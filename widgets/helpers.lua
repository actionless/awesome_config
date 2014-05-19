
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013-2014  Yauheni Kirylau
      * (c) 2013,      Luke Bonham                
      * (c) 2010-2012, Peter Hofmann              
                                                  
--]]
local settings = require("widgets.settings")

local debug  = require("debug")

local awful = require("awful")
local capi   = { timer = timer }
local io     = { open = io.open,
                 lines = io.lines }
local rawget = rawget

local theme_dir = settings.theme_dir
-- Lain helper functions for internal use
local helpers = {}

helpers.beautiful = require("beautiful")
helpers.beautiful.init(awful.util.getdir("config") .. theme_dir .. "theme.lua")
helpers.font = string.match(helpers.beautiful.font, "([%a, ]+) %d+")

helpers.dir    = debug.getinfo(1, 'S').source:match[[^@(.*/).*$]]
helpers.icons_dir   = awful.util.getdir("config") .. theme_dir .. 'icons/'
helpers.scripts_dir = helpers.dir .. 'scripts/'

helpers.mono_preset = { font=helpers.beautiful.notification_monofont,
				        opacity=helpers.beautiful.notification_opacity }

-- {{{ Modules loader

function helpers.wrequire(table, key)
    local module = rawget(table, key)
    return module or require(table._NAME .. '.' .. key)
end

-- }}}

-- {{{ Timer maker

helpers.timer_table = {}

function helpers.newtimer(name, timeout, fun, nostart)
    helpers.timer_table[name] = capi.timer({ timeout = timeout })
    helpers.timer_table[name]:connect_signal("timeout", fun)
    helpers.timer_table[name]:start()
    if not nostart then
        helpers.timer_table[name]:emit_signal("timeout")
    end
end

-- }}}

-- {{{ A map utility

helpers.map_table = {}

function helpers.set_map(element, value)
    helpers.map_table[element] = value
end

function helpers.get_map(element)
    return helpers.map_table[element]
end

-- }}}

-- {{{ Read the ... of a file or return nil.


function helpers.flines_to_lines(f)
  if not f then return nil end
  local lines = {}
  local counter = 1
  for line in f:lines() do 
    lines[counter] = line
    counter = counter + 1
  end
  return lines
end

----------------------------------------------

function helpers.find_in_lines(lines, regex)
  local match = nil
  for _, line in pairs(lines) do
    match = line:match(regex)
    if match then
      return match
    end
  end
end

function helpers.find_value_in_lines(lines, regex, match_key)
  local key, value = nil, nil
  for _, line in pairs(lines) do
    key, value = line:match(regex)
    if key == match_key then
      return value
    end
  end
end

----------------------------------------------

function helpers.first_line_in_fo(f)
  if not f then return nil end
  return f:read("*l")
end

function helpers.find_in_fo(f, regex)
  return helpers.find_in_lines(
    helpers.flines_to_lines(f), regex)
end

function helpers.find_value_in_fo(f, regex, match_key)
  return helpers.find_value_in_lines(
    helpers.flines_to_lines(f),
    regex, match_key)
end

----------------------------------------

function helpers.first_line_in_file(f)
  fp = io.open(f)
  local content = helpers.first_line_in_fo(fp)
  fp:close()
  return content
end

function helpers.find_value_in_file(file_name, regex, match_key)
  fp = io.open(file_name)
  content = helpers.find_value_in_fo(
    fp, regex, match_key)
  fp:close()
  return content
end

-- }}}

return helpers
