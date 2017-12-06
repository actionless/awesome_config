local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local common = require("actionless.widgets.common")

--local assets = require("config.lcars_assets")


local toolbar = {}


function toolbar.init(awesome_context)
  local loaded_widgets = awesome_context.widgets

  local topwibox_layout = {}
  local topwibox_toplayout = {}

  -- Separators
  local separator  = common.constraint({ width=dpi(8), })
  local h_sep = common.constraint({ width=dpi(7) })
  local border_separator = common.constraint({ width = beautiful.panel_padding_bottom })

  awful.screen.connect_for_each_screen(function(s)
    local si = s.index

    local top_panel_left_margin = wibox.container.background(
      common.constraint({width=dpi(100)}),
      beautiful.panel_widget_bg
    )
    -- TOP PANEL:
    local top_panel_toplayout = wibox.layout.align.horizontal(
      wibox.layout.fixed.horizontal(
        top_panel_left_margin,
        top_panel_left_margin
      ),
      nil,
      nil
    )
    local top_panel_left_margin_to_compensate_left_wibox_rounding = wibox.container.background(
      common.constraint({width=beautiful.left_panel_width/2}),
      beautiful.panel_bg
    )
    local top_panel_left_margin_to_compensate_left_wibox = wibox.container.background(
      common.constraint({width=beautiful.left_panel_width/2}),
      beautiful.panel_widget_bg
    )
    local top_panel_bottomlayout = wibox.layout.align.horizontal(
      wibox.layout.fixed.horizontal(
        top_panel_left_margin_to_compensate_left_wibox_rounding,
        top_panel_left_margin_to_compensate_left_wibox,
        top_panel_left_margin,
        --loaded_widgets.screen[si].taglist,
        top_panel_left_margin,
        border_separator,
        loaded_widgets.screen[si].manage_client,
        separator,
        loaded_widgets.kbd,
        separator,
        loaded_widgets.screen[si].promptbox,
        separator
      ),
      loaded_widgets.screen[si].tasklist,
      nil
    )

    -- add sneaky_toggle on first screen
    if si == 1 then
      local fancy_volume_widget = common.constraint({
        widget=wibox.layout.fixed.vertical(
          common.constraint({
            widget=loaded_widgets.volume,
            height=dpi(8),
          }),
          common.constraint({
            widget=wibox.container.background(wibox.widget.textbox(), beautiful.apw_fg_color),
            height=dpi(10),
          })
        ),
        width=dpi(400)
      })
      fancy_volume_widget:buttons(loaded_widgets.volume:buttons())
      top_panel_bottomlayout:set_third(
        wibox.layout.fixed.horizontal(
          h_sep,
          fancy_volume_widget,
          h_sep,
          common.constraint({
            widget=loaded_widgets.music,
            --height=dpi(80),
            width=dpi(700)
          })
          --loaded_widgets.systray_toggle,
        )
      )
    end

    topwibox_toplayout[si] =
      wibox.layout.fixed.vertical(
        common.constraint({height=beautiful.panel_padding_bottom}),
        common.constraint({
          height=beautiful.basic_panel_height,
          widget = top_panel_toplayout,
        }),
        common.constraint({height=beautiful.panel_padding_bottom})
      )

    local top_panel_layout = wibox.layout.align.vertical(
      nil,
      nil,
      wibox.layout.fixed.vertical(
        common.constraint({
          height=beautiful.basic_panel_height,
          widget = top_panel_bottomlayout,
        }),
        common.constraint({height=beautiful.panel_padding_bottom})
      )
    )
    -- add :buttons method
    top_panel_layout = setmetatable(
      top_panel_layout,
      wibox.container.background(top_panel_layout)
    )
    topwibox_layout[si] = top_panel_layout

  end)

  awesome_context.lcars_assets.topwibox_layout = topwibox_layout  -- this one!
  awesome_context.lcars_assets.topwibox_toplayout = topwibox_toplayout

end
return toolbar
