--[[
     Licensed under GNU General Public License v2
      * (c) 2014  Yauheni Kirylau
--]]

-- helper functions for internal use
local string_helpers = {}


function string_helpers.only_digits(str)
  if not str then return nil end
  return tonumber(str:match("%d+"))
end

function string_helpers.split(str, separator)
  local separator, fields = separator or ":", {}
  local pattern = string.format("([^%s]+)", separator)
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
function string_helpers.escape(str)
  --return str and str:gsub("['&<>\"]", xml_entity_names) or nil
  return str and str:gsub("[&<>\"]", xml_entity_names) or nil
end

function string_helpers.getn(unicode_string)
  local _, string_length = string.gsub(unicode_string, "[^\128-\193]", "")
  return string_length
end

function string_helpers.max_length(unicode_string, max_length)
  if #unicode_string <= max_length then
    return unicode_string
  end
  local result = ''
  local counter = 1
  for uchar in string.gmatch(unicode_string, '([%z\1-\127\194-\244][\128-\191]*)') do
      result = result .. uchar
      counter = counter + 1
      if counter > max_length then break end
  end
  return result
end

function string_helpers.multiline_limit(unicode_string, max_length)
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
      result = result .. line .. string.rep(' ', max_length - string_helpers.getn(line))
  end
  return result
end

return string_helpers
