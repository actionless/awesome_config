
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013-2014, Yauheni Kirylau
      * (c) 2013,      Luke Bonham                
      * (c) 2010-2012, Peter Hofmann              
                                                  
--]]

local first_line   = require("widgets.helpers").first_line
local newtimer     = require("widgets.helpers").newtimer
local font         = require("widgets.helpers").font
local mono_preset      = require("widgets.helpers").mono_preset

local wibox        = require("wibox")
local naughty      = require("naughty")

local math         = { ceil   = math.ceil }
local string       = { format = string.format,
                       gmatch = string.gmatch }
local tostring     = tostring
local setmetatable = setmetatable

-- CPU usage
-- widgets.cpu
local cpu = {
	last_total = 0,
	last_active = 0
}
cpu.widget = wibox.widget.textbox('')
cpu.widget:connect_signal("mouse::enter", function () cpu.show_notification() end)
cpu.widget:connect_signal("mouse::leave", function () cpu.hide_notification() end)

local function worker(args)
	local args     = args or {}
	local interval  = args.interval or 5
	local settings = args.settings or function()
		widget:set_text("" .. string.format("%-3s", cpu_now.usage .. "%").. " ")
	end
	cpu.font = args.font or font
	cpu.timeout = args.timeout or 0

	cpu.list_len = args.list_length or 10
	cpu.command = args.command or "COLUMNS=512 top -o \\%CPU -b -n 1 | head -n " .. cpu.list_len +6 .. "| tail -n " .. cpu.list_len  .. 
	                              ' | awk ' .. '\'{printf "%-5s %-4s %s\\n", $1, $9, $12}\''

	function cpu.hide_notification()
		if cpu.id ~= nil then
			naughty.destroy(cpu.id)
			cpu.id = nil
		end
	end

	function cpu.show_notification()
		cpu.hide_notification()
		local f = io.popen(cpu.command)
		local output = ''
		for line in f:lines() do
			output = output .. line .. '\n'
		end
		cpu.id = naughty.notify({
			text = output,
			timeout = cpu.timeout,
			preset = mono_preset
		})
	end

    function cpu.update()
        -- Read the amount of time the CPUs have spent performing
        -- different kinds of work. Read the first line of /proc/stat
        -- which is the sum of all CPUs.
        local times = first_line("/proc/stat")
        local at = 1
        local idle = 0
        local total = 0
        for field in string.gmatch(times, "[%s]+([^%s]+)")
        do
            -- 3 = idle, 4 = ioWait. Essentially, the CPUs have done
            -- nothing during these times.
            if at == 3 or at == 4
            then
                idle = idle + field
            end
            total = total + field
            at = at + 1
        end
        local active = total - idle

        -- Read current data and calculate relative values.
        local dactive = active - cpu.last_active
        local dtotal = total - cpu.last_total

        cpu_now = {}
        cpu_now.usage = math.ceil((dactive / dtotal) * 100)

        widget = cpu.widget
        settings()

        -- Save current data for the next run.
        cpu.last_active = active
        cpu.last_total = total
    end

    newtimer("cpu", interval, cpu.update)

    return setmetatable(cpu, { __index = cpu.widget })
end

return setmetatable(cpu, { __call = function(_, ...) return worker(...) end })
