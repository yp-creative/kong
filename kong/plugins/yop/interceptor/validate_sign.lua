--
-- Created by IntelliJ IDEA.
-- User: jrk
-- Date: 16/7/28
-- Time: 下午4:57
-- To change this template use File | Settings | File Templates.
--

local response, _ = require 'kong.yop.response'()
local security_center = require 'kong.yop.security_center'

local table, pairs = table, pairs

local stringy = require "stringy"

local _M = {}
_M.process = function(ctx)
  local parameters = ctx.parameters
  local ignoreSignFields = ctx.ignoreSignFields
  if not parameters.signRet then return end -- 客户端是否有过签名
  local expectedSign, alg = parameters.sign, ctx.api.signAlg -- 签名摘要

  local needSignKeys = { "method", "v" }
  for key, _ in pairs(parameters) do
    if not ignoreSignFields[key] then
      -- 取出所有需要排序的key
      table.insert(needSignKeys, key)
    end
  end

  table.sort(needSignKeys)

  local signBody = ""
  for _, value in pairs(needSignKeys) do
    if value == "method" then
      signBody = table.concat({ signBody, value, ctx.apiUri })
    elseif value == "v" then
      signBody = table.concat({ signBody, value, ctx.api.apiVersion })
    else
      signBody = table.concat({ signBody, value, stringy.strip(ctx.parameters[value]) })
    end
  end
  local secret = ctx.app.appSecret
  signBody = table.concat({ secret, signBody, secret })

  local actualSign = security_center.sign(alg, signBody)

  if actualSign ~= expectedSign then response.signException(ctx.appKey) end
end
return _M