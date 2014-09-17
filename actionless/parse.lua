--[[
     Licensed under GNU General Public License v2
      * (c) 2014  Yauheni Kirylau
--]]

local helpers = require("actionless.helpers")
local h_table = require("actionless.table")
local h_string = require("actionless.string")


local parse = {}

function parse.string_to_lines(str)
  return h_string.split(str, '\n')
end

function parse.lines_to_string(lines)
  return table.concat(lines, '\n')
end

function parse.fo_to_lines(f)
  if not f then return nil end
  local lines = {}
  local counter = 1
  for line in f:lines() do 
    lines[counter] = line
    counter = counter + 1
  end
  return lines
end

function parse.process_filename(file_name, func, ...)
  local fp = io.open(file_name)
  if fp == nil then return nil end
  local result = func(fp, ...)
  fp:close()
  return result
end

function parse.process_command(cmd, func, ...)
  local fp = io.popen(cmd)
  if fp == nil then return nil end
  local result = func(fp, ...)
  fp:close()
  return result
end

function parse.filename_to_lines(file_name)
  return parse.process_filename(
    file_name, parse.fo_to_lines)
end

function parse.command_to_lines(cmd)
  return parse.process_command(
    cmd, parse.fo_to_lines)
end

function parse.command_to_string(cmd)
  return parse.lines_to_string(
    parse.command_to_lines(cmd))
end
----------------------------------------------

function parse.find_in_lines(lines, regex)
  local match = nil
  for _, line in ipairs(lines) do
    match = line:match(regex)
    if match then
      return match
    end
  end
end

function parse.find_values_in_lines(lines, regex, match_keys, post_func)
  local key, value = nil, nil
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
        match_keys[key] = nil
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
function parse.first_line_in_fo(f)
  if not f then return nil end
  return f:read("*l")
end

function parse.find_in_fo(f, regex)
  return parse.find_in_lines(
    parse.fo_to_lines(f), regex)
end

function parse.find_values_in_fo(f, regex, match_keys, post_func)
  return parse.find_values_in_lines(
    parse.fo_to_lines(f),
    regex, match_keys, post_func)
end
----------------------------------------

function parse.first_line_in_file(file_name)
  return parse.process_filename(
    file_name,
    parse.first_line_in_fo)
end

function parse.find_in_file(file_name, regex)
  return parse.process_filename(
    file_name,
    parse.find_in_fo, regex)
end

function parse.find_values_in_file(file_name, regex, match_keys, post_func)
  return parse.process_filename(
    file_name,
    parse.find_values_in_fo, regex, match_keys, post_func)
end

return parse
