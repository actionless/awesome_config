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
local gears = require("gears")
local beautiful = require("beautiful")


-- helper functions for internal use
local helpers = {}


helpers.font = string.match(beautiful.get().font or "monospace 8", "([%a, ]+) %d+")
helpers.dir    = debug.getinfo(1, 'S').source:match[[^@(.*/).*$]]


function helpers.newinterval(timeout, fun, nostart)
  local t = gears.timer {timeout = timeout or 5}
  t:connect_signal("timeout", function(...)
      t:stop()
      fun(...)
      t:again()
  end)
  t:start()
  if not nostart then
    t:emit_signal("timeout")
  end
end

function helpers.newdelay(timeout, fun)
  local function wrapped_fun(...)
    fun(...)
    return false
  end
  gears.timer.weak_start_new(timeout, wrapped_fun)
end


function helpers.run_once(cmd)
  local findme = cmd
  local firstspace = cmd:find(" ")
  if firstspace then
	findme = cmd:sub(0, firstspace-1)
  end
  awful.spawn.with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

function helpers.async_spawn(cmd, callback)
  local stdout = ''
  local stderr = ''
  local function parse_stdout(str)
    stdout = stdout .. str .. "\n"
  end
  local function parse_stderr(str)
    stderr = stderr ..  str .. "\n"
  end
  local function done_callback()
    return callback(stdout, stderr)
  end
  local exit_callback_fired = false
  local output_done_callback_fired = false
  local function exit_callback()
    exit_callback_fired = true
    if output_done_callback_fired then
      return done_callback()
    end
  end
  local function output_done_callback()
    output_done_callback_fired = true
    if exit_callback_fired then
      return done_callback()
    end
  end
  return awful.spawn.with_line_callback(
    cmd, {
    stdout=parse_stdout,
    stderr=parse_stderr,
    exit=exit_callback,
    output_done=output_done_callback
  })
end


function helpers.client_floats(c)
  local l = awful.layout.get(c.screen)
  if awful.layout.getname(l) == 'floating' or awful.client.floating.get(c) then
    return true
  end
  return false
end


function helpers.layout_get_id(layout)
  local layout_name = awful.layout.getname(layout)
  for layout_id, layout2 in ipairs(awful.layout.layouts) do
    if layout_name == awful.layout.getname(layout2) then
      return layout_id
    end
  end
end


function helpers.tag_noempty_list(s)
  local screen = s or awful.screen.focused()
  local tags = awful.tag.gettags(screen)
  local vtags = {}
  for i, t in pairs(tags) do
      if awful.widget.taglist.filter.noempty(t) then
          vtags[#vtags + 1] = t
      end
  end
  return vtags
end


function helpers.get_tag_idx(target_tag, tag_list, s)
  s = s or awful.screen.focused()
  tag_list = tag_list or awful.tag.gettags(s)
  for idx, t in ipairs(tag_list) do
    if t == target_tag then
      return idx
    end
  end
end


function helpers.tag_view_noempty(delta, s)
    s = s or awful.screen.focused()
    local selected_tag = awful.tag.selected(s)
    local noempty_tags = helpers.tag_noempty_list(s)
    local target_tag_local_idx = helpers.get_tag_idx(selected_tag, noempty_tags, s) + delta
    if target_tag_local_idx < 1 then
      target_tag_local_idx = #noempty_tags
    elseif target_tag_local_idx > #noempty_tags then
      target_tag_local_idx = 1
    end
    local current_idx = awful.tag.getidx()
    local target_idx = awful.tag.getidx(noempty_tags[target_tag_local_idx])
    local idx_delta = current_idx - target_idx
    awful.tag.viewidx(-idx_delta, s)
end


function helpers.get_nix_xresources_theme_path()
  local result
  result = awful.util.pread("readlink -e /nix/store/*-awesome-3*/share/awesome/themes/xresources | tail -n 1")
  result = string.gsub(result, "\n", "")
  print("DEBUG")
  print(result)
  print("DEBUG_END")
  return result
end


localstorage = {}
function helpers.tag_getproperty(t, key)
  local id = awful.tag.getidx(t)
  return localstorage[key] and localstorage[key][id]
end
function helpers.tag_setproperty(t, key, value)
  local id = awful.tag.getidx(t)
  if not localstorage[key] then
    localstorage[key] = {}
  end
  localstorage[key][id] = value
end


function helpers.tag_toggle_gap(t)
  t = t or awful.tag.selected()
  local current_gap = awful.tag.getgap(t)
  local prev_gap = helpers.tag_getproperty(t, "prev_useless_gap")
    or ((current_gap>0) and 0 or beautiful.useless_gap)
  if prev_gap == current_gap then
    if current_gap == 0 then
      prev_gap = beautiful.useless_gap
    else
      prev_gap = 0
    end
  end
  helpers.tag_setproperty(t, "prev_useless_gap", current_gap)
  awful.tag.setgap(prev_gap, t)
end


return helpers
