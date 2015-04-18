--[[
     Licensed under GNU General Public License v2
      * (c) 2013-2014  Yauheni Kirylau
      * (c) 2013,      Luke Bonham
      * (c) 2010-2012, Peter Hofmann
--]]

local debug  = require("debug")
local awful = require("awful")
local capi   = { client = client,
                 mouse = mouse }
local awesome_timer = require("gears").timer or timer


local beautiful = require("beautiful")


-- helper functions for internal use
local helpers = {}

helpers.font = string.match(beautiful.get().font or "monospace 8", "([%a, ]+) %d+")
helpers.dir    = debug.getinfo(1, 'S').source:match[[^@(.*/).*$]]

-- {{{ Timer maker

helpers.timer_table = {}

function helpers.newtimer(name, timeout, fun, nostart)
  local timer = awesome_timer({ timeout = timeout })
  timer:connect_signal("timeout", fun)
  timer:start()
  if not nostart then
    timer:emit_signal("timeout")
  end
  helpers.timer_table[name] = timer
end

function helpers.newinterval(name, timeout, fun, nostart)
  local timer = awesome_timer({ timeout = timeout })
  local patched_function = function(...)
    timer:stop()
    fun(...)
    timer:again()
  end
  timer:connect_signal("timeout", patched_function)
  timer:start()
  if not nostart then
    timer:emit_signal("timeout")
  end
  helpers.timer_table[name] = timer
end

function helpers.newdelay(name, timeout, fun)
  local timer = awesome_timer({ timeout = timeout })
  local patched_function = function(...)
    timer:stop()
    fun(...)
  end
  timer:connect_signal("timeout", patched_function)
  timer:start()
  helpers.timer_table[name] = timer
end

-- }}}

function helpers.run_once(cmd)
  local findme = cmd
  local firstspace = cmd:find(" ")
  if firstspace then
	findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

function helpers.get_current_screen()
  if capi.client.focus then
    return capi.client.focus.screen
  else
    return capi.mouse.screen
  end
end


function helpers.client_floats(c)
  local l = awful.layout.get(c.screen)
  if awful.layout.getname(l) == 'floating' or awful.client.floating.get(c) then
    return true
  end
  return false
end


return helpers
