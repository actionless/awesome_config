
--[[

     Licensed under GNU General Public License v2
      * (c) 2013-2014, Yauheni Kirylau
      * (c) 2013,      Luke Bonham

--]]
local asyncshell   = require("widgets.asyncshell")
local newtimer     = require("widgets.helpers").newtimer

local wibox        = require("wibox")

local io           = io
local tonumber     = tonumber

local setmetatable = setmetatable
local beautiful    = require("widgets.helpers").beautiful

-- coretemp
local temp = {}

local function worker(args)
	local args     = args or {}
	local timeout  = args.timeout or 5
	local critical = args.critical or 75
	local settings = args.settings or function()
		if tonumber(coretemp_now) >= critical then
			temp.widget:set_bg(beautiful.error)
			temp.widget:set_fg(beautiful.bg)
		else
			temp.widget:set_bg(beautiful.bg)
			temp.widget:set_fg(beautiful.fg)
		end
		temp.widget_text:set_text(string.format("%2i", coretemp_now) .. '°C')
	end
    local sensor   = args.sensor or "CPU Temperature"

	temp.widget_text = wibox.widget.textbox('')
	temp.widget = wibox.widget.background()
	temp.widget:set_widget(temp.widget_text)

	function temp.update()
		asyncshell.request("sensors ", function (f) temp.post_update(f) end)
	end

	function temp.post_update(f)
		for line in f:lines() do
			k, v = string.match(line, "(.*):[ ]+(.*)°C.*[(]")
			if not v then
				k, v = string.match(line, "(.*):[ ]+(.*)°C")
			end
			if k == sensor then
				coretemp_now = v
				break
			end
		end
		settings()
	end

	newtimer("coretemp", timeout, temp.update)
	return temp.widget
end

return setmetatable(temp, { __call = function(_, ...) return worker(...) end })
