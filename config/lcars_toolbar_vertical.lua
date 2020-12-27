local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")

local widgets = require("actionless.widgets")
local common = widgets.common
local h_table = require("actionless.util.table")



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

  local top_left_corner_placeholder = {}
  local top_left_corner_imagebox = {}
  local top_left_corner_container = {}

  local lcars_textclock = common.decorated({
    widget = wibox.widget.textclock("%H:%M"),
    valign = "bottom",
    fg=beautiful.clock_fg,
    orientation="vertical",
  })
  loaded_widgets.calendar_popup:attach(lcars_textclock, "tl", {on_hover=true})

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


  local internal_corner_radius = beautiful.left_panel_internal_corner_radius
    leftwibox[si] = awful.wibar({
      position = "left",
      screen = s,
      width = beautiful.left_panel_width + internal_corner_radius,
      visible = false,
      bg=beautiful.panel_bg,
      fg=beautiful.panel_fg,
      shape = function(cr, w, h)
        cr:move_to(w, 0)
        cr:curve_to(
          w, 0,
          w-internal_corner_radius, 0,
          w-internal_corner_radius, internal_corner_radius
        )
        cr:line_to(w-internal_corner_radius, h)
        cr:line_to(0, h)
        cr:line_to(0, 0)
        cr:close_path()
        return cr
      end,
    })



    top_left_corner_placeholder[si] = wibox.container.background(
      common.constraint({
        height=beautiful.left_panel_width/2 - beautiful.panel_height,
      }),
      beautiful.panel_bg
    )
    top_left_corner_container[si] = wibox.container.background(top_left_corner_placeholder[si])

    -- INDICATORS LEFT PANEL
    left_panel_widgets[si] = {
      top_left_corner_container[si],
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
      common.decorated({
        widgets={
              loaded_widgets.mem.widget.textbox,
              loaded_widgets.cpu.widget.textbox,
        },
        orientation="vertical",
      }),
      v_sep,
      screen_widgets.lcarslist,
      loaded_widgets.temp,
      loaded_widgets.bat,
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
        -- right margin + shape compensation:
        common.constraint({width=beautiful.panel_padding_bottom + internal_corner_radius})
      )
    )
    leftwibox[si]:set_widget(left_panel_layout)
  end)


    awesome_context.lcars_assets.leftwibox = leftwibox

  awesome_context.lcars_assets.leftwibox_separator = leftwibox_separator
  awesome_context.lcars_assets.internal_corner_wibox = internal_corner_wibox
  awesome_context.lcars_assets.external_corner_wibox = external_corner_wibox
  awesome_context.lcars_assets.top_internal_corner_wibox = top_internal_corner_wibox
  --
  awesome_context.lcars_assets.top_left_corner_placeholder = top_left_corner_placeholder
  awesome_context.lcars_assets.top_left_corner_imagebox = top_left_corner_imagebox
  awesome_context.lcars_assets.top_left_corner_container = top_left_corner_container

  awesome_context.lcars_assets.left_panel_widgets = left_panel_widgets
  awesome_context.lcars_assets.left_panel_top_layouts = left_panel_top_layouts
  awesome_context.lcars_assets.left_panel_bottom_layouts = left_panel_bottom_layouts

end
return toolbar
