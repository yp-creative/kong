--
-- 权限拦截器，用于控制appKey对api的访问权限

-- -- Created by IntelliJ IDEA.
-- User: zhangwenkang
-- Date: 16-7-23
-- Time: 下午12:06
-- To change this template use File | Settings | File Templates.
--
local response, _ = require 'kong.yop.response'()
local tostring = tostring
local _M = {}

_M.process = function(ctx)
  --  level==0的api不受权限控制
  if ctx.api.apiLevel == 0 then return end
  if not ctx.authorization[tostring(ctx.api.id)] then response.permissionDeniedException(ctx.appKey) end
end

return _M
