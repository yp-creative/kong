local BasePlugin = require "kong.plugins.base_plugin"

local HirenHandler = BasePlugin:extend()

function HirenHandler:new()
  HirenHandler.super.new(self, "hiren")
end

function HirenHandler:access(conf)
  HirenHandler.super.access(self)

  -- Parse querystring parameters in a Lua table
  local querystring_parameters = ngx.req.get_uri_args()

  -- Load the first and last name initial
  local first_name_initial = querystring_parameters.firstName and string.sub(querystring_parameters.firstName, 1, 1) or ""
  local last_name_initial = querystring_parameters.lastName and string.sub(querystring_parameters.lastName, 1, 1) or ""

  -- Add the header to the upstream request
  ngx.req.set_header("X-User-Name-Initials", first_name_initial..last_name_initial)
end

HirenHandler.PRIORITY = 800

return HirenHandler
