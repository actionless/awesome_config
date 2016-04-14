--[[
     Licensed under GNU General Public License v2
      * (c) 2013-2014, Yauheni Kirylau
--]]

local awful = require("awful")
local beautiful = require("beautiful")

local capi = { client = client }


local common = require("actionless.widgets.common")
local persistent = require("actionless.persistent")


local manage_client = {}

local function worker(args)
  args	 = args or {}
  args.bg = args.bg or beautiful.panel_widget_bg or beautiful.fg
  args.fg = args.fg or beautiful.panel_widget_fg or beautiful.bg
  local widget_screen = args.screen or awful.screen.focused()

  local object = {}
  local widget = common.widget()

  widget.is_managing = persistent.titlebar.get()

  args.widget = widget
  widget = common.decorated_horizontal(args)
  widget:set_text('X')
  widget:connect_signal(
    "mouse::enter", function ()
      if not widget.is_managing then
        --widget:set_error()
        widget:set_bg(beautiful.color.color9)
      else
        --widget:set_warning()
        widget:set_bg(beautiful.color.color10)
      end
    end)
  widget:connect_signal(
    "mouse::leave", function ()
      if not widget.is_managing then
        widget:set_normal()
      else
        widget:set_warning()
      end
    end)

  local function update_widget_status()
    if widget.is_managing then
      widget:set_warning()
      widget:set_text('T')
    else
      widget:set_error()
      widget:set_text('X')
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
