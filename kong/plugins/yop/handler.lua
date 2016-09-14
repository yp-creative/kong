local BasePlugin = require "kong.plugins.base_plugin"

local ipairs, ngx = ipairs, ngx
local initializeCtx = require 'kong.plugins.yop.interceptor.initialize_ctx'


local interceptors = {
  require 'kong.plugins.yop.interceptor.http_method',
  require 'kong.plugins.yop.interceptor.whitelist',
  require 'kong.plugins.yop.interceptor.auth',
  require 'kong.plugins.yop.interceptor.default_value',
  require 'kong.plugins.yop.interceptor.request_validator',
  require 'kong.plugins.yop.interceptor.request_transformer',
  require 'kong.plugins.yop.interceptor.load_balance',
  require 'kong.plugins.yop.interceptor.yop_request_id'
}

local YopHandler = BasePlugin:extend()

function YopHandler:new() end

function YopHandler:init_worker()
end

function YopHandler:access()
  local ctx = { nginx = true }
  initializeCtx.process(ctx);
  if not ctx.nginx then return end
  ngx.ctx.body = ""
  for _, interceptor in ipairs(interceptors) do interceptor.process(ctx) end
end

YopHandler.PRIORITY = 800
return YopHandler