--[[
     Licensed under GNU General Public License v2
      * (c) 2014-2021  Yauheni Kirylau
--]]


local beautiful = require("beautiful")
local gears = require("gears")
local wibox = require("wibox")


local module = {}

function module.widget(args2)
  local widget_bg = wibox.container.background()

  function widget_bg:_init_(args)
    args = args or {}

    local show_icon = args.show_icon
    if show_icon == nil then
      show_icon = beautiful.show_widget_icon
    end

    self.lie_layout = wibox.layout.fixed.horizontal()
    if show_icon then
      self.icon_widget = wibox.widget.imagebox()
      --self.icon_widget.resize = beautiful.xresources.get_dpi() > 96
      --self.icon_widget.resize = false
      local vert_center = wibox.layout.align.vertical(nil, self.icon_widget, nil)
      vert_center.expand = "none"
      self.lie_layout:add(vert_center)
    end
    self.text_widget = wibox.widget.textbox('')
    self.text_widget._orig_set_text = self.text_widget.set_text
    self.text_widget._orig_set_markup = self.text_widget.set_markup

    function self.text_widget:set_text(text, ...)
      if not widget_bg.icon_widget and (not text or text == '') then
        widget_bg.visible = false
      else
        widget_bg.visible = true
        return widget_bg.text_widget:_orig_set_text(text, ...)
      end
    end

    function self.text_widget:set_markup(text, ...)
      if not widget_bg.icon_widget and (not text or text == '') then
        widget_bg.visible = false
      else
        widget_bg.visible = true
        return self:_orig_set_markup(text, ...)
      end
    end

    self.lie_layout:add(self.text_widget)
    if args.margin then
      local margin_widget = wibox.container.margin(
        self.lie_layout,
        args.margin.left, args.margin.right,
        args.margin.top, args.margin.bottom,
        args.margin.color, args.margin.draw_empty
      )
      self:set_widget(margin_widget)
    else
      self:set_widget(self.lie_layout)
    end

    if args.text then
      self:set_text(args.text)
    end
    self:set_font(args.font or beautiful.panel_widget_font or beautiful.font)

  end

  function widget_bg:set_image(image)
    if not self.icon_widget then
      return
    end
    if (image == self.old_image) then
      return
    end
    self.old_image = image
    image = image and gears.surface.load(image)
    if not image then
      self.lie_layout.children[1]:set_second(nil)
      return
    else
      self.lie_layout.children[1]:set_second(self.icon_widget)
    end
    self.icon_widget:set_resize(image.height > beautiful.basic_panel_height)
    --local ratio = beautiful.basic_panel_height / image.height
    --self.icon_widget.forced_width = math.ceil(image.width * ratio)
    self.icon_widget:set_image(image)
  end

  function widget_bg:set_font(...)
    return self.text_widget:set_font(...)
  end

  function widget_bg:set_text(...)
    return self.text_widget:set_text(...)
  end

  function widget_bg:set_markup(...)
    return self.text_widget:set_markup(...)
  end

  widget_bg:_init_(args2)
  return widget_bg
end


return setmetatable(module, { __call = function(_, ...) return module.widget(...) end })
