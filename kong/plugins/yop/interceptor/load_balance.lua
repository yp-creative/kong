--
-- 负载均衡拦截器
-- Created by IntelliJ IDEA.
-- User: zhangwenkang
-- Date: 16-7-23
-- Time: 下午12:04
-- To change this template use File | Settings | File Templates.
--
local response, _ = require 'kong.yop.response'()

local _M = {}

_M.process = function(ctx)
  ngx.ctx.upstream_url = "http://172.17.102.173:8064/yop-center" .. ctx.apiUri
end

return _M
