local wibox = require("wibox")
local beautiful = require("beautiful")

local awful = require("awful")
local config = require("actionless.config")
local helpers = require("actionless.helpers")
beautiful.init(config.status.theme_dir)
--beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/lcars_modern/theme.lua")


function get_color(color_n)
  return beautiful.color[color_n]
end


local common = {}


function common.widget(args)
  args = args or {}
  local show_icon = args.force_show_icon or beautiful.show_widget_icon
  --local inverted = args.inverted or false
  local widget = {}

  widget.text_widget = wibox.widget.textbox('')
  widget.text_bg = wibox.widget.background()
  widget.text_bg:set_widget(widget.text_widget)

  widget.icon_widget = wibox.widget.imagebox()
  widget.icon_widget:set_resize(false)
  widget.icon_bg = wibox.widget.background()
  widget.icon_bg:set_widget(widget.icon_widget)

  widget.widget = wibox.layout.fixed.horizontal()
  if show_icon then
    widget.widget:add(widget.icon_bg)
  end
  widget.widget:add(widget.text_bg)

  function widget:set_image(...)
    return widget.icon_widget:set_image(...)
  end

  function widget:set_text(...)
    return widget.text_widget:set_text(...)
  end

  function widget:set_markup(...)
    return widget.text_widget:set_markup(...)
  end

  function widget:set_bg(...)
    widget.text_bg:set_bg(...)
    widget.icon_bg:set_bg(...)
  end

  function widget:set_fg(...)
    widget.text_bg:set_fg(...)
    widget.icon_bg:set_fg(...)
  end

  if inverted then
    widget.set_fg, widget.set_bg = widget.set_bg, widget.set_fg
  end

  return setmetatable(widget, { __index = widget.widget })
end


function common.make_separator(separator_character, args)
  local separator_alias = beautiful['widget_decoration_' .. separator_character]
  if separator_alias then
    return common.make_separator(separator_alias, args)
  end

  args = args or {}
  local bg = args.bg
  local fg = args.fg or get_color(args.color_n) or beautiful.fg
  local inverted = args.inverted or false

  if separator_character == 'sq' then
    separator_character = ' '
    inverted = not inverted
  end

  local widget = wibox.widget.background()
  if inverted then
    widget.set_fg, widget.set_bg = widget.set_bg, widget.set_fg
  end
  widget:set_bg(bg)
  widget:set_fg(fg)
  widget:set_widget(wibox.widget.textbox(separator_character))
  return widget
end

function common.make_image_separator(image_path, args)
  args = args or {}
  local bg = args.bg

  local widget = wibox.widget.background()
  local separator_widget = wibox.widget.imagebox(image_path)
  separator_widget:set_resize(false)
  widget:set_bg(bg)
  widget:set_widget(separator_widget)
  return widget
end


function common.decorated(args)
  local decorated = {
    left_separator_widgets = {},
    widget_list = {},
    right_separator_widgets = {},
  }

  args = args or {}
  local fg = args.fg or get_color(args.color_n)
  local bg = args.bg or beautiful.panel_bg
  local widget_inverted = args.widget_inverted
  if widget_inverted then
    args.inverted = widget_inverted
  end
  local left_separators = args.left or { 'arrl' }
  local right_separators = args.right or { 'arrr' }

  if args.widget then
    decorated.widget_list = {args.widget}
  else
    decorated.widget_list = args.widgets
      or {common.widget(args)}
  end

  decorated.widget = decorated.widget_list[1]
  decorated.wibox = wibox.layout.fixed.horizontal()

  for _, separator_id in ipairs(left_separators) do
    local separator = common.make_separator(separator_id, args)
    table.insert(decorated.left_separator_widgets, separator)
    decorated.wibox:add(separator)
  end
  for _, each_widget in ipairs(decorated.widget_list) do
    decorated.wibox:add(each_widget)
  end
  for _, separator_id in ipairs(right_separators) do
    local separator = common.make_separator(separator_id, args)
    table.insert(decorated.right_separator_widgets, separator)
    decorated.wibox:add(separator)
  end

  setmetatable(decorated.wibox, { __index = decorated.widget })
  setmetatable(decorated,       { __index = decorated.wibox })
  function     decorated:set_color(args)
    args = args or {}
    local fg = args.fg or get_color(args.color_n)
    local bg = args.bg or beautiful.panel_bg
    for _, widget in ipairs(helpers.tables_sum({
      self.left_separator_widgets,
      self.widget_list,
      self.right_separator_widgets
    })) do
      if widget_inverted then
        if bg and widget.set_fg then
          widget:set_fg(bg) end
        if fg and widget.set_bg then
          widget:set_bg(fg) end
      else
        if fg and widget.set_fg then
          widget:set_fg(fg) end
        if bg and widget.set_bg then
          widget:set_bg(bg) end
      end
    end
  end

  decorated:set_color({fg=fg, bg=bg})
  return decorated
end


return common
