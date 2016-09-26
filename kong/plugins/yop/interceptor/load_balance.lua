--
-- 负载均衡拦截器
-- Created by IntelliJ IDEA.
-- User: zhangwenkang
-- Date: 16-7-23
-- Time: 下午12:04
-- To change this template use File | Settings | File Templates.
--
local ngx, ipairs, math, table, next = ngx, ipairs, math, table, next
local log = require 'kong.yop.log'
local response = require 'kong.yop.response'
local _M = {}

local route = {
  RANDOM = function(rule) return math.random(1, rule.denominator) <= rule.numerator end,
  VALUE_EQUAL = function(rule, ctx) return ctx.parameters[rule.parameterName] == rule.parameterValue end
}

local url = { "http://", "upstream", "/", "backendApp", "/soa/rest/", "className", "/", "methodName" }

local function buildUpstream(uuid, upstream, api)
  url[2], url[4], url[6], url[8] = upstream, api.backendApp, api.bareClass, api.bareMethod
  ngx.ctx.upstream_url = table.concat(url)
  log.notice_u(uuid, "use upstream url: ", upstream)
end

_M.process = function(ctx)
  local api = ctx.api
  local endServiceUrl = api.endServiceUrl
  --  指定了endServiceUrl
  if endServiceUrl then buildUpstream(ctx.uuid, endServiceUrl, api) return end
  --  未指定endServiceUrl
  local upstreams = ctx.upstreams
  if upstreams == nil or not next(upstreams) then response.noAvailableUpstreamsException(ctx.appKey) end
  for _, upstream in ipairs(ctx.upstreams) do
    if upstream.immutable then buildUpstream(ctx.uuid, upstream.name, api) return end
    local rule = upstream.routeRule
    if route[rule.ruleType](rule, ctx) then buildUpstream(ctx.uuid, upstream.name, api) return end
  end
end

return _M
