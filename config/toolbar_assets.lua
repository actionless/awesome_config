local wibox = require("wibox")
local beautiful = require("beautiful")
local cairo        = require( "lgi"            ).cairo
local gears = require("gears")

local assets = {}

function assets.top_left_corner_image()
  local top_left_corner_imagebox = wibox.widget.imagebox()
  local radius = beautiful.left_panel_width / 2
  local img = cairo.ImageSurface(cairo.Format.ARGB32, beautiful.left_panel_width, radius)
  local cr = cairo.Context(img)
  cr:set_source(gears.color(beautiful.panel_widget_bg))
  cr:move_to(0, radius)
  cr:line_to(radius*2, radius)
  cr:line_to(radius*2, 0)
  cr:line_to(radius, 0)
  cr:curve_to(
    radius, 0,
    0, 0,
    0, radius
  )
  cr:fill()
  top_left_corner_imagebox:set_image(img)
  top_left_corner_imagebox:set_resize(false)
  return top_left_corner_imagebox
end
function assets.top_top_left_corner_image()
  local top_left_corner_imagebox = wibox.widget.imagebox()
  local radius = beautiful.left_panel_width / 2
  local img = cairo.ImageSurface(cairo.Format.ARGB32, beautiful.left_panel_width, radius)
  local cr = cairo.Context(img)
  cr:set_source(gears.color(beautiful.panel_widget_bg))
  cr:line_to(radius*2, 0)
  cr:line_to(radius*2, radius)
  cr:line_to(radius, radius)
  cr:curve_to(
    radius, radius,
    0, radius,
    0, 0
  )
  cr:fill()
  top_left_corner_imagebox:set_image(img)
  top_left_corner_imagebox:set_resize(false)
  return top_left_corner_imagebox
end

function assets.internal_corner_wibox()
  local internal_corner_radius = beautiful.left_panel_internal_corner_radius
  local w = wibox({})
  w.height = internal_corner_radius
  w.width  = internal_corner_radius
  w.x = beautiful.left_panel_width - beautiful.panel_padding_bottom
  w.y = beautiful.basic_panel_height
  w.opacity = beautiful.panel_opacity
  local internal_corner_imagebox = wibox.widget.imagebox()
  local img = cairo.ImageSurface(cairo.Format.ARGB32, internal_corner_radius, internal_corner_radius)
  local cr = cairo.Context(img)

  -- draw border
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

  -- draw filling
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
  cr:fill()
  cr:stroke()

  internal_corner_imagebox:set_image(img)
  w:set_widget(internal_corner_imagebox)
  w.shape_bounding = img._native
  return w
end
function assets.top_internal_corner_wibox()
  local internal_corner_radius = beautiful.left_panel_internal_corner_radius
  local w = wibox({})
  w.height = internal_corner_radius
  w.width  = internal_corner_radius
  w.x = beautiful.left_panel_width - beautiful.panel_padding_bottom
  w.y = beautiful.basic_panel_height
  w.opacity = beautiful.panel_opacity
  local internal_corner_imagebox = wibox.widget.imagebox()
  local img = cairo.ImageSurface(cairo.Format.ARGB32, internal_corner_radius, internal_corner_radius)
  local cr = cairo.Context(img)

  --draw border
  local ppb = beautiful.panel_padding_bottom
  local icr = internal_corner_radius
  cr.line_width = beautiful.panel_padding_bottom * 2
  cr:set_source(gears.color(beautiful.panel_widget_fg))
  cr:move_to(0, 0)
  cr:line_to(0, icr)
  cr:line_to(icr+ppb, icr)
  cr:curve_to(
    icr+ppb, icr,
    0, icr,
    0, 0
  )
  cr:stroke()
  cr:fill()

  -- draw filling
  cr:set_source(gears.color(beautiful.panel_widget_bg))
  cr.line_width = 1
  cr:move_to(0, 0)
  cr:line_to(0, internal_corner_radius)
  cr:line_to(internal_corner_radius, internal_corner_radius)
  cr:curve_to(
    internal_corner_radius, internal_corner_radius,
    0, internal_corner_radius,
    0, 0
  )
  cr:fill()
  cr:stroke()

  internal_corner_imagebox:set_image(img)
  w:set_widget(internal_corner_imagebox)
  w.shape_bounding = img._native
  return w
end

return assets
