--[[
     Licensed under GNU General Public License v2 
      * (c) 2013-2014  Yauheni Kirylau
      * (c) 2013,      Luke Bonham                
      * (c) 2010-2012, Peter Hofmann              
--]]

local debug  = require("debug")
local awful = require("awful")
local capi   = { timer = timer,
                 client = client,
                 mouse = mouse }
local io     = { open = io.open,
                 lines = io.lines,
                 popen = io.popen }
local rawget = rawget
local beautiful = require("beautiful")



-- helper functions for internal use
local helpers = {}


helpers.font = string.match(beautiful.get().font, "([%a, ]+) %d+")

helpers.dir    = debug.getinfo(1, 'S').source:match[[^@(.*/).*$]]
helpers.scripts_dir = helpers.dir .. 'scripts/'

helpers.mono_preset = { font=beautiful.get().notification_monofont,
			opacity=beautiful.get().notification_opacity }

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

function helpers.only_digits(str)
  if not str then return nil end
  return tonumber(str:match("%d+"))
end

function helpers.split_string(str, sep)
        local sep, fields = sep or ":", {}
        local pattern = string.format("([^%s]+)", sep)
        str:gsub(pattern, function(c) fields[#fields+1] = c end)
        return fields
end

function helpers.imerge(t, set)
    for _, v in ipairs(set) do
        table.insert(t, v)
    end
end

function helpers.getn(dict)
  local num_items = 0
  for k,v in pairs(dict) do
    num_items = num_items + 1
  end
  return num_items
end

function helpers.merge(t, set)
    for k, v in pairs(set) do
        t[k] = v
    end
end

function helpers.map_table_values(t, func)
  for k, v in pairs(t) do
    t[k] = func(v)
  end
end
-- {{{ Read the ... of a file or return nil.


--=============================================================================
-- }}}

function helpers.run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
	findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

local xml_entity_names = { ["'"] = "&apos;", ["\""] = "&quot;", ["<"] = "&lt;", [">"] = "&gt;", ["&"] = "&amp;" };
function helpers.escape(text)
    --return text and text:gsub("['&<>\"]", xml_entity_names) or nil
    return text and text:gsub("[&<>\"]", xml_entity_names) or nil
end

function helpers.get_current_screen()
  if capi.client.focus then
    return capi.client.focus.screen
  else
    return capi.mouse.screen
  end
end

return helpers
