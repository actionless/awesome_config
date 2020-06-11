--[[
     Licensed under GNU General Public License v2
      * (c) 2014  Yauheni Kirylau
--]]

local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local h_table = require("actionless.util.table")

local TRANSPARENT = "#00000000"


local common = {}


function common.centered(widget)
  if not widget then widget=wibox.container.background() end
  local centered_widget = {}
  centered_widget.widget = widget

  local horizontal_align = wibox.layout.align.horizontal()
  horizontal_align:set_second(widget)
  local vertical_align = wibox.layout.align.vertical()
  vertical_align:set_second(horizontal_align)

  setmetatable(centered_widget, { __index = centered_widget.widget })
  return setmetatable(centered_widget, { __index = vertical_align })
end


function common.constraint(args)
  args = args or {}
  local strategy = args.strategy or "exact"
  local result = wibox.container.constraint()
  result:set_strategy(strategy)
  if args.width then
    result:set_width(args.width)
  end
  if args.height then
    result:set_height(args.height)
  end
  if args.widget then
    result:set_widget(args.widget)
  end
  return result
end


function common.set_panel_shape(bg_widget, args)
  args = args or {}
  bg_widget.shape_clip = true
  bg_widget.shape = function(c, w, h) return gears.shape.rounded_rect(c, w, h, beautiful.panel_widget_border_radius) end
  bg_widget.shape_border_width = args.border_width or beautiful.panel_widget_border_width or 0
  bg_widget.shape_border_color = args.border_color or beautiful.panel_widget_border_color or beautiful.border_normal
  return bg_widget
end


function common.panel_shape(widget, args)
  args = args or {}
  local shaped = wibox.container.background(widget)
  common.set_panel_shape(shaped, args)
  setmetatable(shaped,        { __index = widget })
  return shaped
end


--[[
--------------------------------------------------------------------------------
         Common widget
--------------------------------------------------------------------------------
--]]

function common.widget(args)
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
    if not self.icon_widget then
      return
    end
    if (image == self.old_image) then
      return
    end
    self.old_image = image
    image = image and gears.surface.load(image)
    if not image then
      return
    end
    self.icon_widget:set_resize(image.height > beautiful.basic_panel_height)
    --local ratio = beautiful.basic_panel_height / image.height
    --self.icon_widget.forced_width = math.ceil(image.width * ratio)
    self.icon_widget:set_image(image)
  end

  function widget_bg:set_font(...)
    return self.text_widget:set_font(...)
  end

  widget_bg.text_widget.lie_set_text = widget_bg.text_widget.set_text
  function widget_bg.text_widget:set_text(text, ...)
    if not self.icon_widget and (not text or text == '') then
      widget_bg.visible = false
    else
      widget_bg.visible = true
      return self:lie_set_text(text, ...)
    end
  end

  widget_bg.text_widget.lie_set_markup = widget_bg.text_widget.set_markup
  function widget_bg.text_widget:set_markup(text, ...)
    if not self.icon_widget and (not text or text == '') then
      widget_bg.visible = false
    else
      widget_bg.visible = true
      return self:lie_set_markup(text, ...)
    end
  end

  function widget_bg:set_text(...)
    return self.text_widget:set_text(...)
  end

  function widget_bg:set_markup(...)
    return self.text_widget:set_markup(...)
  end

  function widget_bg:set_icon(name)
    if self.icon_widget then
      local icon = beautiful.get()['widget_' .. name]
      gears.debug.assert(icon, ":set_icon failed: icon is missing: " .. name)
      return self.icon_widget:set_image(icon)
    end
  end

  if args.text then
    widget_bg:set_text(args.text)
  end
  widget_bg:set_font(args.font or beautiful.panel_widget_font or beautiful.font)

  return widget_bg
end


--[[
--------------------------------------------------------------------------------
         Decorated widget entrypoint
--------------------------------------------------------------------------------
--]]

function common.decorated(args)
  args = args or {}
  if args.horizontal == nil and args.orientation == nil then
    args.horizontal = true
  end
  if args.horizontal or args.orientation == "horizontal" then
    return common.decorated_horizontal(args)
  else
    return common.decorated_vertical(args)
  end
end



--[[
--------------------------------------------------------------------------------
         Vertical decorated widget
--------------------------------------------------------------------------------
--]]

function common.decorated_vertical(args)
  args = args or {}

  local decorated = {
    lie_widget_list = {},
    bg = args.bg or beautiful.panel_widget_bg or beautiful.fg or "#ffffff",
    fg = args.fg or beautiful.panel_widget_fg or beautiful.bg or "#000000",
    min_height = args.min_height or beautiful.left_widget_min_height,
    valign = args.valign or "top",
  }

  if args.widgets then
    decorated.lie_widget_list = args.widgets
  elseif args.widget then
    decorated.lie_widget_list = {args.widget}
  else
    decorated.lie_widget_list = {common.widget(args)}
  end
  if args.widget then
    decorated.lie_widget = args.widget
  else
    decorated.lie_widget = decorated.lie_widget_list[1]
  end

  for i, widget in ipairs(decorated.lie_widget_list) do
    if widget.set_valign then
      --widget:set_align("right")
      widget:set_valign("top")
      --widget:set_wrap("char")
    end
    if widget.set_font then
      widget:set_font(args.font or beautiful.panel_widget_font or beautiful.font)
    end
    -- give set_bg and set_fg methods to ones don't have it:
    if (decorated.fg and not widget.set_fg) or (decorated.bg and not widget.set_bg) then
      decorated.lie_widget_list[i] = setmetatable(wibox.container.background(widget), widget)
    end
  end

  decorated.lie_widget_layout = wibox.layout.fixed.vertical()
  if decorated.valign == "top" then
    decorated.internal_widget_layout =
    wibox.layout.align.horizontal(
        nil,
        decorated.lie_widget_layout,
        common.constraint({width=args.padding or beautiful.panel_padding_bottom})
    )
  elseif decorated.valign == "bottom" then
    decorated.internal_widget_layout = wibox.layout.align.vertical(
        nil,
        nil,
        wibox.layout.align.horizontal(
            nil,
            decorated.lie_widget_layout,
            common.constraint({width=args.padding or beautiful.panel_padding_bottom})
        )
    )
  end

  decorated.constraint = common.constraint({
    widget = decorated.internal_widget_layout,
    height = decorated.min_height,
    strategy = 'min',
  })
  decorated.lie_background =wibox.container.background(
    decorated.constraint,
    decorated.bg
  )
  decorated.lie_layout = wibox.layout.flex.vertical()
  decorated.lie_layout:add(decorated.lie_background)


  function decorated:init()
    self:set_normal()
    self:show()
  end

  function decorated:set_text(...)
    return self.lie_widget:set_text(...)
  end

  function decorated:set_markup(...)
    return self.lie_widget:set_markup(...)
  end

  --- Set widget color
  -- @param args. "fg", "bg", "name" - "err", "warn", "b", "f" or 1..16
  function decorated:set_color(color_args)
    color_args = color_args or {}
    local fg = color_args.fg
    local bg = color_args.bg
    for _, widget in ipairs(self.lie_widget_list) do
      widget:set_fg(fg)
      --widget:set_bg(bg)
    end
    if bg then
      self.lie_background:set_bg(bg)
    end
  end

  function decorated:set_bg(bg)
    return self:set_color({bg=bg})
  end

  function decorated:set_fg(fg)
    return self:set_color({fg=fg})
  end

  --- Make widget invisible
  function decorated:hide()
    --self.visible = false
    if not self._visible then return end
    self._visible = false

    self.lie_widget_layout:reset()
    self.constraint:set_height(0)
  end

  --- Make widget visible again
  function decorated:show()
    --self.visible = true
    if self._visible then return end
    self._visible = true
    for _, each_widget in ipairs(self.lie_widget_list) do
      local horiz_layout = wibox.layout.align.horizontal()
      horiz_layout:set_right(each_widget)
      self.lie_widget_layout:add(horiz_layout)
    end
    self.constraint:set_height(self.min_height)
  end

  function decorated:set_normal()
    self:set_color({fg=self.fg, bg=self.bg})
  end

  function decorated:set_warning()
    self:set_color({
      bg=beautiful.panel_widget_bg_warning,
      fg=beautiful.panel_widget_fg_warning
    })
  end

  function decorated:set_error()
    self:set_color({
      bg=beautiful.panel_widget_bg_error,
      fg=beautiful.panel_widget_fg_error
    })
  end

  function decorated:set_disabled()
    self:set_color({
      bg=beautiful.panel_widget_bg_disabled,
      fg=beautiful.panel_widget_fg_disabled
    })
  end

  decorated:init()
  --setmetatable(decorated.constraint, { __index = decorated.lie_widget })
  setmetatable(decorated.lie_layout, { __index = decorated.constraint })
  setmetatable(decorated,        { __index = decorated.lie_layout })
  return decorated
end




--[[
--------------------------------------------------------------------------------
         Horizontal decorated widget
--------------------------------------------------------------------------------
--]]

function common.decorated_horizontal(args)
  local decorated = {
    left_separator_widgets = {},
    lie_widget_list = {},
    right_separator_widgets = {},
  }

  args = args or {}
  decorated.bg = args.bg or beautiful.panel_widget_bg or beautiful.fg or "#ffffff"
  decorated.fg = args.fg or beautiful.panel_widget_fg or beautiful.bg or "#000000"

  local spacing = beautiful.panel_widget_spacing or 0
  if args.spacing ~= nil then spacing=args.spacing end
  local separator = spacing and common.constraint{width = spacing}
  if args.margin_left then
    decorated.left_separator_widgets = {common.constraint{width = args.margin_left, }}
  end
  if args.margin_right then
    decorated.right_separator_widgets = {common.constraint{width = args.margin_right, }}
  end

  if args.widgets then
    decorated.lie_widget_list = args.widgets
  elseif args.widget then
    decorated.lie_widget_list = {args.widget}
  else
    decorated.lie_widget_list = {common.widget(args)}
  end
  if args.widget then
    decorated.lie_widget = args.widget
  else
    decorated.lie_widget = decorated.lie_widget_list[1]
  end

  -- give set_bg and set_fg methods to ones don't have it:
  for i, widget in ipairs(decorated.lie_widget_list) do
    if widget.set_font then
      widget:set_font(args.font or beautiful.panel_widget_font or beautiful.font)
    end
    if (decorated.fg and not widget.set_fg) or (decorated.bg and not widget.set_bg) then
      local bg_widget = setmetatable(wibox.container.background(widget), widget)
      if widget.set_font then
        bg_widget.set_font = function(...)
          widget.set_font(...)
        end
      end
      bg_widget.set_markup = function(...)
        widget.set_markup(...)
      end
      decorated.lie_widget_list[i] = bg_widget
      --decorated.lie_widget_list[i] = setmetatable(bg_widget, widget)
    end
  end

  decorated.lie_visible = false
  decorated.lie_layout = wibox.layout.fixed.horizontal()
  --decorated.lie_layout.fill_space = true
  decorated.lie_background = wibox.container.background()
  decorated.lie_background:set_widget(decorated.lie_layout)
  --decorated.wrap_layout = wibox.layout.flex.horizontal()
  decorated.wrap_layout = wibox.layout.fixed.horizontal()
  decorated.wrap_layout:add(decorated.lie_background)
  if args.panel_shape then
    decorated.lie_background = common.set_panel_shape(decorated.lie_background)
  end

  setmetatable(decorated,        { __index = decorated.wrap_layout })

  --- Set widget color
  -- @param args. "fg", "bg", "name" - "err", "warn", "b", "f" or 1..16
  function decorated:set_color(color_args)
    color_args = color_args or {}
    local fg = color_args.fg
    local bg
    if color_args.name then
      bg = beautiful[color_args.name]
    else
      bg = color_args.bg
    end
    for _, widget in ipairs(h_table.flat({
      self.left_separator_widgets,
      self.right_separator_widgets,
      {decorated.lie_background}
    })) do
      if fg and widget.set_fg then
        widget:set_fg(beautiful.panel_bg)
      end
      if bg and widget.set_bg then
        widget:set_bg(bg)
      end
    end
    for _, widget in ipairs(self.lie_widget_list) do
      if fg and widget.set_fg then
        widget:set_fg(fg) end
      if bg and widget.set_bg then
        widget:set_bg(bg) end
    end
  end

  function decorated:set_bg(bg)
    return self:set_color({bg=bg})
  end

  function decorated:set_fg(fg)
    return self:set_color({fg=fg})
  end

  function decorated:hide()
    self.lie_layout:reset()
    if #self.left_separator_widgets > 0 then
      self.wrap_layout:remove_widgets(
        h_table.unpack(self.left_separator_widgets)
      )
    end
    if #self.right_separator_widgets > 0 then
      self.wrap_layout:remove_widgets(
        h_table.unpack(self.right_separator_widgets)
      )
    end
    self.lie_visible = false
  end

  function decorated:show()
    if self.lie_visible then return end
    for _, this_separator in ipairs(self.left_separator_widgets) do
      self.wrap_layout:insert(1, this_separator)
    end
    for i, each_widget in ipairs(self.lie_widget_list) do
      self.lie_layout:add(each_widget)
      if separator and i ~= #self.lie_widget_list then
        self.lie_layout:add(separator)
      end
    end
    for _, this_separator in ipairs(self.right_separator_widgets) do
      self.wrap_layout:add(this_separator)
    end
    self.lie_visible = true
  end

  function decorated:set_normal()
    self:set_color({fg=self.fg, bg=self.bg})
  end

  function decorated:set_warning()
    self:set_color({
      bg=beautiful.panel_widget_bg_warning,
      fg=beautiful.panel_widget_fg_warning
    })
  end

  function decorated:set_error()
    self:set_color({
      bg=beautiful.panel_widget_bg_error,
      fg=beautiful.panel_widget_fg_error
    })
  end

  function decorated:set_disabled()
    self:set_color({
      bg=beautiful.panel_widget_bg_disabled,
      fg=beautiful.panel_widget_fg_disabled
    })
  end

  function decorated:set_font(...)
    if self.lie_widget.set_font then
      return self.lie_widget:set_font(...)
    end
  end

  function decorated:get_text(...)
    return self.lie_widget:get_text(...)
  end

  function decorated:set_text(...)
    return self.lie_widget:set_text(...)
  end

  function decorated:set_markup(...)
    return self.lie_widget:set_markup(...)
  end

  function decorated:set_image(...)
    return self.lie_widget:set_image(...)
  end

  decorated:set_normal()
  decorated:show()
  return decorated
end


function common.text_progressbar(args)
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
  local progress_width = beautiful.panel_widget_width or dpi(20)
  local progress_border_radius = beautiful.panel_widget_border_radius * (
     progress_height / beautiful.basic_panel_height
  ) * 2

  local widget = wibox.widget{
    {
      {
        {
            id = "progressbar",
            max_value     = 1,
            forced_width  = progress_width,
            margins      = {
              bottom=progress_margin_bottom,
              top=beautiful.panel_height - progress_margin_bottom - progress_height - beautiful.panel_padding_bottom,
            },
            color = progress_fg,
            background_color = progress_bg,
            border_width = progress_border_width,
            border_color = progress_border_color,
            shape         = function(c, w, h) return gears.shape.rounded_rect(
                              c, w, h, progress_border_radius
                            ) end,
            widget        = wibox.widget.progressbar,
        },
        id = "p1",
        bg = args.bg or TRANSPARENT,
        layout = wibox.container.background,
      },
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
              id = "t4",
              layout = wibox.layout.align.vertical,
              expand = 'none',
            },
            {
                id = "textbox",
                widget = wibox.widget.textbox,
            },
            id = "t3",
            layout = wibox.layout.fixed.horizontal,
          },
          nil,
          id = "t2",
          layout = wibox.layout.align.horizontal,
          expand = 'none',
        },
        id = "t1",
        left  = text_margin_left,
        right = text_margin_right,
        bottom = text_margin_bottom,
        layout = wibox.container.margin,
      },
      id = "w1",
      layout = wibox.layout.stack
    },
    id = "w0",
    left=widget_margin_left,
    right=widget_margin_right,
    layout = wibox.container.margin,
  }

  widget.textbox = widget.w1.t1.t2.t3.textbox
  widget.progressbar = widget.w1.p1.progressbar

  local show_icon = args.show_icon
  if show_icon == nil then
    show_icon = beautiful.show_widget_icon
  end
  if show_icon then
    widget.icon_widget = widget.w1.t1.t2.t3.t4.imagebox
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
        self.icon_widget.forced_width = math.ceil(image.width * ratio)
      else
        self.icon_widget.forced_width = nil
      end
      self.icon_widget.forced_height = math.ceil(beautiful.basic_panel_height)
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


return common
