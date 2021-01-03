--[[
     Licensed under GNU General Public License v2
      * (c) 2014-2021  Yauheni Kirylau
--]]

local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")


local TRANSPARENT = "#00000000"


local module = {}


function module.text_progressbar(args)
  local progress_fg = args.progress_fg
    or beautiful.panel_widget_progress_fg or beautiful.bg_focus
  local progress_bg = args.progress_bg
    or beautiful.panel_widget_progress_bg or beautiful.bg_normal
  local progress_border_width = args.progress_border_width
    or beautiful.panel_widget_progress_border_width or 1
  local progress_border_color = args.progress_border_color
    or beautiful.panel_widget_progress_border_color or progress_bg

  local widget_margin_left = beautiful.panel_widget_spacing or dpi(3)
  local widget_margin_right = beautiful.panel_widget_spacing or dpi(3)

  local text_margin_left = dpi(4)
  local text_margin_right = dpi(4)
  local text_margin_bottom = dpi(5)
  --local progress_margin_bottom = dpi(2)
  local progress_margin_bottom = dpi(1)
  local progress_height = dpi(3)
  local progress_border_radius = beautiful.panel_widget_border_radius * (
     progress_height / beautiful.basic_panel_height
  ) * 2
  local progress_width = beautiful.panel_widget_width or dpi(20)

  local widget = wibox.widget{
    {
      {
        {
          nil,
          {
            {
              nil,
              {
                  id = "imagebox",
                  widget = wibox.widget.imagebox,
              },
              nil,
              layout = wibox.layout.align.vertical,
              expand = 'none',
            },
            {
                id = "textbox",
                widget = wibox.widget.textbox,
            },
            layout = wibox.layout.fixed.horizontal,
          },
          nil,
          layout = wibox.layout.align.horizontal,
          expand = 'none',
        },
        left  = text_margin_left,
        right = text_margin_right,
        bottom = text_margin_bottom,
        layout = wibox.container.margin,
      },
      {
        {
          {
            {
              id = "progressbar",
              max_value     = 1,
              margins      = {
                bottom=progress_margin_bottom,
                top=(
                  beautiful.panel_height - progress_margin_bottom -
                  progress_height - beautiful.panel_padding_bottom
                ),
              },
              color = progress_fg,
              background_color = progress_bg,
              border_width = progress_border_width,
              border_color = progress_border_color,
              forced_width = progress_width,
              shape = function(c, w, h) return gears.shape.rounded_rect(
                c, w, h, progress_border_radius
              ) end,
              widget = wibox.widget.progressbar,
            },
            layout = wibox.layout.fixed.vertical,
          },
          bg = args.bg or TRANSPARENT,
          layout = wibox.container.background,
        },
        height  = progress_height,
        strategy = 'exact',
        layout = wibox.container.constraint,
      },
      layout = wibox.layout.stack
    },
    left=widget_margin_left,
    right=widget_margin_right,
    layout = wibox.container.margin,
  }

  widget.textbox = widget:get_children_by_id('textbox')[1]
  widget.progressbar = widget:get_children_by_id('progressbar')[1]

  local show_icon = args.show_icon
  if show_icon == nil then
    show_icon = beautiful.show_widget_icon
  end
  if show_icon then
    widget.icon_widget = widget:get_children_by_id('imagebox')[1]
  end

  function widget:set_image(image)
    if not self.icon_widget then
      return
    end
    if (image == self.old_image) and (self.textbox.text == self.old_text) then
      return
    end
    self.old_image = image
    self.old_text = self.textbox.text

    image = image and gears.surface.load(image)
    if not image then
      return
    end
    local need_resize = image.height > (
      beautiful.basic_panel_height - progress_height - progress_margin_bottom*2
    )
    self.icon_widget:set_resize(need_resize)
    if need_resize then
      if self.textbox.text and self.textbox.text ~= '' then
        local ratio = beautiful.basic_panel_height / image.height
        self.icon_widget.forced_width = gears.math.round(image.width * ratio)
      else
        self.icon_widget.forced_width = nil
      end
      self.icon_widget.forced_height = gears.math.round(beautiful.basic_panel_height)
    end
    self.icon_widget:set_image(image)
  end

  function widget:set_text(text)
    self.textbox:set_text(text)
    if self.old_image then
      self:set_image(self.old_image)
    end
  end

  return widget
end

return setmetatable(module, { __call = function(_, ...) return module.text_progressbar(...) end })
