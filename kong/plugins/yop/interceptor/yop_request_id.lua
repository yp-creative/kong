--
-- yop_request_id拦截器，判断header是否有X-YOP-Request-ID，
-- 如果不存在，将其值设为uuid

-- -- Created by IntelliJ IDEA.
-- User: zhangwenkang
-- Date: 16-7-23
-- Time: 下午12:06
-- To change this template use File | Settings | File Templates.
local uuid = require "lua_uuid"
local ngx = ngx
local req_set_header = ngx.req.set_header
local req_get_headers = ngx.req.get_headers

local YOP_REQUEST_ID_HEADER_NAME = "X-YOP-Request-ID"

local _M = {}

_M.process = function(ctx)
  local value = req_get_headers()[YOP_REQUEST_ID_HEADER_NAME]
  if not value then
    -- Generate the header value
    value = uuid():gsub("-", "")
    req_set_header(YOP_REQUEST_ID_HEADER_NAME, value)
  end
end

return _M
