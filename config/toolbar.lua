local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")

local capi = {
  screen = screen,
  client = client,
}

local widgets = require("actionless.widgets")
local common = require("actionless.widgets.common")

local dpi = require("actionless.xresources").compute_fontsize
local assets = require("config.toolbar_assets")
local h_table = require("utils.table")

local toolbar = {}


function toolbar.init(awesome_context)
  local loaded_widgets = awesome_context.widgets

  -- Separators
  local separator  = common.make_separator(' ')
  local sep_media  = common.make_separator('sq', {fg=beautiful.panel_media})

  local v_sep = wibox.widget.background(
    common.constraint({height=beautiful.panel_padding_bottom}),
    beautiful.panel_bg
  )


  -- Create a wibox for each screen and add it
  local leftwibox = {}
  local topwibox = {}
  local topwibox_layout = {}
  local topwibox_toplayout = {}
  local leftwibox_separator = {}
  local internal_corner_wibox = {}
  local top_internal_corner_wibox = {}
  for s = 1, capi.screen.count() do

    local top_panel_left_margin = wibox.widget.background(
      common.constraint({width=dpi(100)}),
      beautiful.fg
    )
    -- TOP PANEL:
    local top_panel_toplayout = common.align.horizontal(
      common.fixed.horizontal({
        top_panel_left_margin,
        top_panel_left_margin,
      }),
      nil,
      nil
    )
    local top_panel_bottomlayout = common.align.horizontal(
      common.fixed.horizontal({
        top_panel_left_margin,
        loaded_widgets.screen[s].taglist,
        top_panel_left_margin,
        separator,
        loaded_widgets.screen[s].close_button,
        separator,
        loaded_widgets.kbd,
        separator,
        loaded_widgets.screen[s].promptbox,
        separator
      }),
      loaded_widgets.screen[s].tasklist,
      nil
    )
    -- add sneaky_toggle on first screen
    if s == 1 then
      loaded_widgets.systray_toggle = widgets.sneaky_toggle({
          widgets={
            sep_media,
            loaded_widgets.netctl,
            sep_media,
          }, enable_sneaky_tray = true,
      })
      top_panel_bottomlayout:set_third(loaded_widgets.systray_toggle)
    end

    topwibox_toplayout[s] =
      common.fixed.vertical({
        common.constraint({height=beautiful.panel_padding_bottom}),
        common.constraint({
          height=beautiful.basic_panel_height,
          widget = top_panel_toplayout,
        }),
        common.constraint({height=beautiful.panel_padding_bottom}),
      })
 
    local top_panel_layout = common.align.vertical(
      nil,
      nil,
      common.fixed.vertical({
        common.constraint({
          height=beautiful.basic_panel_height,
          widget = top_panel_bottomlayout,
        }),
        common.constraint({height=beautiful.panel_padding_bottom})
      })
    )
    topwibox_layout[s] = top_panel_layout



    -- INDICATORS LEFT PANEL
    local left_panel_bottom_layout = common.fixed.vertical({
      loaded_widgets.textclock,
      v_sep,
      loaded_widgets.screen[s].layoutbox,
      v_sep,
      common.constraint({
        widget=loaded_widgets.music,
        height=dpi(180),
        strategy="min",
      }),
      v_sep,
      loaded_widgets.volume,
      v_sep,
      loaded_widgets.mem,
      v_sep,
      loaded_widgets.cpu,
      loaded_widgets.temp,
      loaded_widgets.bat,
    })

    local left_panel_bottom_layout_reflection = common.fixed.vertical(
      h_table.reversed(left_panel_bottom_layout.widgets)
    )
    local left_panel_top_layout = common.align.horizontal(
      nil,
      common.align.vertical(
        wibox.widget.background(
          common.constraint({height=beautiful.left_panel_width/2}),
          beautiful.panel_widget_bg
        ),
        wibox.widget.background(
          left_panel_bottom_layout_reflection,
          beautiful.panel_widget_bg
        ),
        common.fixed.vertical({
          assets.top_top_left_corner_image(),
          common.constraint({height=beautiful.panel_padding_bottom})
        })
      ),
      -- right margin:
      common.align.vertical(
        nil,
        nil,
        common.fixed.vertical({
          wibox.widget.background(
            common.constraint({
              height=beautiful.basic_panel_height,
              width=beautiful.panel_padding_bottom
            }),
            beautiful.panel_fg
          ),
          common.constraint({height=beautiful.panel_padding_bottom})
        })
      )
    )
    leftwibox_separator[s] = common.constraint({
      height = 0,
      widget = left_panel_top_layout
    })

    left_panel_layout = common.align.vertical(
      leftwibox_separator[s],
      common.align.horizontal(
        nil,
        common.align.vertical(
          assets.top_left_corner_image(),
          wibox.widget.background(
            left_panel_bottom_layout,
            beautiful.panel_widget_bg
          ),
          nil
        ),
        -- right margin:
        common.fixed.vertical({
          wibox.widget.background(
            common.constraint({height=beautiful.basic_panel_height, width=beautiful.panel_padding_bottom}),
            beautiful.panel_fg
          ),
          common.constraint({width=beautiful.panel_padding_bottom})
        })
      )
    )

    internal_corner_wibox[s] = assets.internal_corner_wibox()
    top_internal_corner_wibox[s] = assets.top_internal_corner_wibox()

    leftwibox[s] = awful.wibox({
      position = "left",
      screen = s,
      --height = beautiful.panel_height,
      width = beautiful.left_panel_width,
    })
    leftwibox[s]:set_widget(left_panel_layout)
    leftwibox[s].opacity = beautiful.panel_opacity
    leftwibox[s]:set_bg(beautiful.panel_bg)
    leftwibox[s]:set_fg(beautiful.panel_fg)

    topwibox[s] = awful.wibox({
      position = "top",
      screen = s,
      height = beautiful.panel_height,
    })
    topwibox[s]:set_widget(top_panel_layout)
    topwibox[s].opacity = beautiful.panel_opacity
    topwibox[s]:set_bg(beautiful.panel_bg)
    topwibox[s]:set_fg(beautiful.panel_fg)

    internal_corner_wibox[s].visible = true

  end

  awesome_context.topwibox = topwibox
  awesome_context.topwibox_layout = topwibox_layout
  awesome_context.topwibox_toplayout = topwibox_toplayout
  awesome_context.leftwibox = leftwibox
  awesome_context.leftwibox_separator = leftwibox_separator
  awesome_context.internal_corner_wibox = internal_corner_wibox
  awesome_context.top_internal_corner_wibox = top_internal_corner_wibox

  awesome_context.left_panel_visible = true

end
return toolbar
