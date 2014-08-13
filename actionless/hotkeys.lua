local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local beautiful = require("beautiful")

local helpers  = require("actionless.helpers")
local markup  = require("actionless.markup")
local decorated_widget  = require("actionless.widgets.common").decorated
local centered_widget  = require("actionless.widgets.common").centered
local mono_preset  = helpers.mono_preset

local hotkeys = {
  bindings = {
    Mod4 = {
    }
  },
  cached_keyboards = {},
  last_modifiers = nil,
  last_visible = false,
}
local keyboard = {
  { 'Escape', '#67', '#68', '#69', '#70', '#71', '#72', '#73', '#74', '#75', '#76', '#95', '#96', 'Home', 'End'},
  { '`', '#10', '#11', '#12', '#13', '#14', '#15', '#16', '#17', '#18', '#19', '#20', '#21', 'Insert', 'Delete' },
  { 'Tab',  'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', 'Backspace'  },
  { 'Caps',  'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'", '\\', 'Return' },
  { 'Shift',  'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 'Next', 'Up' , 'Prior' },
  { 'Fn', 'Control', 'Mod4', 'Mod1', '    ','space', '         ', 'Alt Gr', 'Print', 'Control', 'Left', 'Down', 'Right'},
}
local keyboard_labels = {
  { 'Esc', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12', 'Home', 'End'},
  { '~', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 'Insert', 'Delete'},
  { 'Tab',  'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']',  'Backspace' },
  { 'Caps',  'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'", '\\', 'Enter' },
  { 'Shift',  'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '?', 'PgUp', 'Up' , 'PgDn' },
  { 'Fn', 'Ctrl', 'Super', 'Alt', '    ','Space', '            ', 'Alt Gr', 'PrtScr', 'Ctrl', 'Left', 'Down', 'Right'},
}

function get_mod_table_name(modifiers)
  table.sort(modifiers)
  return table.concat(modifiers)
end


local function new_keybutton(key, modifiers, key_label)
  local obj = {}
  
  local comment = hotkeys.bindings[get_mod_table_name(modifiers)][key]

  local key_widget = wibox.widget.textbox()
  key_widget:set_markup(markup.big(
      key_label
  ))
  local comment_widget = wibox.widget.textbox()
  comment_widget:set_text(
      comment
      and helpers.multiline_limit(comment, 10)
      or string.rep(' ', 10)
  )
  comment_widget:set_font("monospace 8")
  local layout = wibox.layout.fixed.vertical()
  layout:add(key_widget)
  layout:add(comment_widget)
  local padding = wibox.layout.margin()
  padding:set_widget(layout)
  padding:set_margins(5)
  local background = wibox.widget.background()
  background:set_widget(padding)
  if comment then
    background:set_bg(beautiful.theme)
    background:set_fg(beautiful.bg)
  end
  local margin = wibox.layout.margin()
  margin:set_widget(background)
  margin:set_margins(5)

  setmetatable(obj,       { __index = margin })
  return obj
end


function init_keyboard(modifiers)
    local layout = wibox.layout.fixed.vertical()
    local row_layout
    for i1,row in ipairs(keyboard) do
      row_layout = wibox.layout.fixed.horizontal()
      for i2,key in ipairs(row) do
        row_layout:add(new_keybutton(key, modifiers, keyboard_labels[i1][i2]))
      end
      layout:add(row_layout)
    end
    return layout
end


function init_popup()
  local scr = helpers.get_current_screen()
  local scrgeom = screen[scr].workarea
  local width = 1400
  local height = 600
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
    comment = "Show this popup"
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
