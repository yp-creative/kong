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

local pcall = pcall
local pairs = pairs

local _M = {}

_M.process = function(ctx)
  local secret, parameters = ctx.app.appSecret, ctx.parameters
  local body = parameters.encrypt
  if not body then return end
  if body == "true" then ctx.parameters.encrypt = true return end -- encrypt=true,表示无加密请求参数，但须加密返回

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
return _M
