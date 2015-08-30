--[[
     Licensed under GNU General Public License v2
      * (c) 2013-2014, Yauheni Kirylau
--]]

local awful = require("awful")
local beautiful = require("beautiful")

local capi = { client = client }


local common = require("actionless.widgets.common")


local manage_client = {}

local function worker(args)
  local args	 = args or {}
  args.bg = args.bg or beautiful.panel_widget_bg or beautiful.fg
  args.fg = args.fg or beautiful.panel_widget_fg or beautiful.bg
  local awesome_context = args.awesome_context
  local widget_screen = args.screen or 1

  local object = {}
  local widget = common.widget()

  widget.is_managing = false

  args.widget = widget
  widget = common.decorated_horizontal(args)
  widget:set_text('X')
  widget:connect_signal(
    "mouse::enter", function ()
      if not widget.is_managing then
        widget:set_error()
      else
        widget:set_warning()
      end
    end)
  widget:connect_signal(
    "mouse::leave", function ()
      if not widget.is_managing then
        widget:set_normal()
      end
    end)

  widget.toggle = function()
    local t = awful.tag.selected(widget_screen)
    if not widget.is_managing then
      widget.is_managing = true
      widget:set_warning()
      widget:set_text('T')
      awesome_context.show_titlebar = true
      tag.emit_signal("property::layout", t)
    else
      widget.is_managing = false
      widget:set_error()
      widget:set_text('X')
      awesome_context.show_titlebar = false
      tag.emit_signal("property::layout", t)
    end
  end

  widget:buttons(awful.util.table.join(
    awful.button({ }, 1, function ()
      if not widget.is_managing then
        capi.client.focus:kill()
      end
    end),
    awful.button({ }, 3, widget.toggle)
  ))

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
