local BasePlugin = require "kong.plugins.base_plugin"

local ipairs = ipairs
local ngx = ngx
local table = table
local json = require "so.dkjson"

local initializeCtx = require 'kong.plugins.yop.interceptor.initialize_ctx'
local httpMethod = require 'kong.plugins.yop.interceptor.http_method'
local whitelist = require 'kong.plugins.yop.interceptor.whitelist'
local auth = require 'kong.plugins.yop.interceptor.auth'
local validateSign = require 'kong.plugins.yop.interceptor.validate_sign'
local decrypt = require 'kong.plugins.yop.interceptor.decrypt'
local defaultValue = require 'kong.plugins.yop.interceptor.default_value'
local requestValidator = require 'kong.plugins.yop.interceptor.request_validator'
local requestTransformer = require 'kong.plugins.yop.interceptor.request_transformer'
local loadBalance = require 'kong.plugins.yop.interceptor.load_balance'
local prepareUpstream = require 'kong.plugins.yop.interceptor.prepare_upstream'

local security_center = require 'kong.yop.security_center'
local response, _ = require 'kong.yop.response'()

local interceptors = {
  initializeCtx, httpMethod, whitelist, auth, decrypt, validateSign,
  defaultValue, requestValidator, requestTransformer, loadBalance, prepareUpstream
}
local YopHandler = BasePlugin:extend()

function YopHandler:new()
end

function YopHandler:access()
  ngx.ctx.body = ""
  local ctx = {}
  for _, interceptor in ipairs(interceptors) do
    interceptor.process(ctx)
  end
end

local function handleResponse(body)
  local appSecret = ngx.ctx.appSecret
  ngx.log(ngx.INFO,"app secret:"..appSecret)
  local r = response:new()
  local bizResult = body -- 用作加密,签名
  -- 签名：先处理空格、换行；返回值为空也可签名
  if appSecret then
    r.sign = security_center.sign(bizResult)
  end

  if appSecret and ngx.ctx.encrypt and bizResult ~= "" then
    -- 加密：不处理空格、换行；返回值为空则不做加密
    r.result = security_center.encrypt(bizResult)
  end
  -- 无法直接序列化response,因为response中含有function
  local resp = {}
  resp.state = r.state
  resp.ts = r.ts
  resp.sign = r.sign
  resp.error = r.error
  resp.stringResult = r.stringResult
  resp.format = r.format
  resp.validSign = r.validSign
  resp.result = r.result
  ngx.arg[1] = json.encode (resp, { indent = true })   -- "ts":1472608159000
  ngx.log(ngx.ERR,"ngx.arg[1]:"..ngx.arg[1])
end

function YopHandler:body_filter()
  if ngx.ctx.skipBodyFilter then return end
  -- ngx.arg[2] false 意味着,body没有接收完.
  if (not ngx.arg[2]) then
    ngx.ctx.body = table.concat({ ngx.ctx.body, ngx.arg[1] })
    ngx.arg[1] = nil -- When setting nil or an empty Lua string value to ngx.arg[1], no data chunk will be passed to the downstream Nginx output filters at all.
  else
    -- body接收完全了
    handleResponse(ngx.ctx.body)
  end
end

YopHandler.PRIORITY = 800
return YopHandler