
--[[

     Licensed under GNU General Public License v2
      * (c) 2013, Luke Bonham

--]]

local newtimer     = require("lain.helpers").newtimer

local wibox        = require("wibox")

local io           = io
local tonumber     = tonumber

local setmetatable = setmetatable

-- coretemp
-- lain.widgets.temp
local temp = {}

local function worker(args)
    local args     = args or {}
    local timeout  = args.timeout or 5
    local settings = args.settings or function() end

    temp.widget = wibox.widget.textbox('')

    function update()
        local f = io.open("/sys/devices/LNXSYSTM:00/device:00/PNP0A03:00/device:16/ATK0110:00/hwmon/hwmon0/temp1_input")
	if f == nil then
		 f = io.open("/sys/devices/LNXSYSTM:00/device:00/PNP0A03:00/device:16/ATK0110:00/hwmon/hwmon1/temp1_input")
	end
	if f == nil then
		 f = io.open("/sys/devices/LNXSYSTM:00/device:00/PNP0A03:00/device:16/ATK0110:00/hwmon/hwmon2/temp1_input")
	end
        coretemp_now = tonumber(f:read("*all")) / 1000
        f:close()
        widget = temp.widget
        settings()
    end

    newtimer("coretemp", timeout, update)
    return temp.widget
end

return setmetatable(temp, { __call = function(_, ...) return worker(...) end })
