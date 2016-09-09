--
-- 参数名转换拦截器
-- -- Created by IntelliJ IDEA.
-- User: zhangwenkang
-- Date: 16-7-23
-- Time: 下午12:04
-- To change this template use File | Settings | File Templates.
--
local ipairs, pairs, next, table, string = ipairs, pairs, next, table, string
local setBodyData = ngx.req.set_body_data
local setHeader = ngx.req.set_header
local json = require "cjson"

local _M = {}

--[[递归处理参数，eg:
bancard.name.first=zhang
bancard.name.second=wenkang
bancard.idcard.number=1000
bancard.message=run
--应转化为：
{
  "bancard": {
    "idcard": {
      "number": "1000"
    },
    "name": {
      "second": "wenkang",
      "first": "zhang"
    },
    "message": "run"
  }
}]]

_M.process = function(ctx)
  local transformers = ctx.transformer
  if transformers == nil or next(transformers) == nil then return end

  local parameters = ctx.parameters

  --  调用restful接口时，post的参数
  local restfulPostJsonBody = {}

  --  transformer的个数，即rest接口方法签名上的参数总数
  for _, transformer in ipairs(transformers) do
    local methodParameterI = {}
    table.insert(restfulPostJsonBody, methodParameterI)
    for _, endParamNamePair in pairs(transformer) do
      local paramName, prefixes = endParamNamePair.paramName, endParamNamePair.prefixes
      if parameters[paramName] then
        local cursor = methodParameterI
        -- eg:bancard.name.first prefixes=["bankcard","name","first"]
        for i = 1, #prefixes - 1, 1 do
          local prefix = prefixes[i]
          if cursor[prefix] == nil then cursor[prefix] = {} end
          cursor = cursor[prefix]
        end
        cursor[prefixes[#prefixes]] = parameters[paramName]
      end
    end
  end

  --  如果参数只有一个，不需要使用数组，直接将第一个元素的对象提取出来
  if #restfulPostJsonBody == 1 then restfulPostJsonBody = restfulPostJsonBody[1] end
  restfulPostJsonBody = json.encode(restfulPostJsonBody)

  setBodyData(restfulPostJsonBody)
  setHeader("content-length", string.len(restfulPostJsonBody))
  setHeader("content-type", "application/json; charset=utf-8")
end

return _M
