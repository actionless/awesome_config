local beautiful = require("beautiful")
local awful = require("awful")
local wibox = require("wibox")

local common = require("actionless.widgets.common")

local backlight_progressbar = require("actionless.abw")


return function(args)
  args = args or {}
  local presets = args.presets or {64, 75, 100}

  local button_templates = {}
  for _, preset_percent in ipairs(presets) do
    button_templates[#button_templates + 1] = {
      id = 'role_'..tostring(preset_percent),
      widget = wibox.container.background,
      fg = beautiful.panel_widget_fg,
      {
        markup = ' '..tostring(preset_percent)..' ',
        widget = wibox.widget.textbox,
      },
    }
  end
  button_templates.layout = wibox.layout.fixed.horizontal
  button_templates.fill_space = true

  local custom_backlight_widget = wibox.widget{
    {
      widget = wibox.container.background,
      fg = beautiful.panel_widget_fg,
      {
        widget = wibox.widget.textbox,
        markup = args.markup or 'Backlight: ',
      },
    },
    common.panel_widget_shape(backlight_progressbar),
    {
      id = 'buttons',
      widget=wibox.widget(button_templates),
    },
    layout = wibox.layout.align.horizontal,
    fill_space = true,
  }

  local backlight_widget_buttons = custom_backlight_widget:get_children_by_id('buttons')[1]
  local buttons_objects = {}
  for _, backlight_percent in ipairs(presets) do
    local id = tostring(backlight_percent)
    buttons_objects[id] = backlight_widget_buttons:get_children_by_id(
      'role_'..id
    )[1]
    buttons_objects[id]:buttons(awful.util.table.join(
      awful.button({ }, 1, nil, function ()
        backlight_progressbar.SetValue(backlight_percent/100)
        for button_id, button in pairs(buttons_objects) do
          if button_id == id then
            button.bg = beautiful.panel_widget_bg_warning
            button.fg = beautiful.panel_widget_fg_warning
          else
            button.bg = beautiful.panel_widget_bg
            button.fg = beautiful.panel_widget_fg
          end
        end
      end)
    ))
  end

  custom_backlight_widget.progressbar = backlight_progressbar
  for _, method_name in ipairs({'Update', 'Up', 'Down', 'SetValue', 'backend', }) do
    custom_backlight_widget[method_name] = custom_backlight_widget.progressbar[method_name]
  end

  return custom_backlight_widget
end
