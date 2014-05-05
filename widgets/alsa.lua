
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

alsa.volume = {
	status = "N/A",
	level = "0"
}

local function worker(args)
	local args	 = args or {}
	local with_icon = args.with_icon or true
	local widget_bg = args.widget_bg
	alsa.timeout  = args.timeout or 5
	alsa.channel  = args.channel or "Master"
	alsa.mic_channel = args.mic_channel or "Capture"
	alsa.channels_toggle = args.channels_toggle or {channel, }

	if widget_bg then
		alsa.icon_bg:set_bg(widget_bg)
		alsa.text_bg:set_bg(widget_bg)
	end

	function alsa.up()
		awful.util.spawn_with_shell("amixer -q set " .. alsa.channel .. ",0 1%+")
		--awful.util.spawn("amixer -q set " .. channel .. ",1 1%+")
		if alsa.volume.level < 100 then
			alsa.volume.level = alsa.volume.level + 1
		end
		alsa.update_indicator()
	end

	function alsa.down()
		awful.util.spawn_with_shell("amixer -q set " .. alsa.channel .. ",0 1%-")
		--awful.util.spawn("amixer -q set " .. channel .. ",1 1%-")
		if alsa.volume.level > 0 then
			alsa.volume.level = alsa.volume.level - 1
		end
		alsa.update_indicator()
	end

	function alsa.toggle()
		if alsa.volume.status == 'off' then
			for _, channel in pairs(alsa.channels_toggle) do 
				awful.util.spawn_with_shell("amixer -q set " .. channel .. ",0 on")
				awful.util.spawn_with_shell("amixer -q set " .. channel .. ",1 on")
			end
		else
			awful.util.spawn_with_shell("amixer -q set " .. alsa.channel .. ",0 off")
			awful.util.spawn_with_shell("amixer -q set " .. alsa.channel .. ",1 off")
		end
		if alsa.volume.status == 'off' then
			alsa.volume.status = 'on'
		else
			alsa.volume.status = 'off'
		end
		alsa.update_indicator()
	end

	function alsa.toggle_mic()
		awful.util.spawn("amixer -q set " .. alsa.mic_channel .. ",0 toggle")
		awful.util.spawn("amixer -q set " .. alsa.mic_channel .. ",1 toggle")
		--alsa.update_indicator()
	end

	function alsa.update_indicator()
		if alsa.volume.status == "off" then
			alsa.icon_widget:set_image(beautiful.widget_vol_mute)
		elseif alsa.volume.level == 0 then
			alsa.icon_widget:set_image(beautiful.widget_vol_no)
		elseif alsa.volume.level <= 50 then
			alsa.icon_widget:set_image(beautiful.widget_vol_low)
		elseif alsa.volume.level <= 75 then
			alsa.icon_widget:set_image(beautiful.widget_vol)
		else
			alsa.icon_widget:set_image(beautiful.widget_vol_high)
		end

		alsa.text_widget:set_text(
			string.format("%-4s", alsa.volume.level .. "%"))
	end

	function alsa.update()
		asyncshell.request('amixer get ' .. alsa.channel,
		                   function(f) alsa.post_update(f) end)
	end

	function alsa.post_update(f)
		level, alsa.volume.status = string.match(
			f:read("*all"), "([%d]+)%%.*%[([%l]*)")
		alsa.volume.level = tonumber(level) or nil

		if alsa.volume.level == nil
		then
			alsa.volume.level  = 0
			alsa.volume.status = "off"
		end

		if alsa.volume.status == ""
		then
			if alsa.volume.level == 0
			then
				alsa.volume.status = "off"
			else
				alsa.volume.status = "on"
			end
		end

		alsa.update_indicator()
	end

	newtimer("alsa", alsa.timeout, alsa.update)
	return setmetatable(alsa, { __index = alsa.widget })
end

return setmetatable(alsa, { __call = function(_, ...) return worker(...) end })
