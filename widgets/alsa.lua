
--[[
												  
	 Licensed under GNU General Public License v2 
	  * (c) 2013, Luke Bonham					 
	  * (c) 2010, Adrian C. <anrxc@sysphere.org>  
												  
--]]

local newtimer		= require("widgets.helpers").newtimer
local beautiful		= require("widgets.helpers").beautiful

local wibox		   = require("wibox")
local awful		   = require("awful")

local io			  = { popen  = io.popen }
local string		  = { match  = string.match,
                          format = string.format }

local asyncshell  = require("widgets.asyncshell")
local setmetatable	= setmetatable

-- ALSA volume
local alsa = {}

alsa.text_widget = wibox.widget.textbox('')
alsa.text_bg = wibox.widget.background()
alsa.text_bg:set_widget(alsa.text_widget)

alsa.icon_widget = wibox.widget.imagebox(beautiful.widget_vol)
alsa.icon_bg = wibox.widget.background()
alsa.icon_bg:set_widget(alsa.icon_widget)

alsa.widget = wibox.layout.fixed.horizontal()
alsa.widget:add(alsa.icon_bg)
alsa.widget:add(alsa.text_bg)

alsa.widget:buttons(awful.util.table.join(
	awful.button({ }, 1, function () alsa.toggle() end),
	awful.button({ }, 5, function () alsa.down() end),
	awful.button({ }, 4, function () alsa.up() end)
))

local volume_now = {
	status = "N/A",
	level = "0"
}

local function worker(args)
	local args	 = args or {}
	alsa.timeout  = args.timeout or 5
	alsa.channel  = args.channel or "Master"
	alsa.mic_channel = args.mic_channel or "Capture"
	alsa.channels_toggle = args.channels_toggle or {channel, }

	function alsa.up()
		awful.util.spawn_with_shell("amixer -q set " .. alsa.channel .. ",0 1%+")
	--	awful.util.spawn("amixer -q set " .. channel .. ",1 1%+")
		volume_now.level = volume_now.level + 1
		alsa.update_indicator()
	end

	function alsa.down()
		awful.util.spawn_with_shell("amixer -q set " .. alsa.channel .. ",0 1%-")
	--	awful.util.spawn("amixer -q set " .. channel .. ",1 1%-")
		volume_now.level = volume_now.level - 1
		alsa.update_indicator()
	end

	function alsa.toggle()
		if volume_now.status == 'off' then
			for _, channel in pairs(alsa.channels_toggle) do 
				awful.util.spawn("amixer -q set " .. channel .. ",0 on")
				awful.util.spawn("amixer -q set " .. channel .. ",1 on")
			end
		else
			awful.util.spawn("amixer -q set " .. alsa.channel .. ",0 off")
			awful.util.spawn("amixer -q set " .. alsa.channel .. ",1 off")
		end
		if volume_now.status == 'off' then
			volume_now.status = 'on'
		else
			volume_now.status = 'off'
		end
		alsa.update_indicator()
	end

	function alsa.toggle_mic()
		awful.util.spawn("amixer -q set " .. alsa.mic_channel .. ",0 toggle")
		awful.util.spawn("amixer -q set " .. alsa.mic_channel .. ",1 toggle")
		--alsa.update_indicator()
	end

	function alsa.update_indicator()
		if volume_now.status == "off" then
			alsa.icon_widget:set_image(beautiful.widget_vol_mute)
		elseif volume_now.level == 0 then
			alsa.icon_widget:set_image(beautiful.widget_vol_no)
		elseif volume_now.level <= 50 then
			alsa.icon_widget:set_image(beautiful.widget_vol_low)
		elseif volume_now.level <= 75 then
			alsa.icon_widget:set_image(beautiful.widget_vol)
		else
			alsa.icon_widget:set_image(beautiful.widget_vol_high)
		end

		alsa.text_widget:set_text("" .. string.format("%-4s", volume_now.level .. "%").. " ")
	end

	function alsa.update()
		asyncshell.request('amixer get ' .. alsa.channel,
		                   function(f) alsa.post_update(f) end)
	end
	function alsa.post_update(f)
		level, volume_now.status = string.match(
			f:read("*all"), "([%d]+)%%.*%[([%l]*)")
		volume_now.level = tonumber(level)

		if volume_now.level == nil
		then
			volume_now.level  = "0"
			volume_now.status = "off"
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

		alsa.update_indicator()
	end

	newtimer("alsa", timeout, alsa.update)

	return setmetatable(alsa, { __index = alsa.widget })
end

return setmetatable(alsa, { __call = function(_, ...) return worker(...) end })
