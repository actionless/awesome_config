local capi = { screen = screen }
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local helpers = require("actionless.helpers")
local h_table = require("actionless.table")
local h_string = require("actionless.string")
local markup = require("actionless.markup")
local common_widgets = require("actionless.widgets.common")
local centered_widget = common_widgets.centered
local bordered_widget = common_widgets.bordered

local hotkeys = {
  bindings = {
    Mod4 = {
    }
  },
  cached_keyboards = {},
  last_modifiers = nil,
  last_visible = false,
  popup = {
    visible = false,
  }
}
local APPEARANCE = {
  width = 1400,
  height = 600,
  key_padding = 5,
  key_margin = 5,
  comment_font_size = 8,
  comment_width_chars = 10
}
local KEYBOARD = {
  { 'Escape', '#67', '#68', '#69', '#70', '#71', '#72', '#73', '#74', '#75', '#76', '#95', '#96', 'Home', 'End'},
  { '`', '#10', '#11', '#12', '#13', '#14', '#15', '#16', '#17', '#18', '#19', '#20', '#21', 'Insert', 'Delete' },
  { 'Tab',  'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', 'Backspace'  },
  { 'Caps',  'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'", '\\', 'Return' },
  { 'Shift',  'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 'Next', 'Up' , 'Prior' },
  { 'Fn', 'Control', 'Mod4', 'Mod1', '    ', 'space', '   ', '    ', 'Alt Gr', 'Print', 'Control', 'Left', 'Down', 'Right'},
}
local KEYBOARD_LABELS = {
  { 'Esc', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12', 'Home', 'End'},
  { '~', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 'Ins', 'Del'},
  { 'Tab',  'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']',   'Backspace    ' },
  { 'Caps',  'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'", '\\', 'Enter        ' },
  { 'Shift',  'z', 'x', 'c', 'v', 'b', 'n', 'm', '&lt;', '&gt;', '?', 'PgUp', 'Up' , 'PgDn' },
  { 'Fn', 'Ctrl', 'Super', 'Alt', '    ', 'Space', '    ', '    ', 'Alt G', 'PrScr', 'Ctrl', 'Left', 'Down', 'Right'},
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
  'Backspace    ',
  'Enter        ',
  'Ins',
  'Del',
  'Home',
  'End'
}
local MODIFIERS = {
  Control = '#37'
}

local function keyname_to_keycode(keyname)
  for k, v in pairs(MODIFIERS) do
    if k == keyname then return v end
  end
  return nil
end

local function get_mod_table_name(modifiers)
  local copied = h_table.deepcopy(modifiers)
  table.sort(copied)
  return table.concat(copied)
end

local function human_readable_modifiers(modifiers)
  return table.concat(modifiers, '+')
end


local function new_keybutton(key_label, comment, key_group)
  local obj = {}

  local letter_widget = wibox.widget.textbox()
  letter_widget:set_markup(markup.big(
      key_label
  ))
  local comment_widget = wibox.widget.textbox()
  comment_widget:set_font(helpers.font .. " " .. APPEARANCE.comment_font_size)
  comment_widget:set_text(
      comment
      and h_string.multiline_limit(comment, APPEARANCE.comment_width_chars)
      or string.rep(" ", APPEARANCE.comment_width_chars)
  )

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
  if key_group then
    key_group_bg = beautiful.color[key_group]
  elseif comment then
    key_group_bg = beautiful.theme
  elseif h_table.contains(SPECIAL_KEYBUTTONS, key_label) then
    key_group_bg = "#333333"
    key_group_fg = "#000000"
  end
  if key_group_bg then
    button_widget:set_bg(key_group_bg)
    button_widget:set_fg(key_group_fg)
  end

  setmetatable(obj, { __index = button_widget })
  return obj
end


local function init_keyboard(modifiers)
  local modifiers_table_name = get_mod_table_name(modifiers)
  local keyboard_layout = wibox.layout.fixed.vertical()
  local modifiers_title_row = wibox.layout.fixed.horizontal()
  modifiers_title_row:add(wibox.widget.textbox(
    markup.big(
      human_readable_modifiers(modifiers) .. '+__'
  )))
  keyboard_layout:add(modifiers_title_row)
  for i1,row in ipairs(KEYBOARD) do
    local row_layout = wibox.layout.fixed.horizontal()
    for i2,key in ipairs(row) do
      local hotkey_record = hotkeys.bindings[modifiers_table_name][key] or
                            { comment=nil, group=nil}
      row_layout:add(new_keybutton(
        KEYBOARD_LABELS[i1][i2], hotkey_record.comment, hotkey_record.group
      ))
    end
    keyboard_layout:add(row_layout)
  end
  return keyboard_layout
end


local function init_popup(modifiers)
  local scrgeom = capi.screen[helpers.get_current_screen()].workarea
  local width = APPEARANCE.width
  local height = APPEARANCE.height
  local x = (scrgeom.width - width)/2
  local y = (scrgeom.height - height)/2

  local mywibox = wibox({})
  mywibox.ontop = true
  mywibox.opacity = beautiful.notification_opacity

  local content_widget = wibox.widget.background()
  mywibox:set_widget(centered_widget(content_widget))
  content_widget:set_widget(init_keyboard(modifiers))

  mywibox.visible = false
  mywibox:geometry({
    x = x,
    y = y,
    height = height,
    width = width,
  })

  return mywibox
end


function hotkeys.init(awesome_context)
  hotkeys.modkey = awesome_context.modkey
  hotkeys.altkey = awesome_context.altkey
end


function hotkeys.key(modifiers, key, key_press_function, key_release_function,
                     comment, key_group)
  local patched_key_press_function
  if key_press_function == 'show_help' then
    local modifiers_to_show = h_table.deepcopy(modifiers)
    if h_table.contains_key(MODIFIERS, key) then
      table.insert(modifiers_to_show, key)
      key = keyname_to_keycode(key)
    end
    patched_key_press_function = function()
      hotkeys.show_by_modifiers(modifiers_to_show)
    end
    comment = "show this help"
  else
    patched_key_press_function = function(...)
      hotkeys.popup.visible = false
      hotkeys.last_visible = false
      key_press_function(...)
    end
  end

  local mod_table = get_mod_table_name(modifiers)
  if not hotkeys.bindings[mod_table] then hotkeys.bindings[mod_table] = {} end
  hotkeys.bindings[mod_table][key] = {
    comment=comment,
    group=key_group,
  }
  modifiers = modifiers or {}

  return awful.key(modifiers, key, patched_key_press_function, key_release_function)
end

function hotkeys.on(modifiers, key, key_press_function, comment, key_group)
  return hotkeys.key(modifiers, key, key_press_function, nil, comment, key_group)
end

function hotkeys.show_by_modifiers(modifiers)
  if hotkeys.last_modifiers ~= modifiers then
    local mod_table = get_mod_table_name(modifiers)
    if not hotkeys.cached_keyboards[mod_table] then
      hotkeys.cached_keyboards[mod_table] = init_popup(modifiers)
    end
    hotkeys.popup.visible=false
    hotkeys.popup = hotkeys.cached_keyboards[mod_table]
    hotkeys.popup.visible=true
  else
    hotkeys.popup.visible = not hotkeys.popup.visible
  end
  hotkeys.last_visible = hotkeys.popup.visible
  hotkeys.last_modifiers = modifiers
end

return hotkeys
