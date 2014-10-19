--[[            
     Licensed under GNU General Public License v2
      * (c) 2013-2014, Yauheni Kirylau             
--]]

local awful		= require("awful")
local naughty	= require("naughty")
local beautiful = require("beautiful")
local io		= { popen = io.popen }
local string    = { format = string.format }
local setmetatable = setmetatable
local capi = { client = client }

local common	= require("actionless.widgets.common")
local helpers	= require("actionless.helpers")
local newtimer	= helpers.newtimer
local font		= helpers.font


local manage_client = {}

local function worker(widget_screen, args)
  local args	 = args or {}
  local interval  = args.interval or 5
  local bg = args.bg or beautiful.panel_widget_bg or beautiful.fg
  local fg = args.fg or beautiful.panel_widget_fg or beautiful.bg

  local object = {}
  local widget = common.widget()

  if beautiful.close_button then
    widget:set_image(beautiful.close_button)
    widget:connect_signal(
      "mouse::enter", function ()
        widget:set_image(beautiful.close_button_hover)
      end)
    widget:connect_signal(
      "mouse::leave", function ()
        widget:set_image(beautiful.close_button)
      end)
  else
    widget = common.decorated({
      widget=manage_client.widget, bg=bg, fg=fg,
    })
    widget:set_text(' x ')
    widget:connect_signal(
      "mouse::enter", function ()
        widget:set_color({name='error'})
      end)
    widget:connect_signal(
      "mouse::leave", function ()
        widget:set_color({bg=bg})
      end)
  end

  widget:buttons(awful.util.table.join(
    --awful.button({ }, 1, function () alsa.toggle() end),
    --awful.button({ }, 5, function () alsa.down() end),
    awful.button({ }, 1, function ()
      capi.client.focus:kill()
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
