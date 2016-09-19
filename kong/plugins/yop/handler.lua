local BasePlugin = require "kong.plugins.base_plugin"

local ipairs, ngx, table = ipairs, ngx, table
local json = require "kong.yop.dkjson"
local cjson = require "cjson"
local initializeCtx = require 'kong.plugins.yop.interceptor.initialize_ctx'

local security_center = require 'kong.yop.security_center'
local response = require 'kong.yop.response'

local interceptors = {
  require 'kong.plugins.yop.interceptor.http_method',
  require 'kong.plugins.yop.interceptor.whitelist',
  require 'kong.plugins.yop.interceptor.authorize',
  require 'kong.plugins.yop.interceptor.authenticate',
  require 'kong.plugins.yop.interceptor.default_value',
  require 'kong.plugins.yop.interceptor.request_validator',
  require 'kong.plugins.yop.interceptor.request_transformer',
  require 'kong.plugins.yop.interceptor.load_balance'
}
local keyOrder = { "state", "result", "ts", "sign", "error" }

local YopHandler = BasePlugin:extend()

function YopHandler:new() end

function YopHandler:init_worker()
end

function YopHandler:access()
  local ctx = { nginx = true }
  initializeCtx.process(ctx);
  if not ctx.nginx then return end
  ngx.ctx.body = ""
  for _, interceptor in ipairs(interceptors) do interceptor.process(ctx) end
end

function BasePlugin:header_filter()
  ngx.header.content_length = nil
end

function YopHandler:body_filter()
  --  异常情况，主动跳过后续的加密签名处理
  if ngx.ctx.skipBodyFilter then return end

  -- ngx.arg[2] false 意味着,body没有接收完.
  -- When setting nil or an empty Lua string value to ngx.arg[1], no data chunk will be passed to the downstream Nginx output filters at all.
  if (not ngx.arg[2]) then ngx.ctx.body, ngx.arg[1] = table.concat({ ngx.ctx.body, ngx.arg[1] }), nil return end

  -- body接收完全了
  local body = cjson.decode(ngx.ctx.body)
  local appSecret, signAlg = ngx.ctx.appSecret, ngx.ctx.signAlg

  local r = response:new()
  if body.status ~= "SUCCESS" then
    r:fail()
    r.error = { code = body.exception.code, message = body.exception.errMsg }
    if appSecret then
      r.sign = security_center.sign(signAlg, table.concat({ appSecret, r.state, r.ts, appSecret }))
    end
  else
    r.result = body.result -- 用作加密,签名
    if appSecret and ngx.ctx.encrypt and r.result ~= cjson.null then
      r.result = security_center.encryptResponse(ngx.ctx.keyStoreType, r.result, appSecret)
    end
    if appSecret then
      r.sign = security_center.sign(signAlg, table.concat({ appSecret, r.state, r.result, r.ts, appSecret }))
    end
  end
  ngx.arg[1] = json.encode(r, { indent = true, keyOrder = keyOrder });
end

YopHandler.PRIORITY = 800
return YopHandler