--
-- 认证拦截器，根据header再判断选择oauth2认证拦截器或常规appSecret拦截器

-- -- Created by IntelliJ IDEA.
-- User: zhangwenkang
-- Date: 16-7-23
-- Time: 下午12:06
-- To change this template use File | Settings | File Templates.
--
local req_get_headers = ngx.req.get_headers
local stringy = require 'stringy'

local oauth2 = require 'kong.plugins.yop.interceptor.authenticate-impl.oauth2_authenticate'
local secret = require 'kong.plugins.yop.interceptor.authenticate-impl.secret_authenticate'

local AUTHORIZATION_HEADER_NAME = "Authorization";
local BEARER = "Bearer ";
local BEARER_LENGTH = #BEARER + 1

local _M = {}

_M.process = function(ctx)
  local authorizationHeader = req_get_headers()[AUTHORIZATION_HEADER_NAME]
  if authorizationHeader and stringy.startswith(authorizationHeader, BEARER) then
    oauth2.process(ctx, authorizationHeader:sub(BEARER_LENGTH))
  else
    secret.process(ctx)
  end
end
return _M
