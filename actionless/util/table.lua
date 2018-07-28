--[[
     Licensed under GNU General Public License v2
--]]

local a_table = require("awful.util").table
local unpack    = unpack or table.unpack -- (compatibility with Lua 5.1)

-- helper functions for internal use
local table_helpers = { unpack = unpack, }


function table_helpers.spairs(t, order)
-- http://stackoverflow.com/a/15706820/1850190

    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function table_helpers.rpairs(t)
-- http://stackoverflow.com/a/15706820/1850190

    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- return the iterator function
    local i = #keys
    return function()
        i = i - 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function table_helpers.reversed(t)
-- https://gist.github.com/balaam/3122129
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end

function table_helpers.merge(container, addition)
  container = container or {}
  addition = addition or {}
  for key, value in pairs(addition) do
      container[key] = value
  end
  return container
end

function table_helpers.list_merge(container, addition)
  container = container or {}
  addition = addition or {}
  for _, item in ipairs(addition) do
    if not a_table.hasitem(container, item) then
      table.insert(container, item)
    end
  end
  return container
end

function table_helpers.add(container, addition)
  container = container or {}
  addition = addition or {}
  for _, value in pairs(addition) do
      table.insert(container, value)
  end
  return container
end

function table_helpers.getn(container_table)
  local number_of_items = 0
  for _, _ in pairs(container_table) do
    number_of_items = number_of_items + 1
  end
  return number_of_items
end

function table_helpers.range(original_table, range_start, range_finish)
  range_finish = range_finish or #original_table
  local result = {}
  for i=range_start,range_finish do
    table.insert(result, original_table[i])
  end
  return result
end

function table_helpers.haskey(container_table, desired_key)
  container_table = container_table or {}
  for key, _ in pairs(container_table) do
    if key == desired_key then return true end
  end
  return false
end

function table_helpers.hasvalue(container_table, desired_key)
  container_table = container_table or {}
  for _, value in pairs(container_table) do
    if value == desired_key then return true end
  end
  return false
end

function table_helpers.map(container_table, func)
  local result = {}
  for key, value in pairs(container_table) do
    result[key] = func(value)
  end
  return result
end

function table_helpers.reduce(container_table, func)
  local result
  for _, value in pairs(container_table) do
    result = func(result, value)
  end
  return result
end

function table_helpers.flat(tables)
  return table_helpers.reduce(
    tables,
    function(container, addition)
      return table_helpers.add(container, addition)
    end
  )
end


return table_helpers
