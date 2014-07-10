local wibox = require("wibox")
local beautiful = require("beautiful")

local awful = require("awful")
local config = require("actionless.config")
beautiful.init(config.status.theme_dir)


local common = {}

function common.widget(force_show_icon)
  local show_icon = force_show_icon or beautiful.show_widget_icon
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

  return setmetatable(widget, { __index = widget.widget })
end


function common.make_text_separator_legacy(separator_character, bg, fg)
  --'<span font="monospace 17">' .. separator_character .. '</span>'))
  local fg = fg or beautiful.panel_fg
  local widget = wibox.widget.background()
  if separator_character == 'sq' then
    separator_character = ' '
    function widget:set_fg(...) widget:set_bg(...) end
  else
    local bg = bg or beautiful.panel_bg
    widget:set_bg(bg)
  end
  widget:set_fg(fg)
  widget:set_widget(wibox.widget.textbox(separator_character))
  return widget
end

function common.make_text_separator(separator_character, args)
  args = args or {}
  local color_n = args.color_n
  local bg = args.bg or beautiful.color.f
  local fg = args.fg or beautiful.color[color_n] or beautiful.color.b
  local widget = wibox.widget.background()
  if separator_character == 'sq' then
    separator_character = ' '
    function widget:set_fg(...) widget:set_bg(...) end
  else
    local bg = bg or beautiful.panel_bg
    widget:set_bg(bg)
  end
  widget:set_fg(fg)
  widget:set_widget(wibox.widget.textbox(separator_character))
  return widget
end

function common.make_arrow_separator(direction, color_n)
  local widget = wibox.widget.background()
  local separator_widget
  if not beautiful.widget_use_text_decorations then
    widget:set_bg(beautiful.color.b)
    separator_widget = wibox.widget.imagebox(beautiful.arr[direction][color_n])
    separator_widget:set_resize(false)
  end
  widget:set_widget(separator_widget)
  return widget
end

function common.make_separator_new(direction, color_n)
  if direction == 'l' or direction == 'r' then
    return common.make_arrow_separator(direction, color_n)
  else
    -- @TODO:
    return common.make_separator(direction)
  end
end

function common.make_image_separator(separator_id)
  local bg = bg or beautiful.panel_bg
  local widget = wibox.widget.background()
  widget:set_bg(bg)
  local image_widget = wibox.widget.imagebox(beautiful[image_name])
  image_widget:set_resize(false)
  widget:set_widget(image_widget)
  return widget
end

function common.make_separator(separator_id)
  if separator_id == 'arrl' or separator_id == 'arrr' then
    if beautiful.widget_use_text_decorations then
      return common.make_text_separator(
        beautiful['widget_decoration_' .. separator_id])
    else
      return common.make_image_separator(separator_id)
    end
  elseif separator_id == 'separator' then
    return common.make_text_separator(' ')
  end
end

function common.set_separator_color(widget, color_id, separator_id)
  if separator_id == 'l' or separator_id == 'r' then
    if beautiful.widget_use_text_decorations then
      widget:set_fg(beautiful.color[color_id])
    else
      widget.widget:set_image(beautiful.arr[separator_id][color_id])
    end
  else
    widget:set_bg(beautiful.color[color_id])
  end
end



function common.decorated(args)
  local decorated = {}

  local args = args or {}
  local left_separators = args.left or { 'l' }
  local right_separators = args.right or { 'r' }
  local color_n = args.color_n or 'f'

  decorated.widget = args.widget or common.widget()
  decorated.widget_list = args.widgets or {}

  decorated.wibox = wibox.layout.fixed.horizontal()

  local separator
  for _, separator_id in ipairs(left_separators) do
    separator = common.make_separator_new(separator_id, color_n)
    decorated.wibox:add(separator)
  end
  decorated.wibox:add(decorated.widget)
  for _, each_widget in ipairs(decorated.widget_list) do
  --  decorated.wibox:add(each_widget)
  end
  for _, separator_id in ipairs(right_separators) do
    separator = common.make_separator_new(separator_id, color_n)
    decorated.wibox:add(separator)
  end

  function decorated:set_color(color_id)
    for i, separator_id in ipairs(left_separators) do
      common.set_separator_color(
        decorated.wibox.widgets[i],
        color_id,
        separator_id)
    end
    for i, separator_id in ipairs(right_separators) do
      common.set_separator_color(
        decorated.wibox.widgets[#left_separators + 1 + i],
        color_id,
        separator_id)
    end
    for _, each_widget in ipairs(decorated.widget_list) do
      if each_widget.set_fg then
        each_widget:set_bg(beautiful.color[color_id])
        each_widget:set_fg(beautiful.color.b)
      end
    end
    if self.widget.set_fg then
      self.widget:set_bg(beautiful.color[color_id])
      self.widget:set_fg(beautiful.color.b)
    end
  end

  if color_n then decorated:set_color(color_n) end
  setmetatable(decorated.wibox, { __index = decorated.widget })
  return setmetatable(decorated, { __index = decorated.wibox })
end


return common
