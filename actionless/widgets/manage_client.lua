--[[
     Licensed under GNU General Public License v2
      * (c) 2013-2018, Yauheni Kirylau
--]]

local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local wibox = require('wibox')
local delayed_call = require("gears.timer").delayed_call

local capi = { client = client, screen = screen }


local common = require("actionless.widgets.common")
local persistent = require("actionless.persistent")
local color_utils = require("actionless.util.color")


local manage_client = {}

local function widget_factory(args)
  -- ARGUMENTS: ---------------------------------------------------------------
  args	 = args or {}
  args.bg = args.bg or beautiful.panel_widget_bg or beautiful.fg
  args.fg = args.fg or beautiful.panel_widget_fg or beautiful.bg
  args.error_color_on_hover = args.error_color_on_hover or false
  local widget_screen = args.screen or awful.screen.focused()
  local padding = args.padding or dpi(12)

  -- WIDGET: ------------------------------------------------------------------
  args.widget = wibox.widget.textbox()
  args.widgets = {
    common.constraint{width=padding},
    args.widget,
    common.constraint{width=padding},
  }
  args.spacing = 0
  local widget = common.decorated(args)

  -- METHODS: -----------------------------------------------------------------
  function widget:_update_status()
    if self.titlebars_forced_globally then
      self:set_warning()
      self:set_text('T')
    else
      self:set_normal()
      self:set_text('X')
    end
  end

  function widget:toggle()
    if not self.titlebars_forced_globally then
      self.titlebars_forced_globally = true
      persistent.titlebar.set(true)
    else
      self.titlebars_forced_globally = false
      persistent.titlebar.set(false)
    end
    self:_update_status()
    for _, t in ipairs(widget_screen.tags) do
      t:emit_signal("property::layout")
      for _, c in ipairs(t:clients()) do
        c:emit_signal("property::geometry")
      end
    end
  end

  -- INIT: --------------------------------------------------------------------
  widget.titlebars_forced_globally = persistent.titlebar.get()
  widget:_update_status()
  delayed_call(function()
    if widget_screen == awful.screen.focused() then
      widget:show()
    else
      widget:hide()
    end
  end)

  -- EVENTS: ------------------------------------------------------------------
  capi.client.connect_signal("focus",function(c)
    if c.screen == widget_screen then
      widget:_update_status()
      widget:show()
    end
  end)
  capi.client.connect_signal("unfocus",function(c)
    if c.screen == widget_screen then
      widget:hide()
    end
  end)
  -- Tag changed
  screen.connect_signal("tag::history::update", function (s)
    if (
      capi.screen.count() < 2
    ) or (
      s == widget.prev_focused_screen
    ) then return end

    if s == widget_screen then
      widget:set_text(' ')
      widget:show()
    else
      widget:hide()
    end
    widget.prev_focused_screen = s
  end)

  local function focused_client_on_this_screen()
    return client.focus and (client.focus.screen == widget_screen)
  end

  widget._on_mouse_enter = function ()
    if not widget.titlebars_forced_globally then
      if focused_client_on_this_screen() then
        if args.error_color_on_hover then
          widget:set_bg(beautiful.xrdb.color9)
        else
          widget:set_bg(color_utils.darker(args.bg, -20))
        end
      end
    else
      widget:set_warning()
    end
  end
  widget:connect_signal("mouse::enter", widget._on_mouse_enter)
  widget._on_mouse_leave = function ()
    if not widget.titlebars_forced_globally then
      widget:set_normal()
    else
      widget:set_warning()
    end
  end
  widget:connect_signal("mouse::leave", widget._on_mouse_leave)

  widget._buttons_table = awful.util.table.join(
    awful.button({ }, 1, function()
      if focused_client_on_this_screen() then
        widget:set_error()
      end
    end, function ()
      if focused_client_on_this_screen() then
      --if not widget.titlebars_forced_globally then
        capi.client.focus:kill()
      --end
      end
    end),
    awful.button({ }, 3, function()
      widget:toggle()
    end)
  )
  widget:buttons(widget._buttons_table)

  return widget
end

return setmetatable(manage_client, { __call = function(_, ...)
  return widget_factory(...)
end })
