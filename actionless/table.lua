--[[
     Licensed under GNU General Public License v2
--]]


-- helper functions for internal use
local table_helpers = {}


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

function table_helpers.merge(container, addition)
  container = container or {}
  addition = addition or {}
  for key, value in pairs(addition) do
      container[key] = value
  end
  return container
end

function table_helpers.add(container, addition)
  container = container or {}
  addition = addition or {}
  for index, value in pairs(addition) do
      table.insert(container, value)
  end
  return container
end

function table_helpers.getn(container_table)
  local number_of_items = 0
  for key, value in pairs(container_table) do
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

function table_helpers.contains(container_table, desired_value)
  for key, value in pairs(container_table) do
    if value == desired_value then return true end
  end
  return false
end

function table_helpers.contains_key(container_table, desired_key)
  for key, value in pairs(container_table) do
    if key == desired_key then return true end
  end
  return false
end

function table_helpers.apply(container_table, func)
  for key, value in pairs(container_table) do
    container_table[key] = func(value)
  end
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
  for key, value in pairs(container_table) do
    result = func(result, value)
  end
  return result
end

function table_helpers.deepcopy(obj)
  if type(obj) == 'table' then
      return setmetatable(
        table_helpers.map(
          obj,
          function(value) return table_helpers.deepcopy(value) end
        ),
        table_helpers.deepcopy(getmetatable(obj))
      )
  else -- number, string, boolean, etc
      return obj
  end
end

function table_helpers.sum(tables)
  return table_helpers.reduce(
    tables,
    function(container, addition)
      return table_helpers.add(container, addition)
    end
  )
end


return table_helpers
