
--[[

     Licensed under GNU General Public License v2
      * (c) 2013, Luke Bonham

--]]
local asyncshell   = require("widgets.asyncshell")
local newtimer     = require("lain.helpers").newtimer

local wibox        = require("wibox")

local io           = io

local setmetatable = setmetatable

-- coretemp
-- lain.widgets.temp
local temp = {}

local function worker(args)
    local args     = args or {}
    local timeout  = args.timeout or 5
    local settings = args.settings or function()
		widget:set_text(" " .. coretemp_now .. " ")
	end
    local sensor   = args.sensor or "CPU Temperature"

    temp.widget = wibox.widget.textbox('')

        function update()
                asyncshell.request("sensors ", function (f) post_update(f) end)
        end

    function post_update(f)
	for line in f:lines() do
		for k, v in string.gmatch(line, "(.*):.*%+(.*)[ ]+$") do
--coretemp_now = k
			if k == sensor then coretemp_now = v end
		end
		for k, v in string.gmatch(line, "(.*):.*%+(.*)[ ]+%(.*$") do
--coretemp_now = k
			if k == sensor then coretemp_now = v end
		end
	end
        widget = temp.widget
        settings()
    end

    newtimer("coretemp", timeout, update)
    return temp.widget
end

return setmetatable(temp, { __call = function(_, ...) return worker(...) end })
