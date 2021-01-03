--[[
     Licensed under GNU General Public License v2
      * (c) 2014-2021  Yauheni Kirylau
--]]


local beautiful = require("beautiful")
local wibox = require("wibox")

local h_table = require("actionless.util.table")
local common_constraint = require('actionless.widgets.common.constraint')
local common_widget = require('actionless.widgets.common.widget')
local set_panel_widget_shape = require('actionless.widgets.common.shape').set_panel_widget_shape


local module = {}

--[[
--------------------------------------------------------------------------------
         Decorated widget entrypoint
--------------------------------------------------------------------------------
--]]

function module.decorated(args)
  args = args or {}
  if args.horizontal == nil and args.orientation == nil then
    args.horizontal = true
  end
  if args.horizontal or args.orientation == "horizontal" then
    return module.decorated_horizontal(args)
  else
    return module.decorated_vertical(args)
  end
end



--[[
--------------------------------------------------------------------------------
         Vertical decorated widget
--------------------------------------------------------------------------------
--]]

function module.decorated_vertical(args)
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
    decorated.lie_widget_list = {common_widget(args)}
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
    decorated.internal_widget_layout = wibox.layout.align.horizontal(
        nil,
        decorated.lie_widget_layout,
        common_constraint({width=args.padding or beautiful.panel_padding_bottom})
    )
  elseif decorated.valign == "bottom" then
    decorated.internal_widget_layout = wibox.layout.align.vertical(
        nil,
        nil,
        wibox.layout.align.horizontal(
            nil,
            decorated.lie_widget_layout,
            common_constraint({width=args.padding or beautiful.panel_padding_bottom})
        )
    )
  end

  decorated.constraint = common_constraint({
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
  setmetatable(decorated.lie_layout, { __index = decorated.constraint })
  setmetatable(decorated,        { __index = decorated.lie_layout })
  return decorated
end




--[[
--------------------------------------------------------------------------------
         Horizontal decorated widget
--------------------------------------------------------------------------------
--]]

function module.decorated_horizontal(args)
  local decorated = {
    left_separator_widgets = {},
    lie_widget_list = {},
    right_separator_widgets = {},
  }

  args = args or {}
  decorated.bg = args.bg or beautiful.panel_widget_bg or beautiful.fg or "#ffffff"
  decorated.fg = args.fg or beautiful.panel_widget_fg or beautiful.bg or "#000000"

  args.margin = args.margin or {
    left = args.margin_left,
    right = args.margin_right,
  }
  if args.margin.left then
    table.insert(
      decorated.left_separator_widgets,
      common_constraint{width = args.margin.left, }
    )
  end
  if args.margin.right then
    table.insert(
      decorated.right_separator_widgets,
      common_constraint{width = args.margin.right, }
    )
  end

  if args.widgets then
    decorated.lie_widget_list = args.widgets
  elseif args.widget then
    decorated.lie_widget_list = {args.widget}
  else
    decorated.lie_widget_list = {common_widget(args)}
  end
  if args.widget then
    decorated.lie_widget = args.widget
  else
    decorated.lie_widget = decorated.lie_widget_list[1]
  end

  args.padding = args.padding or {}
  if args.padding.left then
    table.insert(
      decorated.lie_widget_list,
      1,
      wibox.container.background(common_constraint{width = args.padding.left, })
    )
  end
  if args.padding.right then
    table.insert(
      decorated.lie_widget_list,
      wibox.container.background(common_constraint{width = args.padding.right, })
    )
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
  if args.panel_widget_shape then
    decorated.lie_background = set_panel_widget_shape(decorated.lie_background)
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
    for _, each_widget in ipairs(self.lie_widget_list) do
      self.lie_layout:add(each_widget)
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

return setmetatable(module, { __call = function(_, ...) return module.decorated(...) end })
