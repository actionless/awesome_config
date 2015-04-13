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

local toolbar = {}


function toolbar.init(awesome_context)
  local loaded_widgets = awesome_context.widgets

  -- Separators
  local separator  = common.make_separator(' ')
  local sep_media  = common.make_separator('sq', {fg=beautiful.panel_media})


  -- Create a wibox for each screen and add it
  local leftwibox = {}
  local topwibox = {}
  local internal_corner_wibox = {}
  for s = 1, capi.screen.count() do

    local top_panel_left_margin = wibox.widget.background(
      common.constraint({width=dpi(100)}),
      beautiful.fg
    )
    -- TOP PANEL:
    local top_panel_layout = common.align.horizontal(
      common.fixed.horizontal({
        top_panel_left_margin,
        loaded_widgets.screen[s].taglist,
        top_panel_left_margin,
        separator,
        loaded_widgets.screen[s].close_button,
        separator,
        loaded_widgets.kbd,
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
      top_panel_layout:set_third(loaded_widgets.systray_toggle)
    end


    -- INDICATORS LEFT PANEL
    local left_panel_layout = common.fixed.vertical({
      loaded_widgets.textclock,
      loaded_widgets.screen[s].layoutbox,
      common.constraint({
        widget=loaded_widgets.music,
        height=dpi(180)
      }),
      common.fixed.vertical({
        common.constraint({
          widget=loaded_widgets.volume,
          height=dpi(80)
        }),
        common.constraint({height=beautiful.panel_padding_bottom})
      }),
      loaded_widgets.mem,
      loaded_widgets.cpu,
      loaded_widgets.temp,
      loaded_widgets.bat
    })


    -- background image:
    if false and beautiful.panel_bg_image then
      local layout_bg = wibox.widget.background(top_panel_layout)
      layout_bg:set_bgimage(beautiful.panel_bg_image)
      top_panel_layout = layout_bg
    end

    -- bottom panel padding:
    if beautiful.panel_padding_bottom then
      top_panel_layout = common.align.vertical(
        nil,
        top_panel_layout,
        common.constraint({height=beautiful.panel_padding_bottom})
      )
    end


    left_panel_layout = common.align.horizontal(
      nil,
      common.align.vertical(
        common.fixed.vertical({
          assets.top_left_corner_image(),
          common.constraint({height=beautiful.panel_padding_bottom})
        }),
        left_panel_layout,
        nil
      ),
      -- right margin:
      common.fixed.vertical({
        wibox.widget.background(
          common.constraint({height=beautiful.basic_panel_height}),
          beautiful.panel_fg
        ),
        common.constraint({width=beautiful.panel_padding_bottom})
      })
    )

    local internal_corner_radius = dpi(30)
    internal_corner_wibox[s] = assets.internal_corner_wibox(internal_corner_radius)

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
  awesome_context.leftwibox = leftwibox
  awesome_context.internal_corner_wibox = internal_corner_wibox

  awesome_context.left_panel_visible = true

end
return toolbar
