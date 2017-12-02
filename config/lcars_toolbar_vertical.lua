local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local widgets = require("actionless.widgets")
local common = widgets.common
local h_table = require("actionless.util.table")

local assets = require("config.lcars_assets")


local toolbar = {}


function toolbar.init(awesome_context)
  local loaded_widgets = awesome_context.widgets

  -- Separators

  local v_sep_constraint = common.constraint({
    height=beautiful.panel_padding_bottom
  })
  local v_sep = wibox.container.background(
    v_sep_constraint,
    beautiful.panel_bg
  )
  setmetatable(v_sep, { __index = v_sep_constraint })



  local left_panel_widgets = {}
  local left_panel_top_layouts = {}
  local left_panel_bottom_layouts = {}

    local leftwibox = {}

  local leftwibox_separator = {}
  local internal_corner_wibox = {}
  local external_corner_wibox = {}
  local top_internal_corner_wibox = {}

  local lcars_textclock = common.decorated({
    widget = wibox.widget.textclock("%H:%M"),
    valign = "bottom",
    fg=beautiful.clock_fg,
    orientation="vertical",
  })
  awful.widget.calendar_popup.month({}):attach(lcars_textclock, "tl", {on_hover=true})

  awful.screen.connect_for_each_screen(function(s)
    local si = s.index
    local screen_widgets = loaded_widgets.screen[si]

    -- layoutbox
    local lcars_layoutbox = widgets.layoutbox({
      screen = s,
      fg = beautiful.widget_layoutbox_fg,
      bg = beautiful.widget_layoutbox_bg,
      --valign = "bottom",
      --bg = theme.color.color8, -- 6
      horizontal = false,
    })


    leftwibox[si] = awful.wibar({
      position = "left",
      screen = s,
      --height = beautiful.panel_height,
      width = beautiful.left_panel_width,
      opacity = beautiful.panel_opacity,
      visible = false,
      bg=beautiful.panel_bg,
      fg=beautiful.panel_fg,
    })
    --leftwibox[si]:set_widget(left_panel_layout)



    local left_panel_top_margin_to_compensate_rounding = wibox.container.background(
      common.constraint({
        height=beautiful.left_panel_width/2 - beautiful.panel_height,
      }),
      beautiful.panel_bg
    )

    -- INDICATORS LEFT PANEL
    left_panel_widgets[si] = {
      left_panel_top_margin_to_compensate_rounding,
      lcars_textclock,
      v_sep,
      common.decorated({
        widgets={
          lcars_layoutbox.textbox,
          wibox.layout.fixed.horizontal(
            screen_widgets.layoutbox.n_master,
            wibox.widget.textbox(' '),
            screen_widgets.layoutbox.n_col
          ),
        },
        orientation="vertical",
      }),
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
      common.decorated({widgets={
        loaded_widgets.cpu,
        loaded_widgets.mem,
      }}),
      v_sep,
      screen_widgets.lcarslist,
      --loaded_widgets.temp,
      --loaded_widgets.bat,
    }
    left_panel_bottom_layouts[si] = wibox.layout.fixed.vertical(h_table.unpack(left_panel_widgets[si]))

    left_panel_top_layouts[si] = wibox.layout.fixed.vertical(h_table.unpack(h_table.reversed(left_panel_widgets[si])))
    leftwibox_separator[si] = common.constraint({
      height = 0,
      widget = wibox.layout.align.horizontal(
        nil,
        wibox.layout.align.vertical(
            --wibox.container.background(
              --common.constraint({height=beautiful.left_panel_width/2}),
              --beautiful.panel_widget_bg
            --),
            nil,
            wibox.container.background(
              left_panel_top_layouts[si],
              beautiful.panel_widget_bg
            ),
            wibox.layout.fixed.vertical(
              assets.top_top_left_corner_image(),
              common.constraint({height=beautiful.panel_padding_bottom})
            )
        ),
        -- right margin:
        wibox.layout.align.vertical(
            nil,
            nil,
            wibox.layout.fixed.vertical(
              wibox.container.background(
                common.constraint({
                  height=beautiful.basic_panel_height,
                  width=beautiful.panel_padding_bottom
                }),
                beautiful.panel_fg
              ),
              common.constraint({height=beautiful.panel_padding_bottom})
            )
        )
      )
    })

    local left_panel_layout = wibox.layout.align.vertical(
      leftwibox_separator[si],
      wibox.layout.align.horizontal(
        nil,
        left_panel_bottom_layouts[si],
        -- right margin:
        common.constraint({width=beautiful.panel_padding_bottom})
      )
    )


    leftwibox[si]:set_widget(left_panel_layout)
    --leftwibox[si]:set_widget(wibox.widget.textbox('test'))


    external_corner_wibox[si] = assets.top_left_corner_wibox()
    internal_corner_wibox[si] = assets.internal_corner_wibox()
    top_internal_corner_wibox[si] = assets.top_internal_corner_wibox()
    --top_internal_corner_wibox[si] = assets.internal_corner_wibox()


    internal_corner_wibox[si].visible = false
    --external_corner_wibox[si].visible = false

  end)

    awesome_context.leftwibox = leftwibox

  awesome_context.leftwibox_separator = leftwibox_separator
  awesome_context.internal_corner_wibox = internal_corner_wibox
  awesome_context.external_corner_wibox = external_corner_wibox
  awesome_context.top_internal_corner_wibox = top_internal_corner_wibox
  --awesome_context.top_internal_corner_wibox = internal_corner_wibox

  awesome_context.left_panel_widgets = left_panel_widgets
  awesome_context.left_panel_top_layouts = left_panel_top_layouts
  awesome_context.left_panel_bottom_layouts = left_panel_bottom_layouts

end
return toolbar
