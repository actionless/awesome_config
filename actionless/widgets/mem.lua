--[[
     Licensed under GNU General Public License v2
      * (c) 2013-2015, Yauheni Kirylau
      * (c) 2013,      Luke Bonham
      * (c) 2010-2012, Peter Hofmann
--]]

local naughty = require("naughty")
local beautiful = require("beautiful")
local awful = require("awful")

local h_table = require("utils.table")
local h_string = require("utils.string")
local parse = require("utils.parse")
local common_widget= require("actionless.widgets.common").decorated
local helpers = require("actionless.helpers")

-- Memory usage (ignoring caches)
local mem = {
  now = {},
  notification = nil,
}

local function worker(args)
  args   = args or {}
  local update_interval  = args.update_interval or 5
  mem.timeout = args.timeout or 0

  mem.widget = common_widget(args)
  mem.widget:set_image(beautiful.widget_mem)
  mem.widget:connect_signal(
    "mouse::enter", function () mem.show_notification() end)
  mem.widget:connect_signal(
    "mouse::leave", function () mem.hide_notification() end)
  mem.cores_number = tonumber(parse.command_to_string('nproc'))

  mem.list_len = args.list_length or 10

  local new_top = args.new_top or true
  mem.command = "top -o \\%MEM -b -n 1 -w 512"

  function mem.hide_notification()
    if mem.notification ~= nil then
      naughty.destroy(mem.notification)
      mem.notification = nil
    end
  end

  function mem.get_notification_id()
    return mem.notification and mem.notification.id or nil
  end

  function mem.show_notification()
    mem.notification = naughty.notify({
      text = "waiting for top...",
      timeout = mem.timeout,
      font = beautiful.notification_monofont,
      replaces_id = mem.get_notification_id(),
      position = beautiful.widget_notification_position,
    })
    awful.spawn.easy_async(
      mem.command,
      mem.notification_callback_done
    )
    mem.update()
  end

  function mem.notification_callback_done(output)
    local notification_id = mem.get_notification_id()
    if not notification_id then return end
    local result = {}

    for _, line in ipairs(
      h_table.range(
        parse.string_to_lines(output),
        6 + mem.cores_number
      )
    ) do
      local values = h_string.split(line, ' ')
      local percent = values[new_top and 8 or 10]
      local name = values[new_top and 11 or 12]
      percent = percent + 0
      if result[name] then
        result[name] = result[name] + percent
      elseif name then
        result[name] = percent
      end
    end

    local result_string = ' %MEM COMMAND\n'
    local counter = 0
    for k, v in h_table.spairs(result, function(t,a,b) return t[b] < t[a] end) do
      result_string = result_string .. string.format("%5.1f %s", v, k)
      counter = counter + 1
      if counter == mem.list_len then
        break
      else
        result_string = result_string .. '\n'
      end
    end

    mem.notification = naughty.notify({
      text = result_string,
      timeout = mem.timeout,
      font = beautiful.notification_monofont,
      replaces_id = mem.get_notification_id(),
      position = beautiful.widget_notification_position,
    })
  end

  function mem.update()
    mem.now = parse.find_values_in_file(
      "/proc/meminfo",
      "([%a]+):[%s]+([%d]+).+",
      { total = "MemTotal",
        free = "MemFree",
        buf = "Buffers",
        cache = "Cached",
        swap = "SwapTotal",
        swapf = "SwapFree" },
      function(v) return math.floor(v / 1024) end)
    mem.now.used = mem.now.total - (mem.now.free + mem.now.buf + mem.now.cache)
    mem.now.swapused = mem.now.swap - mem.now.swapf

    mem.widget:set_text(
      string.format(
        "%6s", mem.now.used .. "MB"
      ))
  end

  helpers.newinterval(update_interval, mem.update)
  return setmetatable(mem, { __index = mem.widget })
end
return setmetatable(mem, { __call = function(_, ...) return worker(...) end })
