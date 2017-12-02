local wibox = require("wibox")
local beautiful = require("beautiful")
local cairo = require("lgi").cairo
local gears = require("gears")

local assets = {}

function assets.top_left_corner_image()
  local radius = beautiful.left_panel_width / 2
  local img = cairo.ImageSurface(cairo.Format.ARGB32, beautiful.left_panel_width, radius)
  local cr = cairo.Context(img)
  cr:move_to(0, radius)
  cr:line_to(radius*2, radius)
  cr:line_to(radius*2, 0)
  cr:line_to(radius, 0)
  cr:curve_to(
    radius, 0,
    0, 0,
    0, radius
  )
  cr:set_source(gears.color(beautiful.panel_widget_bg))
  cr:fill()
  return img
end

function assets.top_left_corner_wibox()
  local external_corner_wibox_layout = wibox()
  external_corner_wibox_layout.height = beautiful.left_panel_width / 2
  external_corner_wibox_layout.width  = beautiful.left_panel_width - beautiful.panel_padding_bottom
  external_corner_wibox_layout.x = 0
  external_corner_wibox_layout.y = 0
  external_corner_wibox_layout.opacity = beautiful.panel_opacity
  local top_left_corner_image = assets.top_left_corner_image()
  local top_left_corner_imagebox = wibox.widget.imagebox()
  top_left_corner_imagebox:set_image(top_left_corner_image)
  top_left_corner_imagebox:set_resize(false)
  external_corner_wibox_layout:set_widget(top_left_corner_imagebox)
  external_corner_wibox_layout.shape_bounding = top_left_corner_image._native
  return external_corner_wibox_layout
end

function assets.top_top_left_corner_image()
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
  local top_left_corner_imagebox = wibox.widget.imagebox()
  top_left_corner_imagebox:set_image(img)
  top_left_corner_imagebox:set_resize(false)
  return top_left_corner_imagebox
end

function assets.internal_corner_image()
  local internal_corner_radius = beautiful.left_panel_internal_corner_radius
  local img = cairo.ImageSurface(cairo.Format.ARGB32, internal_corner_radius, internal_corner_radius)
  local cr = cairo.Context(img)

  -- draw border
  local border_radius = internal_corner_radius + beautiful.panel_padding_bottom
  cr.line_width = beautiful.panel_padding_bottom * 2
  cr:set_source(gears.color(beautiful.panel_bg))
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

  return img
end

function assets.internal_corner_wibox()
  local internal_corner_radius = beautiful.left_panel_internal_corner_radius
  local w = wibox({})
  w.height = internal_corner_radius
  w.width  = internal_corner_radius
  w.x = beautiful.left_panel_width - beautiful.panel_padding_bottom
  w.y = beautiful.basic_panel_height
  w.opacity = beautiful.panel_opacity
  local img = assets.internal_corner_image()
  local internal_corner_imagebox = wibox.widget.imagebox()
  internal_corner_imagebox:set_image(img)
  w:set_widget(internal_corner_imagebox)
  function w:apply_shape()
    self.shape_bounding = img._native
  end
  w:apply_shape()
  return w
end

function assets.top_internal_corner_wibox()
  local internal_corner_radius = beautiful.left_panel_internal_corner_radius

  local wibox_instance = wibox({})
  wibox_instance.height = internal_corner_radius
  wibox_instance.width  = internal_corner_radius
  wibox_instance.x = beautiful.left_panel_width - beautiful.panel_padding_bottom
  wibox_instance.y = beautiful.basic_panel_height
  wibox_instance.opacity = beautiful.panel_opacity
  local img = cairo.ImageSurface.create(cairo.Format.ARGB32, internal_corner_radius, internal_corner_radius)
  local cr = cairo.Context.create(img)

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

  wibox_instance:set_widget(wibox.widget.imagebox(img))
  wibox_instance.shape_bounding = img._native

  return wibox_instance
end

return assets
