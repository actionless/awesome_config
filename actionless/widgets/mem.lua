--[[
     Licensed under GNU General Public License v2 
      * (c) 2013-2014, Yauheni Kirylau
      * (c) 2013,      Luke Bonham                
      * (c) 2010-2012, Peter Hofmann              
--]]

local naughty      = require("naughty")
local beautiful    = require("beautiful")

local math         = { floor  = math.floor }
local string       = { format = string.format }
local setmetatable = setmetatable

local helpers      = require("actionless.helpers")
local parse        = require("actionless.parse")
local common_widget= require("actionless.widgets.common").widget
local newtimer     = helpers.newtimer
local font         = helpers.font
local mono_preset  = helpers.mono_preset

-- Memory usage (ignoring caches)
local mem = {
  now = {},
}
mem.widget = common_widget()
mem.widget:set_image(beautiful.widget_mem)
mem.widget:connect_signal("mouse::enter", function () mem.show_notification() end)
mem.widget:connect_signal("mouse::leave", function () mem.hide_notification() end)

local function worker(args)
  local args   = args or {}
  local update_interval  = args.update_interval or 5
  mem.timeout = args.timeout or 0
  mem.font = args.font or font

  mem.list_len = args.list_length or 10
  mem.command = args.command or
    "COLUMNS=512 top -o \\%MEM -b -n 1" .. 
    " | head -n " .. mem.list_len +6 .. "| tail -n " .. mem.list_len  .. 
    [[ | awk '{printf "%-5s %-4s %s\n", $1, $10, $12}']]

  function mem.hide_notification()
    if mem.id ~= nil then
      naughty.destroy(mem.id)
      mem.id = nil
    end
  end

  function mem.show_notification()
    mem.hide_notification()
    local output = parse.command_to_string(mem.command)
    mem.id = naughty.notify({
      text = output,
      timeout = mem.timeout,
      preset = mono_preset
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
        "%-6s", mem.now.used .. "MB"
    ))
  end

  newtimer("mem", update_interval, mem.update)
  return setmetatable(mem, { __index = mem.widget })
end
return setmetatable(mem, { __call = function(_, ...) return worker(...) end })
