--
-- 负载均衡拦截器
-- Created by IntelliJ IDEA.
-- User: zhangwenkang
-- Date: 16-7-23
-- Time: 下午12:04
-- To change this template use File | Settings | File Templates.
--
local ngx, ipairs, math, table = ngx, ipairs, math, table
local _M = {}

local routeRuleMatcher = {
  RANDOM = function(rule) return math.random(1, rule.denominator) <= rule.denominator end,
  VALUE_EQUAL = function(rule, ctx) return ctx.parameters[rule.parameterName] == rule.parameterValue end
}

local function routeRuleMatch(rule, ctx) return routeRuleMatcher[rule.ruleType](rule, ctx) end

local url = { "http://", "upstream", "/", "backendApp", "/soa/rest/", "className", "/", "methodName" }
local function loadBalance(ctx, upstream)
  url[2], url[4], url[6], url[8] = upstream.name, ctx.api.backendApp, ctx.api.bareClass, ctx.api.bareMethod
  ngx.ctx.upstream_url = table.concat(url)
end

_M.process = function(ctx)
  for _, upstream in ipairs(ctx.upstreams) do
    if upstream.immutable or routeRuleMatch(upstream.routeRule) then loadBalance(ctx, upstream) return end
  end
end

return _M
