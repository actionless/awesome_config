--[[
     Licensed under GNU General Public License v2
      * (c) 2014-2021  Yauheni Kirylau
--]]


local beautiful = require("beautiful")
local gears = require("gears")
local wibox = require("wibox")


local module = {}


function module.set_panel_widget_shape(bg_widget, args)
  args = args or {}
  bg_widget.shape_clip = true
  bg_widget.shape = function(c, w, h) return gears.shape.rounded_rect(c, w, h, beautiful.panel_widget_border_radius) end
  bg_widget.shape_border_width = args.border_width or beautiful.panel_widget_border_width or 0
  bg_widget.shape_border_color = args.border_color or beautiful.panel_widget_border_color or beautiful.border_normal
  return bg_widget
end


function module.panel_widget_shape(widget, args)
  args = args or {}
  local shaped = wibox.container.background(widget)
  module.set_panel_widget_shape(shaped, args)
  --setmetatable(shaped,        { __index = widget })
  shaped.lie_widget = widget
  return shaped
end


return module
