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
local mono_preset = helpers.mono_preset


local manage_client = {}

manage_client.widget = common.decorated()
if beautiful.close_button then
  manage_client.widget:set_image(beautiful.close_button)
else
  manage_client.widget.widget.text_widget:set_text(' x ')
end

local function worker(args)
	local args	 = args or {}
	local interval  = args.interval or 5
        local fg = args.fg or beautiful.panel_fg or beautiful.fg
        local bg = args.bg or beautiful.panel_bg or beautiful.bg
        manage_client.widget:set_color(args.color_n or 1)

	manage_client.widget:buttons(awful.util.table.join(
		--awful.button({ }, 1, function () alsa.toggle() end),
		--awful.button({ }, 5, function () alsa.down() end),
		awful.button({ }, 1, function () 
			naughty.notify({text='DEBUG'})
			capi.client.focus:kill()  end)
	))

    return setmetatable(manage_client, { __index = manage_client.widget })
end

return setmetatable(manage_client, { __call = function(_, ...) return worker(...) end })
