--[[            
     Licensed under GNU General Public License v2 
      * (c) 2013-2014, Yauheni Kirylau             
--]]
local helpers	= require("widgets.helpers")
local newtimer	= helpers.newtimer
local font		= helpers.font
local beautiful	= helpers.beautiful
local mono_preset = helpers.mono_preset
local first_line = helpers.first_line
local common_widget = require("widgets.common").widget

local naughty	= require("naughty")

local io		= { popen = io.popen }
local string    = { format = string.format }
local setmetatable = setmetatable

local netctl = {
	current = 'loading...',
	widget = common_widget()
}
--netctl.widget:connect_signal("mouse::enter", function () netctl.show_notification() end)
--netctl.widget:connect_signal("mouse::leave", function () netctl.hide_notification() end)

local function worker(args)
	local args	 = args or {}
	local interval  = args.interval or 5
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
		if netctl.current == 'ethernet' then
			netctl.widget:set_image(beautiful.widget_wired)
		else
			netctl.widget:set_image(beautiful.widget_wireless)
		end
		netctl.widget:set_text("" .. string.format("%-6s", netctl.current))
	end

	newtimer("netctl", interval, netctl.update)

    return setmetatable(netctl, { __index = netctl.widget })
end

return setmetatable(netctl, { __call = function(_, ...) return worker(...) end })
