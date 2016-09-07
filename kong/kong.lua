-- Kong, the biggest ape in town
--
--     /\  ____
--     <> ( oo )
--     <>_| ^^ |_
--     <>   @    \
--    /~~\ . . _ |
--   /~~~~\    | |
--  /~~~~~~\/ _| |
--  |[][][]/ / [m]
--  |[][][[m]
--  |[][][]|
--  |[][][]|
--  |[][][]|
--  |[][][]|
--  |[][][]|
--  |[][][]|
--  |[][][]|
--  |[][][]|
--  |[|--|]|
--  |[|  |]|
--  ========
-- ==========
-- |[[    ]]|
-- ==========

local meta = require "kong.meta"

_G._KONG = {
  _NAME = meta._NAME,
  _VERSION = meta._VERSION
}

local core = require "kong.core.handler"
local singletons = require "kong.singletons"
local config_loader = require "kong.tools.config_loader"

local ipairs, pairs = ipairs, pairs

-- Attach a hooks table to the event bus
local function attach_hooks(events, hooks)
  for k, v in pairs(hooks) do
    events:subscribe(k, v)
  end
end

-- Kong public context handlers.
-- @section kong_handlers

local Kong = {}

-- Init Kong's environment in the Nginx master process.
-- To be called by the lua-nginx-module `init_by_lua` directive.
-- Execution:
--   - load the configuration from the path computed by the CLI
--   - instanciate the DAO Factory
--   - load the used plugins
--     - load all plugins if used and installed
--     - sort the plugins by priority
--
-- If any error happens during the initialization of the DAO or plugins,
-- it return an nginx error and exit.
function Kong.init()
  local status, err = pcall(function()
    singletons.configuration = config_loader.load(os.getenv("KONG_CONF"))
    singletons.loaded_plugins = {
      {
        name = "yop",
        handler = require("kong.plugins.yop.handler")
      }
    }
    ngx.update_time()
  end)
  if not status then
    ngx.log(ngx.ERR, "Startup error: " .. err)
    os.exit(1)
  end
end

function Kong.init_worker()
  for _, plugin in ipairs(singletons.loaded_plugins) do
    plugin.handler:init_worker()
  end
end

function Kong.access()
  core.access.before()
  for _, plugin in ipairs(singletons.loaded_plugins) do
    plugin.handler:access()
  end
  core.access.after()
end

function Kong.header_filter()
  core.header_filter.before()
  for _, plugin in ipairs(singletons.loaded_plugins) do
    plugin.handler:header_filter()
  end
  core.header_filter.after()
end

function Kong.body_filter()
  for _, plugin in ipairs(singletons.loaded_plugins) do
    plugin.handler:body_filter()
  end
  core.body_filter.after()
end

function Kong.log()
  for _, plugin in ipairs(singletons.loaded_plugins) do
    plugin.handler:log()
  end
  core.log.after()
end

return Kong
