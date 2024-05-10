--[[
     Licensed under GNU General Public License v2
      * (c) 2013-2014, Yauheni Kirylau
--]]
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local awful = require("awful")
local gears_timer = require("gears.timer")
local naughty = require("naughty")

local parse = require("actionless.util.parse")
local decorated_widget= require("actionless.widgets.common").decorated
local nlog = require("actionless.util.debug").naughty_log
local h_table = require("actionless.util.table")


-- coretemp
local temp = {
  temperatures = {},
  temperatures_nv_smi = {},
}


function temp.hide_notification()
  if temp.notification ~= nil then
    naughty.destroy(temp.notification)
    temp.notification = nil
  end
end


function temp.get_notification_id()
  return temp.notification and temp.notification.id or nil
end


function temp.show_notification()
  local message = ''
  local nv_i = 1
  local i = 1
  local num_sensors = h_table.getn(temp.sensors)
  for sensor_id, sensor_data in pairs(temp.sensors) do
    local temp_value
    if sensor_data.device == 'nvidia' then
      temp_value = temp.temperatures_nv_smi[nv_i]
      nv_i = nv_i + 1
    else
      temp_value = temp.temperatures[i]
      i = i + 1
    end
    message = message .. string.format(
      "%5s: %s",
      sensor_id,
      temp_value or "nil"
    )
    local sensor_idx = i + nv_i - 2
    if sensor_idx < num_sensors then
      message = message .. "\n"
    end
  end

  temp.notification = naughty.notify({
    text = message,
    timeout = temp.notification_timeout,
    font = beautiful.mono_text_font,
    replaces_id = temp.get_notification_id(),
    position = beautiful.widget_notification_position,
  })
end


function temp.update()
  local jq_queries = {}
  local nv_smi_queries = {}
  for _, sensor_data in pairs(temp.sensors) do
    if sensor_data.device ~= 'nvidia' then
      table.insert(jq_queries, string.format(
        '."%s"."%s"."%s_input"',
        sensor_data.device,
        sensor_data.sensor,
        sensor_data.sensor_input or sensor_data.sensor
      ))
    else
      table.insert(nv_smi_queries, string.format(
        ' -e "%s"',
        sensor_data.sensor
      ))
    end
  end
  local cmd = "sensors -Aj | jq '" .. table.concat(jq_queries, ",") .. "'"
  awful.spawn.easy_async({'sh', '-c', cmd}, temp._post_update, temp._error_handler)
  if h_table.getn(nv_smi_queries) > 0 then
    cmd = "nvidia-smi -q | grep " .. table.concat(nv_smi_queries, " ") .. " | cut -d: -f2 | cut -d' ' -f2"
    awful.spawn.easy_async({'sh', '-c', cmd}, temp._post_update_nv_smi, temp._error_handler)
  end
end

function temp._error_handler(str)
  nlog(str)
end

function temp._post_update(str)
  temp.temperatures = parse.string_to_lines(str)
  temp._post_update_common()
end

function temp._post_update_nv_smi(str)
  temp.temperatures_nv_smi = parse.string_to_lines(str)
  temp._post_update_common()
end

function temp._post_update_common()
  --TODO: add not only .warning but also .critical:
  local max_temp_delta = 0
  local max_temp_sensor_temp
  local max_temp_sensor_name
  local sensor_counter = 1
  local sensor_counter_nv_smi = 1
  for sensor_name, sensor_data in pairs(temp.sensors) do
    local this_temp
    if sensor_data.device ~= 'nvidia' then
      this_temp = tonumber(temp.temperatures[sensor_counter])
      sensor_counter = sensor_counter + 1
    else
      this_temp = tonumber(temp.temperatures_nv_smi[sensor_counter_nv_smi])
      sensor_counter_nv_smi = sensor_counter_nv_smi + 1
    end
    if this_temp then
      local warning_temp = sensor_data.warning
      if (this_temp - warning_temp) >= max_temp_delta then
        max_temp_delta = this_temp - warning_temp
        max_temp_sensor_temp = this_temp
        max_temp_sensor_name = sensor_name
      end
    end
  end

  if max_temp_delta > 0 then
    temp.widget:set_text(string.format(" %s: %2i°C", max_temp_sensor_name, max_temp_sensor_temp))
    if beautiful.widget_temp_high then
      temp.widget:set_image(beautiful.widget_temp_high)
    end
    temp.widget:set_bg(beautiful.panel_widget_bg_error)
    temp.widget:set_fg(beautiful.panel_widget_fg_error)
    temp.widget:show()
  else
    temp.widget:hide()
    temp.widget:set_bg(temp.bg)
    temp.widget:set_fg(temp.fg)
  end
end

function temp.init(args)
  args = args or {}
  args.padding = args.padding or {
    left = math.ceil((beautiful.panel_widget_spacing or 0) / 2) or dpi(3),
    right = math.ceil((beautiful.panel_widget_spacing or 0) / 2) or dpi(3),
  }
  local update_interval = args.update_interval or 10
  temp.sensors = args.sensors
  if not temp.sensors then
    nlog('Temperature widget: ".sensors" arg is unset')
    return
  end
  temp.bg = args.bg or beautiful.panel_widget_bg or beautiful.panel_fg or beautiful.fg
  temp.fg = args.fg or beautiful.panel_widget_fg or beautiful.panel_bg or beautiful.bg

  temp.widget = decorated_widget(args)
  if beautiful.widget_temp then
    temp.widget:set_image(beautiful.widget_temp)
  end
  temp.widget:connect_signal(
    "mouse::enter", function () temp.show_notification() end
  )
  temp.widget:connect_signal(
    "mouse::leave", function () temp.hide_notification() end
  )

  gears_timer({
    callback=temp.update,
    timeout=update_interval,
    autostart=true,
    call_now=true,
  })

  return temp.widget
end

return setmetatable(temp, { __call = function(_, ...) return temp.init(...) end })
