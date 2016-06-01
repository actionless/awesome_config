local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local awful = require("awful")

local helpers = require("actionless.helpers")
local widgets = require("actionless.widgets")
local common = widgets.common


local toolbar = {}


function toolbar.init(awesome_context)
  local loaded_widgets = awesome_context.widgets

  -- Separators
  local sep = common.constraint({ width=dpi(2), })
  local separator  = common.constraint({ width=dpi(8), })
  local iseparator  = wibox.container.background(separator, beautiful.panel_widget_bg)

  awesome_context.topwibox_layout_fallback = {}
  -- Create a wibox for each screen and add it
  awful.screen.connect_for_each_screen(function(s)
    local si = s.index

    local wheel_binding = awful.util.table.join(
      awful.button({		}, 5, function(_)
        helpers.tag_view_noempty(1, s)
      end),
      awful.button({		}, 4, function(_)
        helpers.tag_view_noempty(-1, s)
      end)
    )


    -- LEFT side
    --beautiful.panel_tasklist and make_separator('arrr', {fg=beautiful.panel_tasklist}
    local left_margin = awful.util.table.clone(separator)
    --left_margin:buttons(loaded_widgets.screen[si].manage_client.buttons())
    local left_layout = wibox.layout.fixed.horizontal(
      left_margin,
      common.panel_shape(loaded_widgets.screen[si].manage_client),
      sep,
      loaded_widgets.screen[si].promptbox,
      sep,
      sep,
      loaded_widgets.kbd,
      sep,
      loaded_widgets.screen[si].tasklist,
      separator
    )
    left_layout:buttons(wheel_binding)


    -- CENTER
    local center_layout = common.panel_shape(loaded_widgets.screen[si].taglist)
    center_layout:buttons(wheel_binding)


    -- RIGHT side
    --

    local right_layout_left = wibox.layout.fixed.horizontal(
      loaded_widgets.music
    )

    local volume_layout = common.panel_shape(
      common.constraint({
        widget=loaded_widgets.volume,
        width=dpi(120),
      })
    )

    local right_layout_right = wibox.layout.fixed.horizontal(
      volume_layout,
      separator
    )

    local indicators_layout = wibox.layout.fixed.horizontal(
      iseparator,
      iseparator,
      loaded_widgets.mem,
      iseparator,
      iseparator,
      loaded_widgets.cpu,
      iseparator,
      iseparator
    )
    if loaded_widgets.temp then
      indicators_layout:add(loaded_widgets.temp)
    end
    if loaded_widgets.bat then
      indicators_layout:add(loaded_widgets.bat)
    end
    indicators_layout = common.panel_shape(indicators_layout)

    right_layout_right:add(
      indicators_layout,
      separator,
      separator,
      loaded_widgets.textclock,
      separator,
      sep,
      sep,
      loaded_widgets.screen[si].layoutbox,
      separator,
      sep,
      si==1 and loaded_widgets.systray_toggle or separator
    )

    local right_layout = wibox.layout.align.horizontal(
        wibox.layout.fixed.horizontal(),
        right_layout_left,
        right_layout_right
    )
    --right_layout:set_expand('none')


    -- TOOLBAR
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

    awesome_context.topwibox_layout_fallback[si] = layout  -- this one!

    awesome_context.topwibox[si]:set_widget(
      awesome_context.topwibox_layout_fallback[si]
    )
  end)

end
return toolbar
