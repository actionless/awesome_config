local wibox = require("wibox")
local beautiful = require("beautiful")


local common = {}

function common.make_text_separator(separator_character, bg, fg)
  --'<span font="monospace 17">' .. separator_character .. '</span>'))
  local bg = bg or beautiful.panel_bg
  local fg = fg or beautiful.panel_fg
  local widget = wibox.widget.background()
  widget:set_fg(fg)
  widget:set_bg(bg)
  widget:set_widget(wibox.widget.textbox(separator_character))
  return widget
end

function common.make_separator(image_name, bg)
  local bg = bg or beautiful.panel_bg
  local widget = wibox.widget.background()
  widget:set_bg(bg)
  local image_widget = wibox.widget.imagebox(beautiful[image_name])
  image_widget:set_resize(false)
  widget:set_widget(image_widget)
  return widget
end


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


function common.decorated(widget)
  local decorated = {}

  decorated.arrl = common.make_separator('arrl')
  decorated.widget = widget or common.widget()
  decorated.arrr = common.make_separator('arrr')

  decorated.wibox = wibox.layout.fixed.horizontal()
  decorated.wibox:add(decorated.arrl)
  decorated.wibox:add(decorated.widget)
  decorated.wibox:add(decorated.arrr)

  function decorated:set_color(color_number)
    self.arrl.widget:set_image(beautiful['arrl' .. color_number])
    self.arrr.widget:set_image(beautiful['arrr' .. color_number])
    pcall(function()
      self.widget:set_fg(beautiful['color' .. color_number])
    end)
  end

  function decorated:set_warning()
    self.arrl.widget:set_image(beautiful['arrl_warn'])
    self.arrr.widget:set_image(beautiful['arrr_warn'])
    pcall(function()
      self.widget:set_fg(beautiful['shiny'])
      self.widget:set_bg(beautiful['warning'])
    end)
  end

  function decorated:set_error()
    local naughty = require("naughty")
    naughty.notify({text='err'})
    self.arrl.widget:set_image(beautiful['arrl_err'])
    self.arrr.widget:set_image(beautiful['arrr_err'])
    pcall(function()
      self.widget:set_fg(beautiful['shiny'])
      self.widget:set_bg(beautiful['error'])
    end)
  end

  return setmetatable(decorated, { __index = decorated.wibox })
end


return common
