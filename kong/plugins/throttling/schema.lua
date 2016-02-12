local DaoError = require "kong.dao.error"
local constants = require "kong.constants"

return {
  fields = {
    rate = { type = "number" },
    per_second = { type = "number" },
    per_minute = { type = "number" },
    per_hour = { type = "number" },
    per_day = { type = "number" },
    per_month = { type = "number" },
    per_year = { type = "number" },
    async = { type = "boolean", default = false },
    continue_on_error = { type = "boolean", default = false }
  },
  self_check = function(schema, plugin_t, dao, is_update)
    local periods = { "per_second", "per_minute", "per_hour", "per_day", "per_month", "per_year"}
    local has_value
    local invalid_value

    for i, v in ipairs(periods) do
      if plugin_t[v] then
        if has_value then
          invalid_value = "Only one limit can be specified"
          break
        else
          has_value = true
        end
        if plugin_t[v] <=0 then
          invalid_value = "Value for "..v.." must be greater than zero"
        end
      end
    end

    if not has_value then
      return false, DaoError("You need to set at least one limit: "..table.concat(periods, ", "), constants.DATABASE_ERROR_TYPES.SCHEMA)
    elseif invalid_value then
      return false, DaoError(invalid_value, constants.DATABASE_ERROR_TYPES.SCHEMA)
    end

    return true
  end
}
