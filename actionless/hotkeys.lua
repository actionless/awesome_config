local capi = { screen = screen }
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local beautiful = require("beautiful")

local helpers  = require("actionless.helpers")
local markup  = require("actionless.markup")
local common_widgets = require("actionless.widgets.common")
local decorated_widget = common_widgets.decorated
local centered_widget  = common_widgets.centered
local bordered_widget  = common_widgets.bordered

local hotkeys = {
  bindings = {
    Mod4 = {
    }
  },
  cached_keyboards = {},
  last_modifiers = nil,
  last_visible = false,
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
  { 'Fn', 'Control', 'Mod4', 'Mod1', '    ','space', '         ', 'Alt Gr', 'Print', 'Control', 'Left', 'Down', 'Right'},
}
local KEYBOARD_LABELS = {
  { 'Esc', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12', 'Home', 'End'},
  { '~', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 'Insert', 'Delete'},
  { 'Tab',  'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']',  'Backspace' },
  { 'Caps',  'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'", '\\', 'Enter' },
  { 'Shift',  'z', 'x', 'c', 'v', 'b', 'n', 'm', '&lt;', '&gt;', '?', 'PgUp', 'Up' , 'PgDn' },
  { 'Fn', 'Ctrl', 'Super', 'Alt', '    ','Space', '            ', 'Alt Gr', 'PrtScr', 'Ctrl', 'Left', 'Down', 'Right'},
}

local function get_mod_table_name(modifiers)
  table.sort(modifiers)
  return table.concat(modifiers)
end


local function new_keybutton(key_label, comment)
  local obj = {}

  local letter_widget = wibox.widget.textbox()
  letter_widget:set_markup(markup.big(
      key_label
  ))
  local comment_widget = wibox.widget.textbox()
  comment_widget:set_font(helpers.font .. " " .. APPEARANCE.comment_font_size)
  comment_widget:set_text(
      comment
      and helpers.multiline_limit(comment, APPEARANCE.comment_width_chars)
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

  if comment then
    button_widget:set_bg(beautiful.theme)
    button_widget:set_fg(beautiful.bg)
  end

  setmetatable(obj, { __index = button_widget })
  return obj
end


local function init_keyboard(modifiers)
  local modifiers_table_name = get_mod_table_name(modifiers)
  local keyboard_layout = wibox.layout.fixed.vertical()
  for i1,row in ipairs(KEYBOARD) do
    local row_layout = wibox.layout.fixed.horizontal()
    for i2,key in ipairs(row) do
      local comment = hotkeys.bindings[modifiers_table_name][key]
      row_layout:add(new_keybutton(
        KEYBOARD_LABELS[i1][i2], comment
      ))
    end
    keyboard_layout:add(row_layout)
  end
  return keyboard_layout
end


local function init_popup()
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

  mywibox.visible = false
  mywibox:geometry({
    x = x,
    y = y,
    height = height,
    width = width,
  })

  return mywibox, content_widget
end


function hotkeys.init(awesome_context)
  hotkeys.modkey = awesome_context.modkey
  hotkeys.altkey = awesome_context.altkey
  hotkeys.popup, hotkeys.popup_content = init_popup()
end


function hotkeys.key(modifiers, key, key_press_function, key_release_function,
                     comment)
  if key_press_function == 'show_help' then
    key_press_function = function()
      hotkeys.show_by_modifiers(modifiers)
    end
    comment = "show this help"
  end

  local mod_table = get_mod_table_name(modifiers)
  if not hotkeys.bindings[mod_table] then hotkeys.bindings[mod_table] = {} end
  hotkeys.bindings[mod_table][key] = comment
  modifiers = modifiers or {}

  return awful.key(modifiers, key, key_press_function, key_release_function)
end

function hotkeys.on(modifiers, key, key_press_function, comment)
  return hotkeys.key(modifiers, key, key_press_function, nil, comment)
end

function hotkeys.show_by_modifiers(modifiers)
  if hotkeys.last_visible == hotkeys.popup.visible and
    (hotkeys.last_modifiers == modifiers or not hotkeys.popup.visible)
  then
      hotkeys.popup.visible = not hotkeys.popup.visible
  end
  if hotkeys.last_modifiers ~= modifiers then
    local mod_table = get_mod_table_name(modifiers)
    if not hotkeys.cached_keyboards[mod_table] then
      hotkeys.cached_keyboards[mod_table] = init_keyboard(modifiers)
    end
    hotkeys.popup_content:set_widget(hotkeys.cached_keyboards[mod_table])
  end
  hotkeys.last_visible = hotkeys.popup.visible
  hotkeys.last_modifiers = modifiers
end

return hotkeys
