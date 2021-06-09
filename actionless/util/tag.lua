--[[
Licensed under GNU General Public License v2
* (c) 2013-2014  Yauheni Kirylau
--]]

local awful = require("awful")
local beautiful = require("beautiful")


local tag_helpers = {}


function tag_helpers.toggle_gap(t)
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


function tag_helpers.togglemfpol(t)
    t = t or awful.screen.focused().selected_tag
    if t.master_fill_policy == "expand" then
        t.master_fill_policy = "master_width_factor"
    else
        t.master_fill_policy = "expand"
    end
end


function tag_helpers.noempty_list(s)
  s = s or awful.screen.focused()
  local vtags = {}
  for _, t in pairs(s.tags) do
    if awful.widget.taglist.filter.noempty(t) then
      vtags[#vtags + 1] = t
    end
  end
  return vtags
end


function tag_helpers.get_idx(target_tag, tag_list, s)
  s = s or awful.screen.focused()
  tag_list = tag_list or s.tags
  for idx, t in ipairs(tag_list) do
    if t == target_tag then
      return idx
    end
  end
end


function tag_helpers.view_noempty(delta, s)
  s = s or awful.screen.focused()
  local selected_tag = s.selected_tag
  local noempty_tags = tag_helpers.noempty_list(s)
  local target_tag_local_idx = tag_helpers.get_idx(selected_tag, noempty_tags, s) + delta
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


function tag_helpers.get_tiled(t)
  local tiled_clients = {}

  -- @TODO: add some fix for sticky clients: DONE?
  if not t then return tiled_clients end
  local s = t.screen
  if s.selected_tags and #s.selected_tags > 1 then
    return s.tiled_clients
  end

  local visible_clients = s.tiled_clients
  local clients_on_tag = t:clients()
  for _, c in pairs(visible_clients) do
    if c.valid
      and c.sticky
    then
      table.insert(tiled_clients, c)
    end
  end
  for _, c in pairs(clients_on_tag) do
    if not c.floating
      and not c.fullscreen
      and not c.maximized_vertical
      and not c.maximized_horizontal
      and not c.minimized
      and not c.sticky
    then
      table.insert(tiled_clients, c)
    end
  end
  return tiled_clients
end


function tag_helpers.get_client_tag(c)
  if c.screen and c.screen.selected_tags then
    for _, sel_tag in ipairs(c.screen.selected_tags) do
      for _, cli_tag in ipairs(c:tags()) do
        if sel_tag.index == cli_tag.index then
          return cli_tag
        end
      end
    end
  end
  return c.first_tag
end


function tag_helpers.tag_idx_to_key(tag_idx)
  if tag_idx == 10 then
    tag_idx = '0'
  elseif tag_idx == 11 then
    tag_idx = '-'
  elseif tag_idx == 12 then
    tag_idx = '='
  elseif tag_idx > 12 then
    tag_idx = 'F'..(tag_idx-12)
  else
    tag_idx = tostring(tag_idx)
  end
  return tag_idx
end


return tag_helpers
