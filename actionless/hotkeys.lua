local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local beautiful = require("beautiful")

local markup  = require("actionless.markup")
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
  {'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', '['},
}
local bindings = hotkeys.bindings

function get_mod_table_name(modifiers)
  table.sort(modifiers)
  return table.concat(modifiers)
end


local new_keybutton = function () end


function init_keyboard()
    local layout
    for i1,row in ipairs(keyboard) do
      local layout = wibox.layout.align.horizontal()
      for i2,key in ipairs(keyboard) do
        naughty.notify({text=key})
      end
    end
end


function init_popup()
    local mywibox = wibox({
      border_width = beautiful.border_width,
      border_color = beautiful.error
    })
    mywibox.ontop = true
    mywibox.opacity = beautiful.notification_opacity

    local widget = wibox.widget.textbox('test\ntest\ntest\ntest')
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
    local lmargin_widget = wibox.layout.margin(
        wibox.widget.textbox(''),
        sg['lmargin'], 0,
        sg['tmargin'], sg['bmargin']
    )
    local rmargin_widget = wibox.layout.margin(
        wibox.widget.textbox(''),
        0, sg['rmargin'],
        sg['tmargin'], sg['bmargin']
    )
    local layout = wibox.layout.align.horizontal()
    layout:set_left(lmargin_widget)
    layout:set_middle(flex_layout)
    layout:set_right(rmargin_widget)

    mywibox:set_widget(layout)
    local width = 380 + sg.lmargin + sg.rmargin
    local height = 380 + sg.tmargin + sg.bmargin

    -- Set position and size
    mywibox.visible = false
    mywibox:geometry({
      x = sg.x or systray_toggle.scrgeom.x,
      y = sg.y or systray_toggle.scrgeom.y,
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
  local output = ''
  for k, v in pairs(bindings[mod_table]) do
    output = output .. string.format("%12s",k) .. "  " .. v .. "\n"
  end
  if hotkeys.last_visible == hotkeys.popup.visible and
    (hotkeys.last_modifiers == modifiers or not hotkeys.popup.visible)
  then
      hotkeys.popup.visible = not hotkeys.popup.visible
  end
  if hotkeys.last_modifiers ~= modifiers then 
    hotkeys.popup_content:set_markup(markup.small(output))
  end
  hotkeys.last_visible = hotkeys.popup.visible
  hotkeys.last_modifiers = modifiers
end

return hotkeys
