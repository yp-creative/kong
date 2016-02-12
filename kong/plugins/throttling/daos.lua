local BaseDao = require "kong.dao.cassandra.base_dao"
local cassandra = require "cassandra"
local timestamp = require "kong.tools.timestamp"

local ngx_log = ngx and ngx.log or print
local ngx_err = ngx and ngx.ERR
local tostring = tostring

local ThrottlingMetrics = BaseDao:extend()

function ThrottlingMetrics:new(properties, events_handler)
  self._table = "throttling_metrics"
  self.queries = {
    increment_counter = [[ UPDATE throttling_metrics SET value = value + ? WHERE api_id = ? AND
                            identifier = ? AND
                            period_date = ? AND
                            period = ?; ]],
    select_one = [[ SELECT * FROM throttling_metrics WHERE api_id = ? AND
                      identifier = ? AND
                      period_date = ? AND
                      period = ?; ]],
    delete = [[ DELETE FROM throttling_metrics WHERE api_id = ? AND
                  identifier = ? AND
                  period_date = ? AND
                  period = ?; ]]
  }

  ThrottlingMetrics.super.new(self, properties, events_handler)
end

function ThrottlingMetrics:increment(api_id, identifier, current_timestamp, value)
  local periods = timestamp.get_timestamps(current_timestamp)
  local options = self._factory:get_session_options()
  local session, err = cassandra.spawn_session(options)
  if err then
    ngx_log(ngx_err, "[throttling] could not spawn session to Cassandra: "..tostring(err))
    return
  end

  local ok = true
  for period, period_date in pairs(periods) do
    local res, err = session:execute(self.queries.increment_counter, {
      cassandra.counter(value),
      cassandra.uuid(api_id),
      identifier,
      cassandra.timestamp(period_date),
      period
    })
    if not res then
      ok = false
      ngx_log(ngx_err, "[throttling] could not increment counter for period '"..period.."': ", tostring(err))
    end
  end

  session:set_keep_alive()

  return ok
end

function ThrottlingMetrics:find_one(api_id, identifier, current_timestamp, period)
  local periods = timestamp.get_timestamps(current_timestamp)

  local metric, err = ThrottlingMetrics.super.execute(self, self.queries.select_one, {
    cassandra.uuid(api_id),
    identifier,
    cassandra.timestamp(periods[period]),
    period
  })
  if err then
    return nil, err
  elseif #metric > 0 then
    metric = metric[1]
  else
    metric = nil
  end

  return metric
end

-- Unsuported
function ThrottlingMetrics:find_by_primary_key()
  error("throttling_metrics:find_by_primary_key() not yet implemented", 2)
end

function ThrottlingMetrics:delete(api_id, identifier, periods)
  error("throttling_metrics:delete() not yet implemented", 2)
end

function ThrottlingMetrics:insert()
  error("throttling_metrics:insert() not supported", 2)
end

function ThrottlingMetrics:update()
  error("throttling_metrics:update() not supported", 2)
end

function ThrottlingMetrics:find()
  error("throttling_metrics:find() not supported", 2)
end

function ThrottlingMetrics:find_by_keys()
  error("throttling_metrics:find_by_keys() not supported", 2)
end

return {throttling_metrics = ThrottlingMetrics}
