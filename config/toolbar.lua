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
local make_separator = common.make_separator

local dpi = require("actionless.xresources").compute_fontsize

local toolbar = {}


function toolbar.init(awesome_context)
  local loaded_widgets = awesome_context.widgets

  -- Separators
  local sep = wibox.widget.imagebox(beautiful.small_separator)
  local separator  = make_separator(' ')
  local sep_info   = make_separator('sq', {fg=beautiful.panel_info})
  local sep_media  = make_separator('sq', {fg=beautiful.panel_media})


  -- Create a wibox for each screen and add it
  local leftwibox = {}
  local topwibox = {}
  for s = 1, capi.screen.count() do

    -- top side
    local top_layout = wibox.layout.fixed.vertical()

    -- left side of TOP PANEL
    local left_layout = wibox.layout.fixed.horizontal()
      local left_margin = wibox.widget.background(
        common.constraint({width=dpi(100)}),
        beautiful.fg
      )
    left_layout:add(left_margin)
    left_layout:add(loaded_widgets.screen[s].taglist)
    left_layout:add(left_margin)
    left_layout:add(separator)
    left_layout:add(loaded_widgets.screen[s].close_button)
    left_layout:add(separator)
    left_layout:add(loaded_widgets.kbd)
    left_layout:add(loaded_widgets.screen[s].promptbox)
    left_layout:add(separator)

    -- sneaky_toggle
    if s == 1 then
      loaded_widgets.systray_toggle = widgets.sneaky_toggle({
          widgets={
            sep_media,
            --loaded_widgets.netctl,
            sep_media,
          }, enable_sneaky_tray = true,
      })
      left_layout:add(loaded_widgets.systray_toggle)
    else
      left_layout:add(separator)
    end

    -- INDICATORS LEFT PANEL
    local indicators_layout = wibox.layout.flex.vertical()

    indicators_layout:add(loaded_widgets.screen[s].layoutbox)
    indicators_layout:add(loaded_widgets.textclock)
    indicators_layout:add(loaded_widgets.music)
    indicators_layout:add(loaded_widgets.volume)

    indicators_layout:add(loaded_widgets.mem)
    indicators_layout:add(loaded_widgets.cpu)
    indicators_layout:add(loaded_widgets.temp)
    indicators_layout:add(loaded_widgets.bat)


    -- TOOLBAR
    --local left_panel_layout = wibox.layout.align.vertical()
    --left_panel_layout:set_first(top_layout)

    left_panel_layout = indicators_layout

    local top_panel_layout = wibox.layout.align.horizontal()
    top_panel_layout:set_first(left_layout)
    top_panel_layout:set_second(loaded_widgets.screen[s].tasklist)
    --top_panel_layout:set_third(right_layout)

    -- background image:
    if false and beautiful.panel_bg_image then
      local layout_bg = wibox.widget.background()
      layout_bg:set_bgimage(beautiful.panel_bg_image)
      layout_bg:set_widget(layout)
      layout = layout_bg
    end

    -- bottom panel padding:
    if beautiful.panel_padding_bottom then
      local const = wibox.layout.constraint()
      const:set_strategy("exact")
      const:set_height(beautiful.panel_padding_bottom)
      local margined_layout = wibox.layout.align.vertical()
      margined_layout:set_middle(top_panel_layout)
      margined_layout:set_bottom(const)
      top_panel_layout = margined_layout
    end

local cairo        = require( "lgi"            ).cairo

local left_panel_width = dpi(120)

    if true then -- namespace
      local top_left_corner_image = wibox.layout.constraint()
      top_left_corner_image:set_strategy('exact')
        local top_left_corner_imagebox = wibox.widget.imagebox(beautiful.decoration_top_left_corner)
          local radius = left_panel_width / 2
          local img = cairo.ImageSurface(cairo.Format.ARGB32, left_panel_width, radius)
          local cr = cairo.Context(img)
          --cr:set_source(gears.color(beautiful.panel_widget_fg))
          --cr:paint()
          cr:set_source(gears.color(beautiful.panel_widget_bg))
          --[[cr:set_antialias(cairo.Antialias.NONE)]]
          cr:save()
          cr:arc(
            radius,
            radius,
            radius,
            math.pi,
            3*(math.pi/2)
          )
          cr:arc(
            radius,
            0,
            radius,
            math.pi,
            3*(math.pi/2)
          )
          cr:arc(
            radius*2,
            radius,
            radius,
            3*(math.pi/2),
            math.pi
          )
          --cr:close_path()
          --cr:restore()
          cr:fill()
        top_left_corner_imagebox:set_image(img)
      top_left_corner_image:set_widget(top_left_corner_imagebox)


      local top_left_corner_border = wibox.layout.constraint()
      top_left_corner_border:set_strategy('exact')
      top_left_corner_border:set_height(beautiful.panel_padding_bottom)
      local top_left_corner = wibox.layout.fixed.vertical()
      top_left_corner:add(top_left_corner_image)
      top_left_corner:add(top_left_corner_border)

      local rich_layout = wibox.layout.align.vertical()
      rich_layout:set_top(top_left_corner)
      rich_layout:set_middle(left_panel_layout)

      local horiz_placeholder = wibox.layout.constraint()
      horiz_placeholder:set_strategy("exact")
      horiz_placeholder:set_height(beautiful.basic_panel_height)
      local horiz_placeholder_bg = wibox.widget.background(
        horiz_placeholder,
        beautiful.panel_fg
      )
      local const = wibox.layout.constraint()
      const:set_strategy("exact")
      const:set_width(beautiful.panel_padding_bottom)
        local internal_corner_radius = dpi(30)
        local internal_corner_wibox = wibox({})
        internal_corner_wibox.height = internal_corner_radius
        internal_corner_wibox.width  = internal_corner_radius
        internal_corner_wibox.x = left_panel_width - beautiful.panel_padding_bottom
        internal_corner_wibox.y = beautiful.basic_panel_height
        internal_corner_wibox.ontop  = true
        internal_corner_wibox.visible  = true
        local internal_corner_imagebox = wibox.widget.imagebox()
          local img = cairo.ImageSurface(cairo.Format.ARGB32, internal_corner_radius, internal_corner_radius)
          local cr = cairo.Context(img)
          cr:save()

          local border_radius = internal_corner_radius + beautiful.panel_padding_bottom
          cr.line_width = beautiful.panel_padding_bottom * 2
          cr:set_source(gears.color(beautiful.panel_widget_fg))
          cr:move_to(0, border_radius)
          cr:line_to(0, 0)
          cr:line_to(border_radius, 0)
          cr:curve_to(
            border_radius, 0,
            0, 0,
            0, border_radius
          )
          cr:stroke()
          cr:fill()

          cr:set_source(gears.color(beautiful.panel_widget_bg))
          cr.line_width = 1
          cr:move_to(0, internal_corner_radius)
          cr:line_to(0, 0)
          cr:line_to(internal_corner_radius, 0)
          cr:curve_to(
            internal_corner_radius, 0,
            0, 0,
            0, internal_corner_radius
          )
          cr:close_path()
          cr:fill_preserve()
          cr:stroke()
        internal_corner_imagebox:set_image(img)
        internal_corner_wibox:set_widget(internal_corner_imagebox)
        --internal_corner_wibox:set_widget(wibox.widget.textbox('test'))
        internal_corner_wibox.shape_bounding = img._native
      local rounding_decoration = wibox.layout.fixed.vertical()
      rounding_decoration:add(horiz_placeholder_bg)
      rounding_decoration:add(const)

      local margined_layout = wibox.layout.align.horizontal()
      margined_layout:set_middle(rich_layout)
      margined_layout:set_third(rounding_decoration)
      left_panel_layout = margined_layout
    end

    leftwibox[s] = awful.wibox({
      position = "left",
      screen = s,
      --height = beautiful.panel_height,
      width = left_panel_width,
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


  end

  awesome_context.topwibox = topwibox
  awesome_context.leftwibox = leftwibox
  awesome_context.left_panel_visible = true

end
return toolbar
