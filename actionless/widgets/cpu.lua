--[[
     Licensed under GNU General Public License v2
      * (c) 2013-2019, Yauheni Kirylau
--]]

local naughty = require("naughty")
local beautiful = require("beautiful")
local awful = require("awful")
local gears_timer = require("gears.timer")

local h_table = require("actionless.util.table")
local h_string = require("actionless.util.string")
local parse = require("actionless.util.parse")
local common_widgets = require("actionless.widgets.common")


-- CPU usage
-- widgets.cpu
local cpu = {
  last_total = 0,
  last_active = 0,
  now = {},
  notification = nil,
}

function cpu.hide_notification()
  if cpu.notification ~= nil then
    naughty.destroy(cpu.notification)
    cpu.notification = nil
  end
end

function cpu.get_notification_id()
  return cpu.notification and cpu.notification.id or nil
end

function cpu.show_notification()
  cpu.notification = naughty.notify({
    text = "waiting for top...",
    timeout = cpu.timeout,
    font = beautiful.mono_font,
    replaces_id = cpu.get_notification_id(),
    position = beautiful.widget_notification_position,
  })
  awful.spawn.easy_async(
    cpu.command,
    cpu.notification_callback_done
  )
  cpu.update()
end

function cpu.notification_callback_done(output)
  local notification_id = cpu.get_notification_id()
  if not notification_id then return end
  local result = {}
  local names = {}
  local column_headers = h_string.split(
    h_string.lstrip(h_table.range(
      parse.string_to_lines(output),
      6, 6
    )[1]), ' '
  )
  for _, line in ipairs(
    h_table.range(
      parse.string_to_lines(output),
      7
    )
  ) do
    line = h_string.lstrip(line)
    local values = h_string.split(line, ' ')
    local pid = values[cpu.columns.pid]
    local percent = values[cpu.columns.percent]
    local name = values[cpu.columns.name]
    if percent then percent = percent + 0 end
    if percent and percent ~= 0 and name ~= 'top' then
      if result[pid] then
        result[pid] = (result[pid] + percent)/2
      elseif name then
        result[pid] = percent
      end
      names[pid] = name
    end
  end

  local pid_width = 7

  local result_string = ''
  local counter = 0
  local num_records = h_table.getn(result)
  for pid, percent in h_table.spairs(result, function(t,a,b) return t[b] < t[a] end) do
    if cpu.show_pid then
      result_string = result_string .. string.format("%"..pid_width.."s %6.2f %s", pid, percent, names[pid])
    else
      result_string = result_string .. string.format("%6.2f %s", percent, names[pid])
    end
    counter = counter + 1
    if counter == cpu.list_len or counter == num_records then
      break
    end
    result_string = result_string .. '\n'
  end

  if result_string == '' then
    result_string = "no running processes atm"
  else
    local header_string
    if cpu.show_pid then
      header_string = string.format(
        '%'..pid_width..'s %6s %s\n',
        column_headers[cpu.columns.pid],
        column_headers[cpu.columns.percent],
        column_headers[cpu.columns.name]
      )
    else
      header_string = string.format(
        '%6s %s\n',
        column_headers[cpu.columns.percent],
        column_headers[cpu.columns.name]
      )
    end
    result_string = (header_string ..
      '<span font="'  .. tostring(beautiful.mono_text_font)  .. '">' .. result_string .. '</span> '
    )
  end

  cpu.notification = naughty.notify({
    text = result_string,
    timeout = cpu.timeout,
    font = beautiful.mono_font,
    replaces_id = cpu.get_notification_id(),
    position = beautiful.widget_notification_position,
  })
end

function cpu.update()
  cpu.now.la1, cpu.now.la5, cpu.now.la15 = parse.find_in_file(
    "/proc/loadavg",
    "^([0-9.]+) ([0-9.]+) ([0-9.]+) .*"
  )
  local msg = string.format(
    "%-4s", cpu.now.la1
  )
  local widget_icon
  if tonumber(cpu.now.la1) > cpu.cores_number * 2 then
    cpu.widget:set_error()
    widget_icon = beautiful.widget_cpu_critical
  elseif tonumber(cpu.now.la1) > cpu.cores_number then
    cpu.widget:set_warning()
    widget_icon = beautiful.widget_cpu_high
  else
    cpu.widget:set_normal()
    msg = cpu.widget_text
    widget_icon = beautiful.widget_cpu
  end
  cpu.widget:set_text(msg)
  cpu.widget.progressbar:set_value(cpu.now.la1/cpu.cores_number)
  if widget_icon then
    cpu.widget:set_image(widget_icon)
  end
end

function cpu.init(args)
  args     = args or {}
  local update_interval  = args.update_interval or 5
  cpu.cores_number = tonumber(parse.command_to_string('nproc'))
  cpu.timeout = args.timeout or 0
  cpu.show_pid = args.show_pid or false
  cpu.list_len = args.list_length or 10
  cpu.widget_text = args.text or beautiful.widget_cpu_text or 'CPU'

  local widget = common_widgets.text_progressbar(args)
  cpu.widget = common_widgets.decorated{widget=widget}
  cpu.widget.progressbar = widget.progressbar

  if beautiful.show_widget_icon then
    cpu.widget_text = args.text or ''
  end
  if beautiful.widget_cpu then
    cpu.widget:set_image(beautiful.widget_cpu)
  end

  cpu.widget:connect_signal(
    "mouse::enter", function () cpu.show_notification() end
  )
  cpu.widget:connect_signal(
    "mouse::leave", function () cpu.hide_notification() end
  )

  cpu.command = "top -o \\%CPU -b -n 1 -w 512"
  cpu.columns = args.columns or {
    pid=1,
    percent=9,
    name=12
  }

  gears_timer({
    callback=cpu.update,
    timeout=update_interval,
    autostart=true,
    call_now=true,
  })

  return setmetatable(cpu, { __index = cpu.widget })
end

return setmetatable(cpu, { __call = function(_, ...) return cpu.init(...) end })
