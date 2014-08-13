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
  }
}
local popup
local bindings = hotkeys.bindings


function get_mod_table_name(modifiers)
  table.sort(modifiers)
  return table.concat(modifiers)
end


local keyboard = {
  {'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', '['},
}


function init_keyboard()

    local layout = wibox.layout.align.horizontal()
end


function init_popup()
    local mywibox = wibox({})
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

    local lmargin = wibox.layout.margin(
        wibox.widget.textbox(''),
        sg['lmargin'], 0,
        sg['tmargin'], sg['bmargin']
    )
    local rmargin = wibox.layout.margin(
        wibox.widget.textbox(''),
        0, sg['rmargin'],
        sg['tmargin'], sg['bmargin']
    )
    local layout = wibox.layout.align.horizontal()
    layout:set_left(lmargin)
    layout:set_middle(flex_layout)
    layout:set_right(rmargin)

    mywibox:set_widget(layout)
    local width = 380 + sg.lmargin + sg.rmargin
    local height = 380 + sg.tmargin + sg.bmargin

    -- Set position and size
    mywibox.visible = false
    mywibox:geometry({
      x = sg.x or systray_toggle.scrgeom.x,
      y = sg.y or systray_toggle.scrgeom.y,
      height = height,
      width = width
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
  local line
  for k, v in pairs(bindings[mod_table]) do
    line = string.format("%12s",k) .. "  " .. v .. "\n"
    output = output .. line
  end
  hotkeys.popup_content:set_markup(markup.small(output))
  hotkeys.popup.visible = not hotkeys.popup.visible
end

return hotkeys
