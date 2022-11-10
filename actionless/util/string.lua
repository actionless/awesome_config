--[[
     Licensed under GNU General Public License v2
      * (c) 2014  Yauheni Kirylau
--]]

-- helper functions for internal use

local gstring = require('gears.string')

local string_helpers = {}

function string_helpers.only_digits(str)
  if not str then return nil end
  return tonumber(str:match("%d+"))
end

function string_helpers.lstrip(str, chars)
  if type(chars) == 'string' then
    chars = {chars,}
  end
  chars = chars or {' ', '\n', '\t'}
  local strip_needed = true
  while strip_needed do

    strip_needed = false
    for _, char in ipairs(chars) do
      if gstring.startswith(str, char) then
        str = string.sub(str, 2)
        strip_needed = true
        break
      end
    end

  end
  return str
end

function string_helpers.rstrip(str, chars)
  if type(chars) == 'string' then
    chars = {chars,}
  end
  chars = chars or {' ', '\n', '\t'}
  local strip_needed = true
  while strip_needed do

    strip_needed = false
    for _, char in ipairs(chars) do
      if gstring.endswith(str, char) then
        str = string.sub(str, 1, -2)
        strip_needed = true
        break
      end
    end

  end
  return str
end

function string_helpers.strip(str, chars)
  str = string_helpers.lstrip(str, chars)
  str = string_helpers.rstrip(str, chars)
  return str
end

function string_helpers.getn(unicode_string)
  local _, string_length = string.gsub(unicode_string, "[^\128-\193]", "")
  return string_length
end

function string_helpers.max_length(unicode_string, max_length, ellipsize)
  if not unicode_string then return nil end
  if string_helpers.getn(unicode_string) <= max_length then
    return unicode_string
  end
  local result = ''
  local counter = 1
  for uchar in string.gmatch(unicode_string, '([%z\1-\127\194-\244][\128-\191]*)') do
      counter = counter + 1
      if counter > max_length then
        if ellipsize then
          result = result .. '…'
        else
          result = result .. uchar
        end
        break
      else
        result = result .. uchar
      end
  end
  return result
end

function string_helpers.multiline_limit(unicode_string, max_length) --char
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

function string_helpers.multiline_limit_word(unicode_string, max_length)
  local words = gstring.split(unicode_string, ' ')

  local result = ''
  local line = ''
  for _, word in ipairs(words) do
    if #word + #line + 1 > max_length and #line>0 then
      result = result .. line .. '\n'
      line = ''
    end
    line = line .. ' ' .. word
      --local subwords = string_helpers.multiline_limit(word, max_length)
  end
  result = result .. line
  return result
end

function string_helpers.join(separator, items)
  local result = ''
  for _, word in ipairs(items) do
    result = result .. separator .. word
  end
  return result
end

return string_helpers
