--
-- Created by IntelliJ IDEA.
-- User: zhangwenkang
-- Date: 16-7-23
-- Time: 下午12:04
-- To change this template use File | Settings | File Templates.
--
local decodeOnceToString = ngx.unescape_uri
local response, _ = require 'kong.yop.response'()
local security_center = require 'kong.yop.security_center'

local stringy = require "stringy"

local ngx = ngx
local pcall, pairs, table = pcall, pairs, table

local _M = {}

local function decrypt(ctx, secret, parameters)
  local body = parameters.encrypt
  if not body then return end
  if body == "true" then ngx.ctx.encrypt = true return end -- encrypt=true,表示无加密请求参数，但须加密返回

  ngx.ctx.encrypt, ngx.ctx.keyStoreType = true, ctx.keyStoreType

  local status, message = pcall(security_center.decryptRequest, ctx.keyStoreType, body, secret)
  -- 解密失败
  if not status then response.decryptException(ctx.appKey) end

  -- 解密成功,解析message
  local params = stringy.split(message, "&")
  for _, value in pairs(params) do
    local kv = stringy.split(value, "=")
    parameters[kv[1]] = decodeOnceToString(kv[2])
  end
  ctx.parameters = parameters
end

local function validateSign(ctx, secret, parameters)
  local ignoreSignFields = ctx.ignoreSignFields
  if not parameters.signRet then return end -- 客户端是否有过签名
  local expectedSign, alg = parameters.sign, ctx.api.signAlg -- 签名摘要

  local signKeys = { "method", "v" }
  for key, _ in pairs(parameters) do
    if not ignoreSignFields[key] then table.insert(signKeys, key) end
  end

  table.sort(signKeys)
  parameters.method, parameters.v = ctx.apiUri, ctx.api.apiVersion

  local signBody = ""
  for _, value in pairs(signKeys) do
    signBody = table.concat({ signBody, value, stringy.strip(ctx.parameters[value]) })
  end
  signBody = table.concat({ secret, signBody, secret })

  local actualSign = security_center.sign(alg, signBody)

  if actualSign ~= expectedSign then response.signException(ctx.appKey) end
end

_M.process = function(ctx)
  local secret, parameters = ctx.app.appSecret, ctx.parameters
  ngx.ctx.appSecret = secret -- 将 appSercet 作为全局变量放在ngx.ctx里面,供转发后返回加密和签名使用/
  ngx.ctx.signAlg = ctx.api.signAlg

  decrypt(ctx, secret, parameters)
  validateSign(ctx, secret, parameters)
end
return _M
