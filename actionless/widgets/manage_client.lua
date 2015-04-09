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
  local widget_screen = args.screen or 1
  local clientbuttons = args.clientbuttons
  local clientbuttons_manage = args.clientbuttons_manage

  local object = {}
  local widget = common.widget()

  widget.is_managing = false

  args.widget = widget
  widget = common.decorated(args)
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

  widget:buttons(awful.util.table.join(
    awful.button({ }, 1, function ()
      capi.client.focus:kill()
    end),
    awful.button({ }, 3, function ()
      local cls = capi.client.get()
      if not widget.is_managing then
        widget.is_managing = true
        widget:set_warning()
        widget:set_text('M')
        for _, c in pairs(cls) do
          c:buttons(clientbuttons_manage)
        end
      else
        widget.is_managing = false
        widget:set_error()
        widget:set_text('X')
        for _, c in pairs(cls) do
          c:buttons(clientbuttons)
        end
      end
    end)
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
