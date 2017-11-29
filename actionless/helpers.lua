--[[
Licensed under GNU General Public License v2
* (c) 2013-2014  Yauheni Kirylau
* (c) 2013,      Luke Bonham
* (c) 2010-2012, Peter Hofmann
--]]

local awful = require("awful")
local beautiful = require("beautiful")


-- helper functions for internal use
local helpers = {}


function helpers.run_once(cmd)
  local findme = cmd
  local firstspace = cmd:find(" ")
  if firstspace then
    findme = cmd:sub(0, firstspace-1)
  end
  awful.spawn.with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
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


function helpers.tag_toggle_gap(t)
  t = t or awful.screen.focused().selected_tag
  local current_gap = t.gap
  local new_gap
  if current_gap == 0 then
    new_gap = beautiful.useless_gap
  else
    new_gap = 0
  end
  t.gap = new_gap
end


function helpers.tag_noempty_list(s)
  s = s or awful.screen.focused()
  local vtags = {}
  for _, t in pairs(s.tags) do
    if awful.widget.taglist.filter.noempty(t) then
      vtags[#vtags + 1] = t
    end
  end
  return vtags
end


function helpers.tag_get_idx(target_tag, tag_list, s)
  s = s or awful.screen.focused()
  tag_list = tag_list or s.tags
  for idx, t in ipairs(tag_list) do
    if t == target_tag then
      return idx
    end
  end
end


function helpers.tag_view_noempty(delta, s)
  s = s or awful.screen.focused()
  local selected_tag = s.selected_tag
  local noempty_tags = helpers.tag_noempty_list(s)
  local target_tag_local_idx = helpers.tag_get_idx(selected_tag, noempty_tags, s) + delta
  if target_tag_local_idx < 1 then
    target_tag_local_idx = #noempty_tags
  elseif target_tag_local_idx > #noempty_tags then
    target_tag_local_idx = 1
  end
  local current_idx = s.selected_tag.index
  local target_idx = noempty_tags[target_tag_local_idx].index
  local idx_delta = current_idx - target_idx
  awful.tag.viewidx(-idx_delta, s)
end


function helpers.client_floats(c)
  local l = awful.layout.get(c.screen)
  if awful.layout.getname(l) == 'floating' or c.floating then
    return true
  end
  return false
end


return helpers
