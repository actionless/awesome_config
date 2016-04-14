local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local common = require("actionless.widgets.common")
local h_table = require("utils.table")

local assets = require("config.toolbar_assets")


local toolbar = {}


function toolbar.init(awesome_context)
  local loaded_widgets = awesome_context.widgets

  -- Separators
  local separator  = common.make_separator(' ')

  local v_sep_constraint = common.constraint({
    height=beautiful.panel_padding_bottom
  })
  local v_sep = wibox.widget.background(
    v_sep_constraint,
    beautiful.panel_bg
  )
  setmetatable(v_sep, { __index = v_sep_constraint })

  local h_sep = common.constraint({ width=dpi(7) })


  -- Create a wibox for each screen and add it

  -- @TODO: clean it up:
  local left_panel_widgets = {}
  local left_panel_top_layouts = {}
  local left_panel_bottom_layouts = {}

  local topwibox_layout = {}
  local topwibox_toplayout = {}
  local leftwibox_separator = {}
  local internal_corner_wibox = {}
  local top_internal_corner_wibox = {}

  awful.screen.connect_for_each_screen(function(s)
    local si = s.index

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
        --top_panel_left_margin,
        --loaded_widgets.screen[si].taglist,
        top_panel_left_margin,
        separator,
        loaded_widgets.screen[si].manage_client,
        separator,
        loaded_widgets.kbd,
        separator,
        loaded_widgets.screen[si].promptbox,
        separator
      }),
      loaded_widgets.screen[si].tasklist,
      nil
    )
    -- add sneaky_toggle on first screen
    if si == 1 then
      local fancy_volume_widget = common.constraint({
        widget=common.fixed.vertical({
          common.constraint({
            widget=loaded_widgets.volume,
            height=dpi(8),
          }),
          common.constraint({
            widget=wibox.widget.background(wibox.widget.textbox(), beautiful.apw_fg_color),
            height=dpi(10),
          }),
        }),
        width=dpi(400)
      })
      fancy_volume_widget:buttons(loaded_widgets.volume:buttons())
      top_panel_bottomlayout:set_third(
        common.fixed.horizontal({
          h_sep,
          fancy_volume_widget,
          h_sep,
          common.constraint({
            widget=loaded_widgets.music,
            --height=dpi(80),
            width=dpi(700)
          }),
          --loaded_widgets.systray_toggle,
        })
      )
    end

    topwibox_toplayout[si] =
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
    -- add :buttons method
    top_panel_layout = setmetatable(
      top_panel_layout,
      wibox.widget.background(top_panel_layout)
    )
    topwibox_layout[si] = top_panel_layout



    -- INDICATORS LEFT PANEL
    left_panel_widgets[si] = {
      loaded_widgets.lcars_textclock,
      v_sep,
      loaded_widgets.screen[si].layoutbox,
      v_sep,
      --common.constraint({
        --widget=loaded_widgets.music,
        ----height=dpi(180),
        --height=dpi(120),
        --strategy="min",
      --}),
      --v_sep,
      --setmetatable(
        --common.constraint({
          --widget=loaded_widgets.volume,
          --height=dpi(80)
          ----height=dpi(60)
        --}),
        --{ __index = apw_widget }
      --),
      --v_sep,
      --common.decorated({widgets={
        --loaded_widgets.cpu,
        --loaded_widgets.mem,
      --}}),
      --v_sep,
      loaded_widgets.screen[si].lcarslist,
      --loaded_widgets.temp,
      --loaded_widgets.bat,
    }
    left_panel_bottom_layouts[si] = common.fixed.vertical(left_panel_widgets[si])

    left_panel_top_layouts[si] = common.fixed.vertical(
      h_table.reversed(left_panel_bottom_layouts[si].widgets)
    )
    leftwibox_separator[si] = common.constraint({
      height = 0,
      widget = common.align.horizontal(
      nil,
      common.align.vertical(
        --wibox.widget.background(
          --common.constraint({height=beautiful.left_panel_width/2}),
          --beautiful.panel_widget_bg
        --),
        nil,
        wibox.widget.background(
          left_panel_top_layouts[si],
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
    })

    local left_panel_layout = common.align.vertical(
      leftwibox_separator[si],
      common.align.horizontal(
        nil,
        common.align.vertical(
          assets.top_left_corner_image(),
          wibox.widget.background(
            left_panel_bottom_layouts[si],
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

    internal_corner_wibox[si] = assets.internal_corner_wibox()
    top_internal_corner_wibox[si] = assets.top_internal_corner_wibox()
    --top_internal_corner_wibox[si] = assets.internal_corner_wibox()


    awesome_context.leftwibox[si]:set_widget(left_panel_layout)
    internal_corner_wibox[si].visible = false

  end)

  awesome_context.topwibox_layout = topwibox_layout  -- this one!
  awesome_context.topwibox_toplayout = topwibox_toplayout

  awesome_context.leftwibox_separator = leftwibox_separator
  awesome_context.internal_corner_wibox = internal_corner_wibox
  awesome_context.top_internal_corner_wibox = top_internal_corner_wibox
  --awesome_context.top_internal_corner_wibox = internal_corner_wibox

  awesome_context.left_panel_widgets = left_panel_widgets
  awesome_context.left_panel_top_layouts = left_panel_top_layouts
  awesome_context.left_panel_bottom_layouts = left_panel_bottom_layouts

end
return toolbar
