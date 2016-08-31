local Object = require "classic"
local BasePlugin = Object:extend()

function BasePlugin:new(name)
    self._name = name
end

function BasePlugin:init_worker()
end

function BasePlugin:certificate()
end

function BasePlugin:access()
end

function BasePlugin:header_filter()
end

function BasePlugin:body_filter()
end

function BasePlugin:log()
end

return BasePlugin
