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

local beautiful = require("beautiful")


-- helper functions for internal use
local helpers = {}

helpers.font = string.match(beautiful.get().font or "monospace 8", "([%a, ]+) %d+")


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

function helpers.newinterval(name, timeout, fun, nostart)
  local timer = capi.timer({ timeout = timeout })
  timer:connect_signal("timeout", patched_function)
  timer:start()
  if not nostart then
    timer:emit_signal("timeout")
  end
  helpers.timer_table[name] = timer
end

function helpers.newtimer(name, timeout, fun, nostart)
  local timer = capi.timer({ timeout = timeout })
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
  local timer = capi.timer({ timeout = timeout })
  local patched_function = function(...)
    timer:stop()
    fun(...)
  end
  timer:connect_signal("timeout", patched_function)
  timer:start()
  helpers.timer_table[name] = timer
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



-----------------------------------------------------------



function helpers.table_merge(container, addition)
  container = container or {}
  addition = addition or {}
  for key, value in pairs(addition) do
      container[key] = value
  end
  return container
end

function helpers.table_add(container, addition)
  container = container or {}
  addition = addition or {}
  for index, value in pairs(addition) do
      table.insert(container, value)
  end
  return container
end

function helpers.getn(dict)
  local num_items = 0
  for k,v in pairs(dict) do
    num_items = num_items + 1
  end
  return num_items
end

function helpers.table_range(t, range_start, range_finish)
  range_finish = range_finish or #table
  result = {}
  for i=range_start,range_finish do
    table.insert(result, t[i])
  end
  return result
end

function helpers.table_contains(t, e)
  for k, v in pairs(t) do
    if v == e then return true end
  end
  return false
end

function helpers.table_contains_key(t, e)
  for k, v in pairs(t) do
    if k == e then return true end
  end
  return false
end

function helpers.table_apply(t, func)
  for k, v in pairs(t) do
    t[k] = func(v)
  end
end

function helpers.table_map(t, func)
  local result = {}
  for k, v in pairs(t) do
    result[k] = func(v)
  end
  return result
end

function helpers.table_reduce(t, func)
  local result
  for k, v in pairs(t) do
    result = func(result, v)
  end
  return result
end

function helpers.deepcopy(orig)
  if type(orig) == 'table' then
      return setmetatable(
        helpers.table_map(
          orig,
          function(value) return helpers.deepcopy(value) end
        ),
        helpers.deepcopy(getmetatable(orig))
      )
  else -- number, string, boolean, etc
      return orig
  end
end

function helpers.tables_sum(tables)
  return helpers.table_reduce(
    tables,
    function(c,a) return helpers.table_add(c,a) end)
end


----------------------------------------


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

local xml_entity_names = {
  ["'"] = "&apos;",
  ["\""] = "&quot;",
  ["<"] = "&lt;",
  [">"] = "&gt;",
  ["&"] = "&amp;"
}
function helpers.escape(result)
    --return text and text:gsub("['&<>\"]", xml_entity_names) or nil
    return result and result:gsub("[&<>\"]", xml_entity_names) or nil
end

function helpers.unicode_length(unicode_string)
  local _, string_length = string.gsub(unicode_string, "[^\128-\193]", "")
  return string_length
end

function helpers.unicode_max_length(unicode_string, max_length)
  if #unicode_string <= max_length then
    return unicode_string
  end
  local result = ''
  local counter = 0
  for uchar in string.gmatch(unicode_string, '([%z\1-\127\194-\244][\128-\191]*)') do
      result = result .. uchar
      counter = counter + 1
      if counter > max_length then break end
  end
  return result
end

function helpers.multiline_limit(unicode_string, max_length)
  if not unicode_string then return nil end
  local result = ''
  local line = ''
  local counter = 0
  for uchar in string.gmatch(unicode_string, '([%z\1-\127\194-\244][\128-\191]*)') do
    line = line .. uchar
    counter = counter + 1
    if counter == max_length then
      result = result .. line .. "\n"
      line = ''
      counter = 0
    end
  end
  if counter > 0 then
      result = result .. line .. string.rep(' ', max_length-helpers.unicode_length(line))
  end
  return result
end

-----------------------------------------------

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

return helpers
