--[[
     Licensed under GNU General Public License v2
      * (c) 2014  Yauheni Kirylau
--]]

local wibox = require("wibox")
--local gears = require("gears")
local beautiful = require("beautiful")

local h_table = require("utils.table")


local function get_color(color_n)
  return beautiful[color_n]
end


local common = {}


function common.widget(args)
  args = args or {}

  local show_icon = args.show_icon or beautiful.show_widget_icon
  local force_no_bgimage = args.force_no_bgimage or false
  local widget = {}
    widget.lie_layout = wibox.layout.fixed.horizontal()
    if show_icon then
        widget.icon_widget = wibox.widget.imagebox()
        widget.icon_widget:set_resize(beautiful.hidpi or false)
        widget.lie_layout:add(widget.icon_widget)
    end
      widget.text_widget = wibox.widget.textbox('')
    widget.lie_layout:add(widget.text_widget)
  widget.widget_bg = wibox.widget.background()
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
    if not force_no_bgimage then
      local bg = select(1, ...)
      if bg == beautiful.panel_widget_bg_warning and bgimage_warning then
        self:set_bgimage(bgimage_warning)
        return
      elseif bg == beautiful.panel_widget_bg_error and bgimage_error then
        self:set_bgimage(bgimage_error)
        return
      elseif
        bg ~= beautiful.panel_widget_bg_warning and
        bg ~= beautiful.panel_widget_bg_error and
        bgimage_normal
      then
        self:set_bgimage(bgimage_normal)
      end
    end
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

  if bgimage_normal and not force_no_bgimage then
    widget.widget_bg:set_bgimage(bgimage_normal)
  end

  setmetatable(widget.widget_bg, { __index = widget.text_widget })
  return setmetatable(widget, { __index = widget.widget_bg })
end


function common.centered(widget)
  if not widget then widget=wibox.widget.background() end
  local centered_widget = {}
  centered_widget.widget = widget

  local horizontal_align = wibox.layout.align.horizontal()
  horizontal_align:set_second(widget)
  local vertical_align = wibox.layout.align.vertical()
  vertical_align:set_second(horizontal_align)

  setmetatable(centered_widget, { __index = centered_widget.widget })
  return setmetatable(centered_widget, { __index = vertical_align })
end




function common.make_separator(separator_character, args)

  local bgimage_normal = beautiful[
    'widget_decoration_image_' .. separator_character]

  local separator_alias = beautiful['widget_decoration_' .. separator_character]
  if separator_alias then
    return common.make_separator(separator_alias, args)
  end

  args = args or {}
  local bg = args.bg or beautiful.panel_bg or beautiful.bg or "#000000"
  local fg = args.fg or get_color(args.color_n) or beautiful.fg
  local inverted = args.inverted or false

  if separator_character == 'sq' or bg==fg then
    separator_character = ' '
    inverted = not inverted
  end

  local widget = wibox.widget.background()
  if inverted then
    widget.set_fg, widget.set_bg = widget.set_bg, widget.set_fg
  end
  --@TODO: fix that:
  --widget:set_bg(bg)
  widget:set_fg(fg)
  widget:set_widget(wibox.widget.textbox(separator_character))


  return widget
end


function common.constraint(args)
  args = args or {}
  local strategy = args.strategy or "exact"
  local result = wibox.layout.constraint()
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
common.fixed = {}
function common.fixed.horizontal(widgets)
  return init_list_layout(wibox.layout.fixed.horizontal(), widgets)
end
function common.fixed.vertical(widgets)
  return init_list_layout(wibox.layout.fixed.vertical(), widgets)
end
common.flex = {}
function common.flex.horizontal(widgets)
  return init_list_layout(wibox.layout.flex.horizontal(), widgets)
end
function common.flex.vertical(widgets)
  return init_list_layout(wibox.layout.flex.vertical(), widgets)
end

common.align = {}
function common.align.init(layout, first, second, third, args)
  layout:set_first(first)
  layout:set_second(second)
  layout:set_third(third)
  if args then
    if args.expand then
      layout:set_expand(args.expand)
    end
  end
  return layout
end
function common.align.horizontal(...)
  return common.align.init(wibox.layout.align.horizontal(), ...)
end
function common.align.vertical(...)
  return common.align.init(wibox.layout.align.vertical(), ...)
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
    decorated.widget_list = {args.widget}
  else
    decorated.widget_list = args.widgets or {common.widget(args)}
  end
  decorated.widget = decorated.widget_list[1]
  for i, widget in ipairs(decorated.widget_list) do
    if widget.set_align then
      widget:set_align("right")
      widget:set_valign("top")
      --widget:set_wrap("char")
    end
  -- give set_bg and set_fg methods to ones don't have it:
    if (decorated.fg and not widget.set_fg) then
      decorated.widget_list[i] = setmetatable(wibox.widget.background(widget), widget)
    end
  end

  decorated.widget_layout = wibox.layout.fixed.vertical()

  if valign == "top" then
    decorated.internal_widget_layout = 
    common.align.horizontal(
        nil,
        decorated.widget_layout,
        common.constraint({width=args.padding or beautiful.panel_padding_bottom})
    )
  elseif valign == "bottom" then
    decorated.internal_widget_layout = common.align.vertical(
        nil,
        nil,
        common.align.horizontal(
            nil,
            decorated.widget_layout,
            common.constraint({width=args.padding or beautiful.panel_padding_bottom})
        )
    )
  end
  decorated.constraint = common.constraint({
    widget = decorated.internal_widget_layout,
    height = decorated.min_height,
    strategy = 'min',
  })
  decorated.lie_background =wibox.widget.background(
    decorated.constraint,
    decorated.bg
  )

  decorated.lie_layout = wibox.layout.flex.vertical()
  decorated.lie_layout:add(decorated.lie_background)

  setmetatable(decorated.constraint, { __index = decorated.widget })
  setmetatable(decorated.lie_layout, { __index = decorated.constraint })
  setmetatable(decorated,        { __index = decorated.lie_layout })

  --- Set widget color
  -- @param args. "fg", "bg", "name" - "err", "warn", "b", "f" or 1..16
  function decorated:set_color(args)
    args = args or {}
    local fg = args.fg
    local bg = args.bg
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
  local left_separators = args.left_separators or {} -- { 'arrl' }
  local right_separators = args.right_separators or {} -- { 'arrr' }

  local separator = common.make_separator(' ')

  if args.widget then
    decorated.widget_list = {args.widget}
  else
    decorated.widget_list = args.widgets or {common.widget(args)}
  end

  -- give set_bg and set_fg methods to ones don't have it:
  for i, widget in ipairs(decorated.widget_list) do
    if (decorated.fg and not widget.set_fg) or (decorated.bg and not widget.set_bg) then
      local bg_widget = setmetatable(wibox.widget.background(widget), widget)
      bg_widget.set_font = function(...)
        widget.set_font(...)
      end
      bg_widget.set_markup = function(...)
        widget.set_markup(...)
      end
      decorated.widget_list[i] = setmetatable(bg_widget, widget)
    end
  end

  decorated.widget = decorated.widget_list[1]
  decorated.lie_layout = wibox.layout.fixed.horizontal()
  decorated.lie_background = wibox.widget.background()
  decorated.lie_background:set_widget(decorated.lie_layout)
  decorated.wrap_layout = wibox.layout.flex.horizontal()
  decorated.wrap_layout:add(decorated.lie_background)

  for _, separator_id in ipairs(left_separators) do
    table.insert(
      decorated.left_separator_widgets,
      common.make_separator(separator_id, {inverted=true}))
  end
  for _, separator_id in ipairs(right_separators) do
    table.insert(
      decorated.right_separator_widgets,
      common.make_separator(separator_id, {inverted=true}))
  end

  setmetatable(decorated.wrap_layout, { __index = decorated.widget })
  setmetatable(decorated,        { __index = decorated.wrap_layout })

  --- Set widget color
  -- @param args. "fg", "bg", "name" - "err", "warn", "b", "f" or 1..16
  function decorated:set_color(args)
    args = args or {}
    local fg = args.fg
    local bg = args.bg
    if args.name then
      bg = get_color(args.name)
    else
      bg = args.bg
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
    for _, widget in ipairs(self.widget_list) do
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
  end

  --- Make widget visible again
  function decorated:show()
    for _, separator in ipairs(self.left_separator_widgets) do
      self.lie_layout:add(separator)
    end
    for i, each_widget in ipairs(self.widget_list) do
      self.lie_layout:add(each_widget)
      if i ~= #self.widget_list then
        self.lie_layout:add(separator)
      end
    end
    for _, separator in ipairs(self.right_separator_widgets) do
      self.lie_layout:add(separator)
    end
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
    return self.widget:set_font(...)
  end

  decorated:set_normal()
  decorated:show()
  return decorated
end


return common
