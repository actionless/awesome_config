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
  if not nostart then fun() end
  local function wrapped_fun(...)
    fun(...)
    gears.timer.start_new(timeout, wrapped_fun)
    return false
  end
  gears.timer.start_new(timeout, wrapped_fun)
end

function helpers.newdelay(timeout, fun)
  local function wrapped_fun(...)
    fun(...)
    return false
  end
  gears.timer.start_new(timeout, wrapped_fun)
end


function helpers.run_once(cmd)
  local findme = cmd
  local firstspace = cmd:find(" ")
  if firstspace then
	findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end


function helpers.client_floats(c)
  local l = awful.layout.get(c.screen)
  if awful.layout.getname(l) == 'floating' or awful.client.floating.get(c) then
    return true
  end
  return false
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


function helpers.tag_view_noempty(delta, s)
    s = s or awful.screen.focused()
    local selected_tag = awful.tag.selected(s)
    local noempty_tags = helpers.tag_noempty_list(s)
    local target_tag_local_idx
    for i, t in ipairs(noempty_tags) do
      if t == selected_tag then
        target_tag_local_idx = i + delta
        break
      end
    end
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
  result = awful.util.pread("readlink -e /nix/store/*-awesome-3*/share/awesome/themes/xresources")
  result = string.gsub(result, "\n", "")
  print("DEBUG")
  print(result)
  print("DEBUG_END")
  return result
end


return helpers
