
--[[
												  
	 Licensed under GNU General Public License v2 
	  * (c) 2013, Luke Bonham					 
	  * (c) 2010, Adrian C. <anrxc@sysphere.org>  
												  
--]]

local newtimer		= require("widgets.helpers").newtimer

local wibox		   = require("wibox")
local awful		   = require("awful")

local io			  = { popen  = io.popen }
local string		  = { match  = string.match,
                          format = string.format }

local setmetatable	= setmetatable

-- ALSA volume
local alsa = {}

local function worker(args)
	local args	 = args or {}
	local timeout  = args.timeout or 5
	local channel  = args.channel or "Master"
	local channels_toggle = args.channels_toggle or {channel, }
	local settings = args.settings or function() end

	alsa.widget = wibox.widget.textbox('')
	alsa.widget:buttons(awful.util.table.join(
		awful.button({ }, 1, alsa.toggle),
		awful.button({ }, 5, alsa.down),
		awful.button({ }, 4, alsa.up)
	))

	function alsa.up()
		awful.util.spawn_with_shell("amixer -q set " .. channel .. ",0 1%+")
	--	awful.util.spawn("amixer -q set " .. channel .. ",1 1%+")
		alsa.update()
	end

	function alsa.down()
		awful.util.spawn_with_shell("amixer -q set " .. channel .. ",0 1%-")
	--	awful.util.spawn("amixer -q set " .. channel .. ",1 1%-")
		alsa.update()
	end

	function alsa.toggle()
		awful.util.spawn("amixer -q set " .. channel .. ",0 toggle")
		awful.util.spawn("amixer -q set " .. channel .. ",1 toggle")
		alsa.update()
	end

	function alsa.update()
		local f = assert(io.popen('amixer get ' .. channel))
		local mixer = f:read("*all")
		f:close()

		volume_now = {}

		volume_now.level, volume_now.status = string.match(mixer, "([%d]+)%%.*%[([%l]*)")

		if volume_now.level == nil
		then
			volume_now.level  = "0"
			volume_now.status = "off"
		else
			volume_now.level = string.format("%2s", volume_now.level)
		end

		if volume_now.status == ""
		then
			if volume_now.level == "0"
			then
				volume_now.status = "off"
			else
				volume_now.status = "on"
			end
		end

		widget = alsa.widget
		settings()
	end

	newtimer("alsa", timeout, alsa.update)

	return setmetatable(alsa, { __index = alsa.widget })
end

return setmetatable(alsa, { __call = function(_, ...) return worker(...) end })
