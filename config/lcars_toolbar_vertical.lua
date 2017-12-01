local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local common = require("actionless.widgets.common")
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

  awful.screen.connect_for_each_screen(function(s)
    local si = s.index
    local screen_widgets = loaded_widgets.screen[si]

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




    -- INDICATORS LEFT PANEL
    left_panel_widgets[si] = {
      loaded_widgets.lcars_textclock,
      v_sep,
      common.decorated({widgets={
        screen_widgets.layoutbox.textbox,
        wibox.layout.fixed.horizontal(
          screen_widgets.layoutbox.n_master,
          wibox.widget.textbox(' '),
          screen_widgets.layoutbox.n_col
        ),
      }}),
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
        wibox.layout.align.vertical(
          --assets.bottom_top_left_corner_image(),
          wibox.container.background(
            left_panel_bottom_layouts[si],
            --wibox.widget.textbox('test'),
            --beautiful.panel_widget_bg
            "#00ff00"
          ),
          nil
        ),
        -- right margin:
        wibox.layout.fixed.vertical(
          wibox.container.background(
            common.constraint({height=beautiful.basic_panel_height, width=beautiful.panel_padding_bottom}),
            --beautiful.panel_fg
            "#ff0000"
          ),
          common.constraint({width=beautiful.panel_padding_bottom})
        )
      )
    )

    local top_left_corner_image = assets.top_left_corner_image()
    local top_left_corner_imagebox = wibox.widget.imagebox()
    top_left_corner_imagebox:set_image(top_left_corner_image)
    top_left_corner_imagebox:set_resize(false)

    --@TODO: this should be debugged
    local external_corner_wibox_layout = wibox(top_left_corner_imagebox)
    --external_corner_wibox_layout = wibox(wibox.container.background(wibox.widget.textbox('test'), "#ff0000"))
    external_corner_wibox_layout.shape_bounding = top_left_corner_image._native
    external_corner_wibox_layout:geometry({ x = 0, y = 0, width = 200, height = 200, })
    external_corner_wibox.border_color="#ff0000"
    external_corner_wibox.border_width = 10
    external_corner_wibox[si] = external_corner_wibox_layout

    internal_corner_wibox[si] = assets.internal_corner_wibox()
    top_internal_corner_wibox[si] = assets.top_internal_corner_wibox()
    --top_internal_corner_wibox[si] = assets.internal_corner_wibox()


    leftwibox[si]:set_widget(left_panel_layout)
    --leftwibox[si]:set_widget(wibox.widget.textbox('test'))

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
