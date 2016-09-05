local BasePlugin = require "kong.plugins.base_plugin"

local ipairs = ipairs
local ngx = ngx
local table = table
local json = require "so.dkjson"
local cjson = require "cjson"
local initializeCtx = require 'kong.plugins.yop.interceptor.initialize_ctx'

local security_center = require 'kong.yop.security_center'
local response, _ = require 'kong.yop.response'()

local interceptors = {
  require 'kong.plugins.yop.interceptor.http_method',
  require 'kong.plugins.yop.interceptor.whitelist',
  require 'kong.plugins.yop.interceptor.auth',
  require 'kong.plugins.yop.interceptor.decrypt',
  require 'kong.plugins.yop.interceptor.validate_sign',
  require 'kong.plugins.yop.interceptor.default_value',
  require 'kong.plugins.yop.interceptor.request_validator',
  require 'kong.plugins.yop.interceptor.request_transformer',
  require 'kong.plugins.yop.interceptor.load_balance'
}

local YopHandler = BasePlugin:extend()

function YopHandler:new() end

function YopHandler:access()
  local ctx = { nginx = true }
  initializeCtx.process(ctx);
  if not ctx.nginx then return end
  ngx.ctx.body = ""
  for _, interceptor in ipairs(interceptors) do interceptor.process(ctx) end
end

function YopHandler:body_filter()
  --  异常情况，主动跳过后续的加密签名处理
  if ngx.ctx.skipBodyFilter then return end

  -- ngx.arg[2] false 意味着,body没有接收完.
  -- When setting nil or an empty Lua string value to ngx.arg[1], no data chunk will be passed to the downstream Nginx output filters at all.
  if (not ngx.arg[2]) then ngx.ctx.body, ngx.arg[1] = table.concat({ ngx.ctx.body, ngx.arg[1] }), nil return end

  -- body接收完全了
  local body = cjson.decode(ngx.ctx.body)
  local r = response:new()
  r.state = body.status

  local appSecret, keyStoreType, signAlg = ngx.ctx.appSecret, ngx.ctx.keyStoreType, ngx.ctx.signAlg

  r.result = body.result -- 用作加密,签名
  -- 签名：先处理空格、换行；返回值为空也可签名
  security_center.signResponse(r, appSecret, signAlg)

  -- 加密：不处理空格、换行；返回值为空则不做加密
  if ngx.ctx.encrypt and r.result ~= "" then security_center.encryptResponse(r, keyStoreType, appSecret) end

  ngx.arg[1] = json.encode(r, { indent = true }) -- "ts":1472608159000
end

YopHandler.PRIORITY = 800
return YopHandler