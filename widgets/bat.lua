
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013,      Luke Bonham                
      * (c) 2010-2012, Peter Hofmann              
                                                  
--]]

local asyncshell   = require("widgets.asyncshell")
local newtimer     = require("widgets.helpers").newtimer
local first_line   = require("widgets.helpers").first_line

local naughty      = require("naughty")
local wibox        = require("wibox")

local math         = { floor  = math.floor }
local string       = { format = string.format,
						match = string.match }

local setmetatable = setmetatable

-- Battery infos
local bat = {}
bat_now = {
	on_bat = "N/A",
	lo_bat = "N/A",
	perc   = "N/A",
	time   = "N/A",
}
bat_prev = nil

local function worker(args)
    local args = args or {}
    local timeout = args.timeout or 30
    local battery = args.battery or "BAT0"
    local settings = args.settings or function() end

    bat.widget_text = wibox.widget.textbox('')
    bat.widget = wibox.widget.background()
	bat.widget:set_widget(bat.widget_text)

	function bat.update()
		asyncshell.request('upower -d', function(f) bat.post_update(f) end)
	end

    function bat.post_update(f)
        for line in f:lines() do 
			k, v = string.match(line, "[ ]+(.*):[ ]+(.*)")
			if k == 'percentage' then
				bat_now.perc = string.match(v,"%d+")
			elseif k == 'time to empty' then
				bat_now.time = tonumber(v)
			elseif k == 'on-battery' then
				bat_now.on_bat = v
			elseif k == 'on-low-battery' then
				bat_now.lo_bat = v
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
        widget = bat.widget
        settings()
		bat_prev = bat_now
    end

    newtimer("bat_widget", timeout, bat.update)

    return bat.widget
end

return setmetatable(bat, { __call = function(_, ...) return worker(...) end })
