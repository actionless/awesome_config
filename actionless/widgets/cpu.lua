--[[
     Licensed under GNU General Public License v2
      * (c) 2013-2014, Yauheni Kirylau
--]]
local naughty      = require("naughty")
local beautiful    = require("beautiful")

local h_table      = require("utils.table")
local parse = require("utils.parse")
local helpers = require("actionless.helpers")
local newinterval = helpers.newinterval
local common_widget = require("actionless.widgets.common").widget
local async = require("utils.async")


-- CPU usage
-- widgets.cpu
local cpu = {
  last_total = 0,
  last_active = 0,
  now = {}
}

local function worker(args)
  args     = args or {}
  local update_interval  = args.update_interval or 5
  local bg = args.bg or beautiful.panel_fg or beautiful.fg
  local fg = args.fg or beautiful.panel_bg or beautiful.bg
  cpu.cores_number = args.cores_number or 8
  cpu.timeout = args.timeout or 0

  cpu.widget = common_widget()
  cpu.widget:set_image(beautiful.widget_cpu)
  cpu.widget:connect_signal(
    "mouse::enter", function () cpu.show_notification() end)
  cpu.widget:connect_signal(
    "mouse::leave", function () cpu.hide_notification() end)

  cpu.list_len = args.list_length or 10
  cpu.command = args.command
    or [[ top -o \%CPU -b -n 5 -w 512 -d 0.05 ]] ..
       [[ | awk '{if ($7 > 0.0) {printf "%5s %4s %s\n", $1, $7, $11}}' ]]

  function cpu.hide_notification()
    if cpu.id ~= nil then
      naughty.destroy(cpu.id)
      cpu.id = nil
    end
  end

  function cpu.show_notification()
    cpu.hide_notification()
    cpu.id = naughty.notify({
      text = "waiting for top...",
      timeout = cpu.timeout,
      font = beautiful.notification_monofont,
    })
    async.execute(cpu.command, cpu.notification_callback)
  end

  function cpu.notification_callback(output)
    cpu.hide_notification()
    local result = {}
    local names = {}
    for _, line in ipairs(parse.string_to_lines(output)) do
      local pid, percent, name = line:match("^(%d+)%s+(.+)%s+(.*)")
      if percent and name ~= 'top' then
        percent = percent + 0
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
      else
        result_string = result_string .. '\n'
      end
    end
    if result_string ~= '' then
      result_string = "  PID  %CPU COMMAND\n" .. result_string
    else
      result_string = "no running processes atm"
    end
    cpu.id = naughty.notify({
      text = result_string,
      timeout = cpu.timeout,
      font = beautiful.notification_monofont,
    })
  end

  function cpu.update()
    cpu.now.la1, cpu.now.la5, cpu.now.la15 = parse.find_in_file(
      "/proc/loadavg",
      "^([0-9.]+) ([0-9.]+) ([0-9.]+) .*")
    if tonumber(cpu.now.la1) > cpu.cores_number * 2 then
      cpu.widget:set_bg(beautiful.panel_widget_bg_error)
      cpu.widget:set_fg(beautiful.panel_widget_fg_error)
    elseif tonumber(cpu.now.la1) > cpu.cores_number then
      cpu.widget:set_bg(beautiful.panel_widget_bg_warning)
      cpu.widget:set_fg(beautiful.panel_widget_fg_warning)
    else
      cpu.widget:set_fg(fg)
      cpu.widget:set_bg(bg)
    end
    cpu.widget:set_text(
      string.format(
        "%-4s",
        cpu.now.la1
    ))
  end

  newinterval("cpu", update_interval, cpu.update)

  return setmetatable(cpu, { __index = cpu.widget })
end

return setmetatable(cpu, { __call = function(_, ...) return worker(...) end })
