--[[
     Licensed under GNU General Public License v2
      * (c) 2014  Yauheni Kirylau
--]]

local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local config = require("actionless.config")
local helpers = require("actionless.helpers")
local h_table = require("actionless.table")
local iconfont = require("actionless.iconfont")

beautiful.init(config.awesome.theme_dir)


local function get_color(color_n)
  return beautiful[color_n]
end


local common = {}


function common.widget(args)
  args = args or {}
  local show_icon = args.show_icon or beautiful.show_widget_icon
  local use_iconfont = args.use_iconfont or beautiful.use_iconfont
  local force_no_bgimage = args.force_no_bgimage or false
  local widget = {}
    widget.layout = wibox.layout.fixed.horizontal()
    if show_icon then
      if use_iconfont then
        widget.iconfont_widget = wibox.widget.textbox()
        widget.iconfont_widget:set_font(beautiful.iconfont)
        widget.layout:add(widget.iconfont_widget)
      else
        widget.icon_widget = wibox.widget.imagebox()
        widget.icon_widget:set_resize(false)
        widget.layout:add(widget.icon_widget)
      end
    end
      widget.text_widget = wibox.widget.textbox('')
    widget.layout:add(widget.text_widget)
  widget.widget_bg = wibox.widget.background()
  widget.widget_bg:set_widget(widget.layout)

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
      if use_iconfont then
        local symbol = iconfont.get_symbol(name)
        if symbol then
          return self.iconfont_widget:set_text(" " .. symbol .. " ")
        end
      end
      local icon = beautiful.get()['widget_' .. name]
      gears.debug.assert(icon, ":set_icon failed: icon is missing: " .. name)
      return self.icon_widget:set_image(icon)
    end
  end

  function widget:buttons(...)
    return self.widget:buttons(...)
  end

  function widget:show()
    self.widget_bg:set_widget(self.layout)
  end

  function widget:hide()
    self.widget_bg:set_widget(nil)
  end

  local widget_bgimage_path = beautiful['widget_decoration_image_bg']
  if widget_bgimage_path and not force_no_bgimage then
    widget.widget_bg:set_bgimage(widget_bgimage_path)
  end

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


function common.bordered(widget, args)
  if not widget then return nil end
  local margin = args.margin or 0
  local padding = args.padding or 0
  local obj = {}
      obj.padding = wibox.layout.margin()
      obj.padding:set_widget(widget)
      obj.padding:set_margins(padding)
    obj.background = wibox.widget.background()
    obj.background:set_widget(obj.padding)
  obj.margin = wibox.layout.margin()
  obj.margin:set_widget(obj.background)
  obj.margin:set_margins(margin)
  setmetatable(obj, { __index = obj.margin })

  function obj:set_bg(...)
    obj.background:set_bg(...)
  end

  function obj:set_fg(...)
    obj.background:set_fg(...)
  end

  return obj
end



function common.make_image_separator(image_path, args)
  if not image_path then return false end
  args = args or {}
  local bg = args.bg
  local widget = wibox.widget.background()
  local separator_widget = wibox.widget.imagebox(image_path)
  separator_widget:set_resize(false)
  widget:set_bg(bg)
  widget:set_widget(separator_widget)
  return widget
end


function common.make_separator(separator_character, args)
  local image_path = beautiful['widget_decoration_image_' .. separator_character]
  if image_path then
    return common.make_image_separator(image_path, args)
  end
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


function common.decorated(args)
  local decorated = {
    left_separator_widgets = {},
    widget_list = {},
    right_separator_widgets = {},
  }

  args = args or {}
  local bg = args.bg or beautiful.panel_widget_bg or beautiful.fg or "#ffffff"
  local fg = args.fg or beautiful.panel_widget_fg or beautiful.bg or "#000000"
  local left_separators = args.left_separators or { 'arrl' }
  local right_separators = args.right_separators or { 'arrr' }

  if args.widget then
    decorated.widget_list = {args.widget}
  else
    decorated.widget_list = args.widgets or {common.widget(args)}
  end

  decorated.widget = decorated.widget_list[1]
  decorated.layout = wibox.layout.fixed.horizontal()

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

  setmetatable(decorated.layout, { __index = decorated.widget })
  setmetatable(decorated,        { __index = decorated.layout })

  --- Set widget color
  -- @param args. "fg", "bg", "name" - "err", "warn", "b", "f" or 1..16
  function decorated:set_color(args)
    args = args or {}
    local fg = args.fg
    local bg
    if args.name then
      bg = get_color(args.name)
    else
      bg = args.bg
    end
    for _, widget in ipairs(h_table.sum({
      self.left_separator_widgets,
      self.right_separator_widgets
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

  --- Make widget invisible
  function decorated:hide()
    self.layout:reset()
  end

  --- Make widget visible again
  function decorated:show()
    for _, separator in ipairs(self.left_separator_widgets) do
      self.layout:add(separator)
    end
    for _, each_widget in ipairs(self.widget_list) do
      self.layout:add(each_widget)
    end
    for _, separator in ipairs(self.right_separator_widgets) do
      self.layout:add(separator)
    end
  end

  decorated:set_color({fg=fg, bg=bg})
  decorated:show()
  return decorated
end


return common
