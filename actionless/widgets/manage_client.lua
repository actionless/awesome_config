--[[
     Licensed under GNU General Public License v2
      * (c) 2013-2014, Yauheni Kirylau
--]]

local awful = require("awful")
local beautiful = require("beautiful")

local capi = { client = client }


local common = require("actionless.widgets.common")
local persistent = require("actionless.persistent")
local color_utils = require("utils.color")


local manage_client = {}

local function worker(args)
  args	 = args or {}
  args.bg = args.bg or beautiful.panel_widget_bg or beautiful.fg
  args.fg = args.fg or beautiful.panel_widget_fg or beautiful.bg
  args.error_color_on_hover = args.error_color_on_hover or false
  local widget_screen = args.screen or awful.screen.focused()

  local object = {}
  local widget = common.widget()

  widget.is_managing = persistent.titlebar.get()

  args.widget = widget
  widget = common.decorated_horizontal(args)
  widget:set_text(' X ')

  widget._on_mouse_enter = function ()
    if not widget.is_managing then
      if args.error_color_on_hover then
        widget:set_error()
      else
        widget:set_bg(color_utils.darker(args.bg, -20))
      end
    else
      widget:set_warning()
    end
  end
  widget._on_mouse_leave = function ()
    if not widget.is_managing then
      widget:set_normal()
    else
      widget:set_warning()
    end
  end
  widget:connect_signal("mouse::enter", widget._on_mouse_enter)
  widget:connect_signal("mouse::leave", widget._on_mouse_leave)
  widget._buttons_table = awful.util.table.join(
    awful.button({ }, 1, function ()
      if not widget.is_managing then
        capi.client.focus:kill()
      end
    end),
    awful.button({ }, 3, function()
      widget.toggle()
    end)
  )
  widget:buttons(widget._buttons_table)

  local function update_widget_status()
    if widget.is_managing then
      widget:set_warning()
      widget:set_text('  T  ')
    else
      widget:set_normal()
      widget:set_text('  X  ')
    end
  end

  update_widget_status()

  widget.toggle = function()
    if not widget.is_managing then
      widget.is_managing = true
      persistent.titlebar.set(true)
    else
      widget.is_managing = false
      persistent.titlebar.set(false)
    end
    update_widget_status()
    for _, t in ipairs(widget_screen.tags) do
      t:emit_signal("property::layout")
      for _, c in ipairs(t:clients()) do
        c:emit_signal("property::geometry")
      end
    end
  end
  widget:hide()
  capi.client.connect_signal("focus",function(c)
    if c.screen == widget_screen then
      widget:show()
    end
  end)
  capi.client.connect_signal("unfocus",function(c)
    if c.screen == widget_screen then
      widget:hide()
    end
  end)

  return setmetatable(object, { __index = widget })
end

return setmetatable(manage_client, { __call = function(_, ...) return worker(...) end })
