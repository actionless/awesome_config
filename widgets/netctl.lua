--[[            
     Licensed under GNU General Public License v2 
      * (c) 2013-2014, Yauheni Kirylau             
--]]
local newtimer  = require("widgets.helpers").newtimer
local font      = require("widgets.helpers").font
local beautiful      = require("widgets.helpers").beautiful
local mono_preset      = require("widgets.helpers").mono_preset

local wibox     = require("wibox")
local naughty   = require("naughty")

local io        = { lines  = io.lines,
                    popen = io.popen }
local math      = { floor  = math.floor }
local string    = { format = string.format,
                    gmatch = string.gmatch,
                    len    = string.len }
local setmetatable = setmetatable

local netctl = {current = 'loading...'}

netctl.text_widget = wibox.widget.textbox('')
netctl.icon_widget = wibox.widget.imagebox(beautiful.widget_wireless)

netctl.widget = wibox.layout.fixed.horizontal()

netctl.widget:add(netctl.icon_widget)
netctl.widget:add(netctl.text_widget)

netctl.widget:connect_signal("mouse::enter", function () netctl.show_notification() end)
netctl.widget:connect_signal("mouse::leave", function () netctl.hide_notification() end)

local function worker(args)
	local args	 = args or {}
	local interval  = args.interval or 5
	local settings = args.settings or function()
		netctl.text_widget:set_text("" .. string.format("%-6s", netctl.current))
	end
	netctl.timeout = args.timeout or 0
	netctl.font = args.font or font

	function netctl.hide_notification()
		if netctl.id ~= nil then
			naughty.destroy(netctl.id)
			netctl.id = nil
		end
	end

	function netctl.show_notification()
		netctl.hide_notification()
		local f = io.popen(netctl.command)
		local output = ''
		for line in f:lines() do
			output = output .. line .. '\n'
		end
		netctl.id = naughty.notify({
			text = output,
			timeout = netctl.timeout,
			preset = mono_preset
		})
	end

	function netctl.update()
		asyncshell.request('fish -c crnt_net', function(f) netctl.post_update(f) end)
	end

	function netctl.post_update(f)
		for line in f:lines() do
				netctl.current = line
		end

		widget = netctl.widget
		settings()
	end

	newtimer("netctl", interval, netctl.update)

    return setmetatable(netctl, { __index = netctl.widget })
end

return setmetatable(netctl, { __call = function(_, ...) return worker(...) end })
