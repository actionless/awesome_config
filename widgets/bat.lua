--[[
     Licensed under GNU General Public License v3
      * (c) 2014,		Yauheni Kirylau
--]]

local naughty		= require("naughty")
local wibox			= require("wibox")
local string		= { format	= string.format,
					    match	= string.match }

local setmetatable = setmetatable

local asyncshell	= require("widgets.asyncshell")
local newtimer		= require("widgets.helpers").newtimer
local beautiful		= require("widgets.helpers").beautiful


-- Batterys info
local bat = {}

bat.text_widget = wibox.widget.textbox('')
bat.text_bg = wibox.widget.background()
bat.text_bg:set_widget(bat.text_widget)

bat.icon_widget = wibox.widget.imagebox(beautiful.widget_battery)
bat.icon_bg = wibox.widget.background()
bat.icon_bg:set_widget(bat.icon_widget)

bat.widget = wibox.layout.fixed.horizontal()
bat.widget:add(bat.icon_bg)
bat.widget:add(bat.text_bg)

local bat_now = {
	percentage	= "N/A",
	state		= "N/A",
}

local function worker(args)
	local args = args or {}
	local timeout = args.timeout or 30
	local device = args.device or "battery_BAT0"

	function bat.update()
		asyncshell.request(
			'upower -i /org/freedesktop/UPower/devices/' .. device,
			function(f) bat.post_update(f) end)
	end

    function bat.post_update(f)
		bat_now = {}
		for line in f:lines() do
			k, v = string.match(line, "[ ]+(.*):[ ]+(.*)")
			if k == 'percentage' and not bat_now.perc then
				bat_now.percentage = tonumber(string.match(v,"%d+"))
			elseif k == 'state' then
				bat_now.state = v
			elseif k == 'on-low-battery' then
				if v == 'yes' then
					bat.icon_widget:set_image(beautiful.widget_battery_empty)
					bat.text_bg:set_bg(beautiful.error)
					bat.text_bg:set_fg(beautiful.bg)
				end
			end 
		end

		bat.text_bg.widget:set_markup(
			string.format(
				"%-4s", bat_now.percentage .. "%"))

		if bat_now.percentage < 25 then
			bat.icon_widget:set_image(beautiful.widget_battery_low)
			bat.text_bg:set_bg(beautiful.theme)
			bat.text_bg:set_fg(beautiful.fg)
		elseif bat_now.state == 'fully-charged' 
		  or bat_now.state == 'charging' then
			bat.icon_widget:set_image(beautiful.widget_ac)
			bat.icon_bg:set_bg(beautiful.bg)
			bat.text_bg:set_bg(beautiful.bg)
			bat.text_bg:set_fg(beautiful.fg)
		else
			bat.icon_widget:set_image(beautiful.widget_battery)
			bat.text_bg:set_bg(beautiful.bg)
			bat.text_bg:set_fg(beautiful.fg)
		end
		-- notifications for low and critical states
		--if bat_now.perc <= 5
		--then
        --        bat.id = naughty.notify({
        --            text = "shutdown imminent",
        --            title = "battery nearly exhausted",
        --            position = "top_right",
        --            timeout = 15,
        --            fg="#000000",
        --            bg="#ffffff",
        --            ontop = true,
        --            replaces_id = bat.id
        --        }).id
		--end
    end

    newtimer("bat_widget_" .. device, timeout, bat.update)

    return bat.widget
end

return setmetatable(bat, { __call = function(_, ...) return worker(...) end })
