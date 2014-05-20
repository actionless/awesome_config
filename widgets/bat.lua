--[[
     Licensed under GNU General Public License v2
      * (c) 2014,		Yauheni Kirylau
--]]

local naughty		= require("naughty")
local wibox			= require("wibox")
local string		= { format	= string.format,
					    match	= string.match }

local setmetatable = setmetatable

local asyncshell	= require("widgets.asyncshell")
local helpers 		= require("widgets.helpers")
local newtimer		= helpers.newtimer
local beautiful		= helpers.beautiful
local common_widget	= require("widgets.common").widget


-- Batterys info
local bat = {}
bat.widget = common_widget()

local bat_now = {
	percentage	= "N/A",
	state		= "N/A",
  on_low_battery = nil
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

  function bat.post_update(lines)
    bat_now = helpers.find_values_in_lines(
      lines,
      "(.*):[ ]+(.*)",
      { percentage='percentage', state='state', on_low_battery='on-low-battery' }
    )
    bat_now.percentage = helpers.only_digits(bat_now.percentage)

		bat.widget:set_markup(
			string.format("%-4s", bat_now.percentage .. "%"))
    
    if bat_now.state == 'fully-charged' then
			bat.widget:set_image(beautiful.widget_ac)
			bat.widget:set_bg(beautiful.bg)
			bat.widget:set_fg(beautiful.fg)
      
    elseif bat_now.state == 'charging' then
      if bat_now.percentage < 30 then
        bat.widget:set_image(beautiful.widget_ac_charging_low)
      else
        bat.widget:set_image(beautiful.widget_ac_charging)
      end
      bat.widget:set_bg(beautiful.theme)
      bat.widget:set_fg(beautiful.fg)
      
    else
      if bat_now.on_low_battery == 'yes' then
        bat.widget:set_image(beautiful.widget_battery_empty)
        bat.widget:set_bg(beautiful.error)
        bat.widget:set_fg(beautiful.bg)
      elseif bat_now.percentage < 30 then
        bat.widget:set_image(beautiful.widget_battery_low)
        bat.widget:set_bg(beautiful.theme)
        bat.widget:set_fg(beautiful.fg)
      else
        bat.widget:set_image(beautiful.widget_battery)
        bat.widget:set_bg(beautiful.bg)
        bat.widget:set_fg(beautiful.fg)
      end
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