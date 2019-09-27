--[[
     Licensed under GNU General Public License v2
      * (c) 2013-2014, Yauheni Kirylau
--]]
local beautiful = require("beautiful")
local awful = require("awful")
local gears_timer = require("gears.timer")

local parse = require("actionless.util.parse")
local decorated_widget= require("actionless.widgets.common").decorated


-- coretemp
local temp = {}

local function worker(args)
  args = args or {}
  local update_interval = args.update_interval or 10
  --local warning = args.warning or 75
  local sensors = args.sensors
  if not sensors then
    nlog('Temperature widget: ".sensors" arg is unset')
    return
  end

  local bg = args.bg or beautiful.panel_widget_bg or beautiful.panel_fg or beautiful.fg
  local fg = args.fg or beautiful.panel_widget_fg or beautiful.panel_bg or beautiful.bg

  temp.widget = decorated_widget(args)
  temp.widget:set_image(beautiful.widget_temp)

  function temp.update()
    local jq_queries = {}
    for _, sensor_data in pairs(sensors) do
      table.insert(jq_queries, string.format(
        --'."%s".%s.%s_input',
        '."%s".%s.temp1_input',
        sensor_data.device,
        sensor_data.sensor,
        sensor_data.sensor
      ))
    end
    local cmd = "sensors -Aj | jq '" .. table.concat(jq_queries, ",") .. "'"
    awful.spawn.easy_async({'sh', '-c', cmd}, temp.post_update)
  end

  function temp.post_update(str)
    local max_temp_delta = 0
    local temperatures = parse.string_to_lines(str)
    local sensor_counter = 1
    for sensor_name, sensor_data in pairs(sensors) do
      local warning_temp = sensor_data.warning
      local this_temp = tonumber(temperatures[sensor_counter])
      if this_temp >= warning_temp then
        temp.widget:show()
        temp.widget:set_bg(beautiful.panel_widget_bg_error)
        temp.widget:set_fg(beautiful.panel_widget_fg_error)
        if (this_temp - warning_temp) >= max_temp_delta then
          max_temp_delta = this_temp - warning_temp
          temp.widget:set_text(string.format(" %s: %2i°C ", sensor_name, this_temp))
        end
      elseif max_temp_delta == 0 then
        temp.widget:hide()
        temp.widget:set_bg(bg)
        temp.widget:set_fg(fg)
      end
      sensor_counter = sensor_counter + 1
    end
  end

  gears_timer({
    callback=temp.update,
    timeout=update_interval,
    autostart=true,
    call_now=true,
  })

  return temp.widget
end

return setmetatable(temp, { __call = function(_, ...) return worker(...) end })
