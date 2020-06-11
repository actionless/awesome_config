local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local awful = require("awful")
local gmath = require("gears.math")

local tag_helpers = require("actionless.util.tag")
local common = require("actionless.widgets").common


local toolbar = {}


function toolbar.init(awesome_context)
  local loaded_widgets = awesome_context.widgets

  -- Separators
  local separator  = common.constraint({ width=beautiful.panel_widget_spacing, })
  local sep = common.constraint({ width=gmath.round(beautiful.panel_widget_spacing/4) })

  local apw = wibox.layout.fixed.horizontal(
    common.panel_shape(
      common.constraint({
        widget=loaded_widgets.volume,
        width=awesome_context.apw_width or dpi(120),
      })
    ),
    separator
  )

  -- Create a wibox for each screen and add it
  awful.screen.connect_for_each_screen(function(s)
    local si = s.index

    local wheel_binding = awful.util.table.join(
      awful.button({		}, 5, function(_)
        tag_helpers.view_noempty(1, s)
      end),
      awful.button({		}, 4, function(_)
        tag_helpers.view_noempty(-1, s)
      end)
    )


    -- LEFT side
    local left_margin = common.constraint({ width=beautiful.panel_padding_bottom, })
    local manage_client = loaded_widgets.screen[si].manage_client
    left_margin:buttons(manage_client._buttons_table)
    left_margin:connect_signal("mouse::enter", manage_client._on_mouse_enter)
    left_margin:connect_signal("mouse::leave", manage_client._on_mouse_leave)
    local left_layout = wibox.widget{
      layout = wibox.layout.align.horizontal,
      expand = 'inside',
      {
        layout = wibox.layout.fixed.horizontal,
        buttons = wheel_binding,
        left_margin,
        common.panel_shape(manage_client),
        sep,
        loaded_widgets.screen[si].promptbox,
        loaded_widgets.kbd,
        sep
      },
      {
        layout = wibox.container.background,
        buttons = wheel_binding,
        loaded_widgets.screen[si].tasklist,
      },
      {
        layout = wibox.layout.fixed.horizontal,
        {
          layout = wibox.container.background,
          buttons = wheel_binding,
          awesome_context.apw_on_the_left and separator or sep,
        },
        awesome_context.apw_on_the_left and apw,
      },
      {
        layout = wibox.container.background,
        buttons = wheel_binding,
        separator,
      },
    }

    -- CENTER
    local center_layout = common.panel_shape(loaded_widgets.screen[si].taglist)
    center_layout:buttons(wheel_binding)

    -- RIGHT side
    local iseparator  = wibox.container.background(separator, beautiful.panel_widget_bg)
    local right_layout = wibox.widget{
      layout = wibox.layout.align.horizontal,
      separator,
      {
        --layout = wibox.layout.flex.horizontal,
        layout = wibox.layout.fixed.horizontal,
        common.panel_shape(
          loaded_widgets.music,
          {
            border_width = 0,
          }
        )
      },
      {
        layout = wibox.layout.fixed.horizontal,
        separator,
        not awesome_context.apw_on_the_left and apw,
        common.panel_shape(wibox.widget{
          layout = wibox.layout.fixed.horizontal,
          iseparator,
          loaded_widgets.mem,
          loaded_widgets.cpu,
          iseparator,
          loaded_widgets.disk and loaded_widgets.disk,
          loaded_widgets.temp and loaded_widgets.temp,
          loaded_widgets.bat and loaded_widgets.bat,
        }),
        separator,
        loaded_widgets.updates,
        separator,
        loaded_widgets.textclock,
        separator,
        sep,
        sep,
        loaded_widgets.screen[si].layoutbox,
        separator,
        sep,
        si==1
          and loaded_widgets.systray_toggle
          or common.constraint({ width=beautiful.panel_padding_bottom, }),
        loaded_widgets.naughty_counter,
      }
    }


    -- PANEL LAYOUT
    local width = s.geometry.width
    local w3 = width/3
    local layout = wibox.layout.align.horizontal(
      wibox.container.constraint(left_layout, 'max', w3*0.1),
      --left_layout,
      wibox.container.constraint(center_layout, 'max', w3*1.1),
      --center_layout,
      wibox.container.constraint(right_layout, 'max', w3*1.8)
      --right_layout
    )
    layout:set_expand('outside')

    -- panel bottom padding:
    if beautiful.panel_padding_bottom then
      local const = wibox.container.constraint()
      const:set_strategy("exact")
      const:set_height(beautiful.panel_padding_bottom)
      layout = wibox.layout.align.vertical(
        nil,
        layout,
        const
      )
    end

    awesome_context.topwibox_layout[si] = layout  -- this one!

    awesome_context.topwibox[si]:set_widget(
      awesome_context.topwibox_layout[si]
    )
  end)

end
return toolbar
