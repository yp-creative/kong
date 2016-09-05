--
-- 参数名转换拦截器
-- -- Created by IntelliJ IDEA.
-- User: zhangwenkang
-- Date: 16-7-23
-- Time: 下午12:04
-- To change this template use File | Settings | File Templates.
--
local ipairs, pairs, next, table = ipairs, pairs, next, table
local setBodyData = ngx.req.set_body_data
local setHeader = ngx.req.set_header
local stringLen = string.len
local json = require "cjson"
local CONTENT_LENGTH = "content-length"
local CONTENT_TYPE = "content-type"
local APPLICATION_JSON = "application/json; charset=utf-8"

local _M = {}

_M.process = function(ctx)
  local transformer = ctx.transformer
  if transformer == nil or next(transformer) == nil then return end

  local parameters = ctx.parameters
  local postJsonBody = {}

  for i, tr in ipairs(transformer) do
    table.insert(postJsonBody, {})
    for endParamName, paramName in pairs(tr) do
      ngx.log(ngx.INFO, "tr is : " .. (require "cjson").encode(tr))
      ngx.log(ngx.INFO, "endParamName:" .. endParamName .. " paramName:" .. paramName)
      if parameters[paramName] then ngx.log(ngx.INFO, "paramName:" .. paramName .. " paramValue:" .. parameters[paramName]) end
      if parameters[paramName] then postJsonBody[i][endParamName] = parameters[paramName] end
      if parameters[paramName] then ngx.log(ngx.INFO, "jsonParamName:" .. paramName .. " jsonParamValue:" .. postJsonBody[i][endParamName]) end
    end
  end

  ngx.log(ngx.INFO, "postJsonBody is : " .. (require "cjson").encode(postJsonBody))

  if #postJsonBody == 1 then postJsonBody = postJsonBody[1] end
  postJsonBody = json.encode(postJsonBody)

  setBodyData(postJsonBody)
  setHeader(CONTENT_LENGTH, stringLen(postJsonBody))
  setHeader(CONTENT_TYPE, APPLICATION_JSON)
end

return _M
