--[[
     Licensed under GNU General Public License v2
      * (c) 2014-2021  Yauheni Kirylau
--]]


local beautiful = require("beautiful")
local gears = require("gears")
local wibox = require("wibox")


local module = {}

function module.widget(args)
  args = args or {}

  local show_icon = args.show_icon
  if show_icon == nil then
    show_icon = beautiful.show_widget_icon
  end

  local widget_bg = wibox.container.background()
  widget_bg.lie_layout = wibox.layout.fixed.horizontal()
  if show_icon then
    widget_bg.icon_widget = wibox.widget.imagebox()
    --widget_bg.icon_widget.resize = beautiful.xresources.get_dpi() > 96
    --widget_bg.icon_widget.resize = false
    local vert_center = wibox.layout.align.vertical(nil, widget_bg.icon_widget, nil)
    vert_center.expand = "none"
    widget_bg.lie_layout:add(vert_center)
  end
  widget_bg.text_widget = wibox.widget.textbox('')
  widget_bg.lie_layout:add(widget_bg.text_widget)
  if args.margin then
    local margin_widget = wibox.container.margin(
      widget_bg.lie_layout,
      args.margin.left, args.margin.right,
      args.margin.top, args.margin.bottom,
      args.margin.color, args.margin.draw_empty
    )
    widget_bg:set_widget(margin_widget)
  else
    widget_bg:set_widget(widget_bg.lie_layout)
  end

  function widget_bg:set_image(image)
    if not widget_bg.icon_widget then
      return
    end
    if (image == widget_bg.old_image) then
      return
    end
    widget_bg.old_image = image
    image = image and gears.surface.load(image)
    if not image then
      return
    end
    widget_bg.icon_widget:set_resize(image.height > beautiful.basic_panel_height)
    --local ratio = beautiful.basic_panel_height / image.height
    --widget_bg.icon_widget.forced_width = math.ceil(image.width * ratio)
    widget_bg.icon_widget:set_image(image)
  end

  function widget_bg:set_font(...)
    return widget_bg.text_widget:set_font(...)
  end

  widget_bg.text_widget._orig_set_text = widget_bg.text_widget.set_text
  function widget_bg.text_widget:set_text(text, ...)
    if not widget_bg.icon_widget and (not text or text == '') then
      widget_bg.visible = false
    else
      widget_bg.visible = true
      return widget_bg.text_widget:_orig_set_text(text, ...)
    end
  end

  widget_bg.text_widget._orig_set_markup = widget_bg.text_widget.set_markup
  function widget_bg.text_widget:set_markup(text, ...)
    if not widget_bg.icon_widget and (not text or text == '') then
      widget_bg.visible = false
    else
      widget_bg.visible = true
      return widget_bg.text_widget:_orig_set_markup(text, ...)
    end
  end

  function widget_bg:set_text(...)
    return widget_bg.text_widget:set_text(...)
  end

  function widget_bg:set_markup(...)
    return widget_bg.text_widget:set_markup(...)
  end

  if args.text then
    widget_bg:set_text(args.text)
  end
  widget_bg:set_font(args.font or beautiful.panel_widget_font or beautiful.font)

  return widget_bg
end


return setmetatable(module, { __call = function(_, ...) return module.widget(...) end })
