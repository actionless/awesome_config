--[[
     Licensed under GNU General Public License v2
      * (c) 2014  Yauheni Kirylau
--]]

local capi = {
  screen = screen,
  client = client,
  keygrabber = keygrabber,
}
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local helpers = require("actionless.helpers")
local h_table = require("actionless.table")
local markup = require("actionless.markup")
local bordered_widget = require("actionless.widgets.common").bordered

local hotkeys = {
  appearance = {
    width = 1400,
    height = 650,
    key_padding = 5,
    key_margin = 5,
    comment_font_size = 8,
    hide_on_key_release = false,
    special_button_bg = "#333333",
    special_button_fg = "#000000",
    default_button_bg = beautiful.theme,
    alt_fg = beautiful.color and beautiful.color[0] or beautiful.bg,
  },
  bindings = {
    --[[
    Mod4 = {
      Space = {
        comment = 'app launcher',
        group = 5
      },
    },
    --]]
  },
  cached_keyboards = {},
  last_modifiers = nil,
  last_groups = nil,
  last_visible = false,
  popup = {
    visible = false,
  },
  groups = {
    pressed={
      name="hold",
      color=beautiful.color and beautiful.color[2] or "#aaaabb",
      modifiers={}
    }
  },
}
local APPEARANCE = hotkeys.appearance

local KEYBOARD = {
  { 'Escape', '#67', '#68', '#69', '#70', '#71', '#72', '#73', '#74', '#75', '#76', '#95', '#96', 'Home', 'End'},
  { '`', '#10', '#11', '#12', '#13', '#14', '#15', '#16', '#17', '#18', '#19', '#20', '#21', 'Insert', 'Delete' },
  { 'Tab', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', 'Backspace' },
  { 'Caps', 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'", '\\', 'Return' },
  { 'Shift', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 'Next', 'Up' , 'Prior' },
  { 'Fn', 'Control', 'Mod4', 'Mod1', '', 'space', '', '', '#108', 'Print', 'Control', 'Left', 'Down', 'Right'},
}
local LABELS = {
  Mod4="Super",
  Mod1="Alt",
--  Control="Ctrl"
}
-- @TODO: remove this table
local KEYBOARD_LABELS = {
  { 'Esc', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12', 'Home', 'End'},
  { '~', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 'Ins', 'Del'},
  { 'Tab', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', 'BackSpc' },
  { 'Caps', 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'", '\\', 'Enter' },
  { 'Shift', 'z', 'x', 'c', 'v', 'b', 'n', 'm', '&lt;', '&gt;', '?', 'PgUp', 'Up' , 'PgDn' },
  { 'Fn', 'Ctrl', 'Super', 'Alt', '', 'Space', '', '', 'Alt Gr', 'PrScr', 'Ctrl', 'Left', 'Down', 'Right'},
}
local SPECIAL_KEYBUTTONS = {
  'Esc',
  'Tab',
  'Caps',
  'Shift',
  'Ctrl',
  'Super',
  'Alt',
  'Alt G',
  'PrScr',
  'PgUp',
  'PgDn',
  'BackSpc',
  'Enter',
  'Ins',
  'Del',
  'Home',
  'End',
  'F1',
  'F2',
  'F3',
  'F4',
  'F5',
  'F6',
  'F7',
  'F8',
  'F9',
  'F10',
  'F11',
  'F12',
}

local MODIFIERS = {
  Control = '#37'
}

local function join_modifiers(modifiers)
  if #modifiers<1 then return "no modifiers" end
  local result = {}
  for _, modifier in pairs(modifiers) do
    table.insert(result, LABELS[modifier] or modifier)
  end
  table.sort(result, function(a,b) return a>b end)
  return table.concat(result, '+')
end

-------------------------------------------------------------------------------
--{{
local function create_wibox(modifiers, available_groups)
  table.sort(available_groups)

  local function create_keybutton(key_label, comment, key_group)
    local obj = {}
        local letter_widget = wibox.widget.textbox()
        letter_widget:set_markup(markup.big(key_label))
        local comment_widget = wibox.widget.textbox()
        comment_widget:set_font(helpers.font .. " " .. APPEARANCE.comment_font_size)
        comment_widget:set_text(comment or '')
      local button_layout = wibox.layout.fixed.vertical()
      button_layout:add(letter_widget)
      button_layout:add(comment_widget)
    local button_widget = bordered_widget(
      button_layout, {
        padding = APPEARANCE.key_padding,
        margin = APPEARANCE.key_margin,
    })
    local key_group_bg = nil
    local key_group_fg = beautiful.bg
    if key_group and hotkeys.groups[key_group] then
      key_group_bg = hotkeys.groups[key_group].color
    elseif comment then
      key_group_bg = APPEARANCE.default_button_bg
    elseif h_table.contains(SPECIAL_KEYBUTTONS, key_label) then
      key_group_bg = APPEARANCE.special_button_bg
      key_group_fg = APPEARANCE.special_button_fg
    end
    if key_group_bg then
      button_widget:set_bg(key_group_bg)
      button_widget:set_fg(key_group_fg)
    end
    setmetatable(obj, { __index = button_widget })
    return obj
  end

  local function create_legend(active_modifiers_string, available_groups, active_groups)

    local function create_layout_for_group(group_id, group_is_active, active_modifiers_string)
      local group = hotkeys.groups[group_id]
      local group_layout = wibox.layout.fixed.vertical()
      group_layout:add(
        wibox.widget.textbox(
          group_is_active
          and markup.fg(
            APPEARANCE.alt_fg,
            markup.bg(group.color, group.name))
          or markup.fg(group.color, group.name)
      ))
      if group.modifiers then
        for _, modifier in pairs(group.modifiers) do
          group_layout:add(
            wibox.widget.textbox(
              modifier == active_modifiers_string
              and markup.fg(
                APPEARANCE.alt_fg,
                markup.bg(group.color, modifier))
              or modifier
          ))
        end
      end
      return group_layout
    end

    local legend_layout = wibox.layout.flex.horizontal()
    for _, group_id in ipairs(available_groups) do
      local group_is_active = h_table.contains(active_groups, group_id)
      legend_layout:add(create_layout_for_group(group_id, group_is_active, active_modifiers_string))
    end
    return legend_layout
  end

  local function create_keyboard(active_modifiers, available_groups)
    local active_modifiers_string = join_modifiers(active_modifiers)
    local hotkeys_for_current_modifier = hotkeys.bindings[active_modifiers_string]
    for _, modifier in ipairs(active_modifiers) do
      hotkeys_for_current_modifier[modifier] = {
        comment="pressed",
        group="pressed",
      }
    end
    local keyboard_layout = wibox.layout.flex.vertical()
    local active_groups = {}
    for i1, row in ipairs(KEYBOARD) do
      local row_layout = wibox.layout.flex.horizontal()
      for i2, key in ipairs(row) do
        local hotkey_record = hotkeys_for_current_modifier[key]
        if hotkey_record
          and hotkey_record.group
          and h_table.contains(available_groups, hotkey_record.group)
        then
          row_layout:add(create_keybutton(
            KEYBOARD_LABELS[i1][i2], hotkey_record.comment, hotkey_record.group
          ))
          h_table.list_merge(active_groups, {hotkey_record.group})
        else
          row_layout:add(create_keybutton(KEYBOARD_LABELS[i1][i2], nil, nil))
        end
      end
      keyboard_layout:add(row_layout)
    end
    keyboard_layout:add(
      create_legend(active_modifiers_string, available_groups, active_groups))
    return keyboard_layout
  end

  local scrgeom = capi.screen[helpers.get_current_screen()].workarea
  local width = APPEARANCE.width
  local height = APPEARANCE.height
  local x = (scrgeom.width - width) / 2
  local y = (scrgeom.height - height) / 2
  local mywibox = wibox({
    ontop = true,
    opacity = beautiful.notification_opacity,
  })
  mywibox:geometry({
    x = x,
    y = y,
    height = height,
    width = width,
  })
  mywibox:set_widget(
    bordered_widget(
      create_keyboard(modifiers, available_groups),
      {
        padding = APPEARANCE.key_padding,
        margin = APPEARANCE.key_margin,
      }
    )
  )
  return mywibox
end
--}}
-------------------------------------------------------------------------------


function hotkeys.add_groups(groups)
  h_table.merge(hotkeys.groups, groups)
end


function hotkeys.key(modifiers, key, key_press_function, key_release_function,
                     comment, key_group)

  if key_press_function == 'show_help' then
    -- {{ that needed if popup is called by modifier itself:
    local modifiers_to_show = h_table.deepcopy(modifiers)
    if h_table.contains_key(MODIFIERS, key) then
      table.insert(modifiers_to_show, key)
      key = MODIFIERS[key]
    end
    -- }}
    key_press_function = function()
      hotkeys.show_by_modifiers(modifiers_to_show)
    end
    comment = "show this help"
  end

  local mod_table = join_modifiers(modifiers)
  if not hotkeys.bindings[mod_table] then hotkeys.bindings[mod_table] = {} end
  hotkeys.bindings[mod_table][key] = {
    comment=comment,
    group=key_group,
  }
  if key_group then
    hotkeys.groups[key_group].modifiers = h_table.list_merge(hotkeys.groups[key_group].modifiers, {mod_table})
  end

  if key_press_function or key_release_function then
    return awful.key(modifiers, key, key_press_function, key_release_function)
  end
end


function hotkeys.on(modifiers, key, key_press_function, comment, key_group)
  return hotkeys.key(modifiers, key, key_press_function, nil, comment, key_group)
end


function hotkeys.show_by_modifiers(modifiers)
  local client_name
  if capi.client.focus then
    client_name = capi.client.focus.name
  else
    client_name = 'no client'
  end
  local available_groups = {}
  for group_name, group in pairs(hotkeys.groups) do
    if not group.client_name
      or (group.client_name and client_name:match(group.client_name))
    then
      table.insert(available_groups, group_name)
    end
  end
  local joined_groups = join_modifiers(available_groups)
  local mod_table = join_modifiers(modifiers)

  if hotkeys.last_modifiers ~= mod_table
    or hotkeys.last_groups ~= joined_groups
  then
    if not hotkeys.cached_keyboards[mod_table] then
      hotkeys.cached_keyboards[mod_table] = {}
    end
    if not hotkeys.cached_keyboards[mod_table][joined_groups] then
      hotkeys.cached_keyboards[mod_table][joined_groups] = create_wibox(modifiers, available_groups)
    end
    -- old-popup -- is to prevent flickering when switching between them:
    local old_popup = hotkeys.popup
    hotkeys.popup = hotkeys.cached_keyboards[mod_table][joined_groups]
    hotkeys.popup.visible = true
    old_popup.visible = false
  else
    hotkeys.popup.visible = not hotkeys.popup.visible
  end

  hotkeys.last_groups = joined_groups
  hotkeys.last_visible = hotkeys.popup.visible
  hotkeys.last_modifiers = mod_table

  local function hide_popup()
    capi.keygrabber.stop()
    hotkeys.popup.visible = false
    hotkeys.last_visible = false
  end

  capi.keygrabber.run(function(_, key, event)
    if APPEARANCE.hide_on_key_release then
      if event == "release" then hide_popup() end
    else
      if event == "release" then return end
      if key then hide_popup() end
    end
  end)
end

return hotkeys
