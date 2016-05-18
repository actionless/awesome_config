--[[
     Licensed under GNU General Public License v2
      * (c) 2013-2014, Yauheni Kirylau
--]]

local naughty      = require("naughty")
local beautiful    = require("beautiful")
local awful = require("awful")

local h_table      = require("utils.table")
local h_string      = require("utils.string")
local parse = require("utils.parse")
local helpers = require("actionless.helpers")
local newinterval = helpers.newinterval
local common_widget = require("actionless.widgets.common").decorated


-- CPU usage
-- widgets.cpu
local cpu = {
  last_total = 0,
  last_active = 0,
  now = {},
  notification = nil,
}

local function worker(args)
  args     = args or {}
  local update_interval  = args.update_interval or 5
  cpu.cores_number = tonumber(parse.command_to_string('nproc'))
  cpu.timeout = args.timeout or 0

  cpu.widget = common_widget(args)
  cpu.widget:set_image(beautiful.widget_cpu)
  cpu.widget:connect_signal(
    "mouse::enter", function () cpu.show_notification() end)
  cpu.widget:connect_signal(
    "mouse::leave", function () cpu.hide_notification() end)

  cpu.list_len = args.list_length or 10

  local new_top = args.new_top or true
  cpu.command = "top -o \\%CPU -b -n 1 -w 512 -d 0.05"

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
      font = beautiful.notification_monofont,
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
    for _, line in ipairs(
      h_table.range(
        parse.string_to_lines(output),
        6 + cpu.cores_number
      )
    ) do
      --local pid, percent, name = line:match("^(%d+)%s+(.+)%s+(.*)")
      local values = h_string.split(line, ' ')
      local pid = values[1]
      local percent = values[new_top and 7 or 9]
      local name = values[new_top and 11 or 12]
      percent = percent + 0
      if percent and percent ~= 0 and name ~= 'top' then
        if result[pid] then
          result[pid] = (result[pid] + percent)/2
        elseif name then
          result[pid] = percent
        end
        names[pid] = name
      end
    end

    local result_string = ''
    local counter = 0
    for pid, percent in h_table.spairs(result, function(t,a,b) return t[b] < t[a] end) do
      result_string = result_string .. string.format("%5s %5.2f %s", pid, percent, names[pid])
      counter = counter + 1
      if counter == cpu.list_len then
        break
      end
      result_string = result_string .. '\n'
    end
    if result_string ~= '' then
      result_string = "  PID  %CPU COMMAND\n" .. result_string
    else
      result_string = "no running processes atm"
    end
    cpu.notification = naughty.notify({
      text = result_string,
      timeout = cpu.timeout,
      font = beautiful.notification_monofont,
      replaces_id = cpu.get_notification_id(),
      position = beautiful.widget_notification_position,
    })
  end

  function cpu.update()
    cpu.now.la1, cpu.now.la5, cpu.now.la15 = parse.find_in_file(
      "/proc/loadavg",
      "^([0-9.]+) ([0-9.]+) ([0-9.]+) .*")
    if tonumber(cpu.now.la1) > cpu.cores_number * 2 then
      cpu.widget:set_error()
    elseif tonumber(cpu.now.la1) > cpu.cores_number then
      cpu.widget:set_warning()
    else
      cpu.widget:set_normal()
    end
    cpu.widget:set_text(
      string.format(
        "%-4s",
        cpu.now.la1
      ))
  end

  newinterval(update_interval, cpu.update)

  return setmetatable(cpu, { __index = cpu.widget })
end

return setmetatable(cpu, { __call = function(_, ...) return worker(...) end })
