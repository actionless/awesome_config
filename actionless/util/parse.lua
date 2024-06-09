--[[
     Licensed under GNU General Public License v2
      * (c) 2014-2021  Yauheni Kirylau
--]]

local g_string = require("gears.string")

local log = require("actionless.util.debug").log
local h_fs = require("actionless.util.filesystem")
local h_table = require("actionless.util.table")


local parse = {}

function parse.string_to_lines(str)
  if (not str) or (str == '') then return {} end
  return g_string.split(str, '\n')
end

function parse.lines_to_string(lines)
  return table.concat(lines, '\n')
end

----------------------------------------------
function parse.filename_to_string_async(file_name, callback)
  h_fs.read_file(file_name, callback)
end

function parse.filename_to_lines_async(file_name, callback)
  parse.filename_to_string_async(file_name, function(result) callback(parse.string_to_lines(result)) end)
end

----------------------------------------------

function parse.find_in_lines(lines, regex)
  local matches = {}
  for _, line in ipairs(lines) do
    for _, match in ipairs({line:match(regex)}) do
      if match then
        matches[#matches+1] = match
      end
    end
  end
  return h_table.unpack(matches)
end

function parse.find_values_in_lines(lines, regex, match_keys, post_func)
  local key, value
  local result_values = {}
  local match_keys_length = h_table.getn(match_keys)
  for _, line in ipairs(lines) do
    if match_keys_length <= 0 then
      return result_values
    end
    key, value = line:match(regex)
    for result_key, match_key in pairs(match_keys) do
      if key == match_key then
        if post_func then value = post_func(value) end
        result_values[result_key] = value
        match_keys[result_key] = nil
        match_keys_length = match_keys_length - 1
      end
    end
  end
  return result_values
end

----------------------------------------------
function parse.find_in_multiline_string(str, regex)
  return parse.find_in_lines(
    parse.string_to_lines(str), regex)
end

function parse.find_values_in_string(str, regex, match_keys, post_func)
  return parse.find_values_in_lines(
    parse.string_to_lines(str), regex, match_keys, post_func)
end

----------------------------------------------

function parse.find_in_file_sync(file_name, regex, args)
  args = args or {}
  if not args.skip_warning then
    nlog(
      "find_in_file_sync() is deprecated\n"
      .."(called from "..tostring(args.from)..")"
    )
  end
  local fp = io.open(file_name)
  if fp == nil then return nil end

  local lines = {}
  local counter = 1
  for line in fp:lines() do
    lines[counter] = line
    counter = counter + 1
  end

  local result = {parse.find_in_lines(lines, regex)}
  fp:close()
  return h_table.unpack(result)
end

function parse.find_in_file_async(file_name, regex, callback)
  parse.filename_to_lines_async(file_name, function(lines)
    callback(parse.find_in_lines(lines, regex))
  end)
end

function parse.find_values_in_file_async(file_name, regex, match_keys, post_func, callback)
  parse.filename_to_lines_async(file_name, function(lines)
    callback(parse.find_values_in_lines(lines, regex, match_keys, post_func))
  end)
end

return parse
