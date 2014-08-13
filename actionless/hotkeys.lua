local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local beautiful = require("beautiful")

local markup  = require("actionless.markup")
local decorated_widget  = require("actionless.widgets.common").decorated
local mono_preset  = require("actionless.helpers").mono_preset

local hotkeys = {
  bindings = {
    Mod4 = {
    }
  },
  last_modifiers = nil,
  last_visible = false,
}
local keyboard = {
  { '`', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 'Backspace' },
  { 'Tab',  'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', '[' },
  { 'Caps',  'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'", '\\' },
  { 'Shift',  'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/' },
}
local bindings = hotkeys.bindings

function get_mod_table_name(modifiers)
  table.sort(modifiers)
  return table.concat(modifiers)
end


local function new_keybutton(key, modifiers)
  local obj = {}
  
  obj.key = key
  obj.comment = hotkeys.bindings[get_mod_table_name(modifiers)][key]

  local key_widget = wibox.widget.textbox()
  key_widget:set_markup(markup.big(obj.key))
  local comment_widget = wibox.widget.textbox()
  comment_widget:set_markup(markup.small(obj.comment))
  local layout = wibox.layout.fixed.vertical()
  layout:add(key_widget)
  layout:add(comment_widget)
  local padding = wibox.layout.margin()
  padding:set_widget(layout)
  padding:set_margins(5)
  local background = wibox.widget.background()
  background:set_widget(padding)
  if obj.comment then
    background:set_bg('#ffdd00')
  end
  local margin = wibox.layout.margin()
  margin:set_widget(background)
  margin:set_margins(5)

  setmetatable(obj,       { __index = margin })
  return obj
end


function init_keyboard(widget, modifiers)
    local layout = wibox.layout.fixed.vertical()
    local row_layout
    for i1,row in ipairs(keyboard) do
      row_layout = wibox.layout.fixed.horizontal()
      for i2,key in ipairs(row) do
        row_layout:add(new_keybutton(key, modifiers))
      end
      layout:add(row_layout)
    end
    return layout
end


function init_popup()
    local mywibox = wibox({
      border_width = beautiful.border_width,
      border_color = beautiful.error
    })
    mywibox.ontop = true
    mywibox.opacity = beautiful.notification_opacity

    local widget = wibox.widget.textbox('placeholder')
    local flex_layout = wibox.layout.flex.horizontal()
    flex_layout:add(widget)

    local sg = {
        x = 350,
        y = 50,
        lmargin = 5,
        rmargin = 5,
        tmargin = 2,
        bmargin = 2,
    }

    mywibox:set_widget(layout)
    local width = 900
    local height = 400

    -- Set position and size
    mywibox.visible = false
    mywibox:geometry({
      x = sg.x,
      y = sg.y,
      height = height,
      width = width,
    })

    return mywibox, widget
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
    key_release_function = function()
      --naughty.destroy(popup)
    end
    comment = "Show this popup"
  end

  local mod_table = get_mod_table_name(modifiers)
  if not bindings[mod_table] then bindings[mod_table] = {} end
  bindings[mod_table][key] = comment
  modifiers = modifiers or {}

  return awful.key(modifiers, key, key_press_function, key_release_function)
end


function hotkeys.show_by_modifiers(modifiers)
  local mod_table = get_mod_table_name(modifiers)
  if hotkeys.last_visible == hotkeys.popup.visible and
    (hotkeys.last_modifiers == modifiers or not hotkeys.popup.visible)
  then
      hotkeys.popup.visible = not hotkeys.popup.visible
  end
  if hotkeys.last_modifiers ~= modifiers then 
    local keyboard = init_keyboard(hotkeys.popup_content, modifiers)
    hotkeys.popup_content:set_markup(markup.small(output))
    hotkeys.popup:set_widget(keyboard)
  end
  hotkeys.last_visible = hotkeys.popup.visible
  hotkeys.last_modifiers = modifiers
end

return hotkeys
