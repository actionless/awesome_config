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
  local nothing  = common.constraint({ width=0, })

  local apw = wibox.layout.fixed.horizontal(
    common.panel_shape(
      common.constraint({
        widget=loaded_widgets.volume,
        width=dpi(120),
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
    local right_margin = common.constraint({ width=beautiful.panel_padding_bottom, })
    right_margin:buttons(loaded_widgets.systray_toggle._buttons_table)
    local iseparator  = wibox.container.background(separator, beautiful.panel_widget_bg)
    local right_layout = wibox.widget{
      layout = wibox.layout.align.horizontal,
      separator,
      {
        layout = wibox.layout.flex.horizontal,
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
          and common.panel_shape(loaded_widgets.systray_toggle)
          or common.constraint({ width=beautiful.panel_padding_bottom, }),
        right_margin or nothing,
      }
    }


    -- PANEL LAYOUT
    local layout = wibox.layout.align.horizontal(
      left_layout,
      center_layout,
      right_layout
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
