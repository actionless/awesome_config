--[[
     Licensed under GNU General Public License v2
      * (c) 2014  Yauheni Kirylau
--]]

local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local h_table = require("utils.table")


local function get_color(color_n)
  return beautiful[color_n]
end


local common = {}


function common.widget(args)
  args = args or {}

  local show_icon = args.show_icon or beautiful.show_widget_icon
  local widget = {}
    widget.lie_layout = wibox.layout.fixed.horizontal()
    if show_icon then
        widget.icon_widget = wibox.widget.imagebox()
        widget.icon_widget:set_resize(beautiful.hidpi or false)
        widget.lie_layout:add(widget.icon_widget)
    end
      widget.text_widget = wibox.widget.textbox('')
    widget.lie_layout:add(widget.text_widget)
  widget.widget_bg = wibox.container.background()
  widget.widget_bg:set_widget(widget.lie_layout)

  function widget:set_image(...)
    if self.icon_widget then
      return self.icon_widget:set_image(...)
    end
  end

  function widget:set_text(...)
    return self.text_widget:set_text(...)
  end

  function widget:set_markup(...)
    return self.text_widget:set_markup(...)
  end

  function widget:set_bg(...)
    self.widget_bg:set_bg(...)
  end

  function widget:set_fg(...)
    self.widget_bg:set_fg(...)
  end

  function widget:set_icon(name)
    if show_icon then
      local icon = beautiful.get()['widget_' .. name]
      --gears.debug.assert(icon, ":set_icon failed: icon is missing: " .. name)
      return self.icon_widget:set_image(icon)
    end
  end

  function widget:buttons(...)
    return self.widget:buttons(...)
  end

  function widget:show()
    self.widget_bg:set_widget(self.lie_layout)
  end

  function widget:hide()
    self.widget_bg:set_widget(nil)
  end

  setmetatable(widget.widget_bg, { __index = widget.text_widget })
  return setmetatable(widget, { __index = widget.widget_bg })
end


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


local function init_list_layout(layout, widgets)
  widgets = widgets or {}
  for _, widget in ipairs(widgets) do
    layout:add(widget)
  end
  return layout
end
common.flex = {}
function common.flex.horizontal(widgets)
  return init_list_layout(wibox.layout.flex.horizontal(), widgets)
end
function common.flex.vertical(widgets)
  return init_list_layout(wibox.layout.flex.vertical(), widgets)
end



function common.decorated(args)
  args = args or {}

  if args.horizontal or args.orientation == "horizontal" then
    return common.decorated_horizontal(args)
  end

  local decorated = {
    widget_list = {},
  }

  decorated.bg = args.bg or beautiful.panel_widget_bg or beautiful.fg or "#ffffff"
  decorated.fg = args.fg or beautiful.panel_widget_fg or beautiful.bg or "#000000"
  local valign = args.valign or "top"
  decorated.min_height = args.min_height or beautiful.left_widget_min_height

  if args.widget then
    decorated.lie_widget_list = {args.widget}
  else
    decorated.lie_widget_list = args.widgets or {common.widget(args)}
  end
  decorated.lie_widget = decorated.lie_widget_list[1]
  for i, widget in ipairs(decorated.lie_widget_list) do
    if widget.set_align then
      widget:set_align("right")
      widget:set_valign("top")
      --widget:set_wrap("char")
    end
  -- give set_bg and set_fg methods to ones don't have it:
    if (decorated.fg and not widget.set_fg) then
      decorated.lie_widget_list[i] = setmetatable(wibox.container.background(widget), widget)
    end
  end

  decorated.lie_widget_layout = wibox.layout.fixed.vertical()

  if valign == "top" then
    decorated.internal_widget_layout =
    wibox.layout.align.horizontal(
        nil,
        decorated.lie_widget_layout,
        common.constraint({width=args.padding or beautiful.panel_padding_bottom})
    )
  elseif valign == "bottom" then
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

  setmetatable(decorated.constraint, { __index = decorated.lie_widget })
  setmetatable(decorated.lie_layout, { __index = decorated.constraint })
  setmetatable(decorated,        { __index = decorated.lie_layout })

  --- Set widget color
  -- @param args. "fg", "bg", "name" - "err", "warn", "b", "f" or 1..16
  function decorated:set_color(color_args)
    color_args = color_args or {}
    local fg = color_args.fg
    local bg = color_args.bg
    for _, widget in ipairs(self.widget_list) do
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

    self.widget_layout:reset()
    self.constraint:set_height(0)
  end

  --- Make widget visible again
  function decorated:show()
    --self.visible = true
    if self._visible then return end
    self._visible = true
    for _, each_widget in ipairs(self.widget_list) do
      local horiz_layout = wibox.layout.align.horizontal()
      horiz_layout:set_right(each_widget)
      self.widget_layout:add(horiz_layout)
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

  decorated:set_normal()
  decorated:show()
  return decorated
end















function common.decorated_horizontal(args)
  local decorated = {
    left_separator_widgets = {},
    widget_list = {},
    right_separator_widgets = {},
  }

  args = args or {}
  decorated.bg = args.bg or beautiful.panel_widget_bg or beautiful.fg or "#ffffff"
  decorated.fg = args.fg or beautiful.panel_widget_fg or beautiful.bg or "#000000"

  local separator = wibox.widget.textbox(' ')

  if args.widget then
    decorated.lie_widget_list = {args.widget}
  else
    decorated.lie_widget_list = args.widgets or {common.widget(args)}
  end

  -- give set_bg and set_fg methods to ones don't have it:
  for i, widget in ipairs(decorated.lie_widget_list) do
    if (decorated.fg and not widget.set_fg) or (decorated.bg and not widget.set_bg) then
      local bg_widget = setmetatable(wibox.container.background(widget), widget)
      bg_widget.set_font = function(...)
        widget.set_font(...)
      end
      bg_widget.set_markup = function(...)
        widget.set_markup(...)
      end
      decorated.lie_widget_list[i] = setmetatable(bg_widget, widget)
    end
  end

  decorated.lie_visible = false
  decorated.lie_widget = decorated.lie_widget_list[1]
  decorated.lie_layout = wibox.layout.fixed.horizontal()
  decorated.lie_background = wibox.container.background()
  decorated.lie_background:set_widget(decorated.lie_layout)
  decorated.wrap_layout = wibox.layout.flex.horizontal()
  decorated.wrap_layout:add(decorated.lie_background)

  setmetatable(decorated.wrap_layout, { __index = decorated.lie_widget })
  setmetatable(decorated,        { __index = decorated.wrap_layout })

  --- Set widget color
  -- @param args. "fg", "bg", "name" - "err", "warn", "b", "f" or 1..16
  function decorated:set_color(color_args)
    color_args = color_args or {}
    local fg = color_args.fg
    local bg
    if color_args.name then
      bg = get_color(color_args.name)
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

  --- Make widget invisible
  function decorated:hide()
    self.lie_layout:reset()
    self.lie_visible = false
  end

  --- Make widget visible again
  function decorated:show()
    if self.lie_visible then return end
    for _, this_separator in ipairs(self.left_separator_widgets) do
      self.lie_layout:add(this_separator)
    end
    for i, each_widget in ipairs(self.lie_widget_list) do
      self.lie_layout:add(each_widget)
      if i ~= #self.lie_widget_list then
        self.lie_layout:add(separator)
      end
    end
    for _, this_separator in ipairs(self.right_separator_widgets) do
      self.lie_layout:add(this_separator)
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
    return self.lie_widget:set_font(...)
  end

  decorated:set_normal()
  decorated:show()
  return decorated
end


local AWESOME_METHODS = {
  "set_forced_height",
  "set_shape",
  "set_fg",
  "_private",
  "get_bg",
  "before_draw_children",
  "get_forced_height",
  "set_opacity",
  "get_shape_border_color",
  "set_tooltip",
  "get_fg",
  "set_shape_border_color",
  "index",
  "get_all_children",
  "fit",
  "_signals",
  "get_opacity",
  "widget_name",
  "set_bg",
  "get_widget",
  "emit_signal",
  "get_shape_clip",
  "set_bgimage",
  "set_children",
  "mt",
  "after_draw_children",
  "weak_connect_signal",
  "get_shape",
  "modulename",
  "set_shape_border_width",
  "get_shape_border_width",
  "set_shape_clip",
  "set_widget",
  "get_bgimage",
  "get_preferred_size",
  "get_children",
  "draw",
  "get_forced_width",
  "set_menu",
  "is_widget",
  "get_visible",
  "setup",
  "set_visible",
  "set_forced_width",
  "layout",

  --"add_signal",
  --"buttons",
  --"disconnect_signal",
  --"connect_signal",
}

function common.panel_shape(widget)
  local shaped = wibox.container.background(widget)
  shaped:set_shape(gears.shape.rounded_rect, beautiful.panel_widget_border_radius)
  shaped.shape_clip = true
  shaped.shape_border_width = beautiful.panel_widget_border_width or 0
  shaped.shape_border_color = beautiful.panel_widget_border_color or beautiful.border_normal
  return shaped
end

function common.newdecoration(args)
  args = args or {}
  local widget = args.widget
  local bg = args.bg
  local fg = args.fg
  local shape = args.shape
  local shape_args = args.shape_args or {}
  local background = wibox.container.background(widget, bg)
  background:set_fg(fg)
  background:set_shape(shape, table.unpack(shape_args))
  for k, v in pairs(widget) do
    if not h_table.hasvalue(AWESOME_METHODS, k) then
      background[k] = v
    end
  end
  return background
end


return common
