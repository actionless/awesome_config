
--[[

     Licensed under GNU General Public License v2
      * (c) 2013-2014, Yauheni Kirylau
      * (c) 2013,      Luke Bonham

--]]
local asyncshell   = require("widgets.asyncshell")
local newtimer     = require("widgets.helpers").newtimer
local icons_dir     = require("widgets.helpers").icons_dir

local wibox        = require("wibox")
local naughty        = require("naughty")

local io           = io
local tonumber     = tonumber
local math         = require("math")

local setmetatable = setmetatable
local beautiful    = require("widgets.helpers").beautiful


function scandir(directory)
    local i, t, popen = 0, {}, io.popen
	result = {}
    for filename in popen('ls -a "'..directory..'"'):lines() do
        i = i + 1
		if filename ~= '.' and filename ~= '..' then
	        table.insert(result,filename)
		end
    end
    return result
end


local function worker(args)
	local rp = {}
	local args     = args or {}
	--local interval  = args.interval or 5
	local interval  = args.interval or math.random(5,15)
	local dir = args.dir or icons_dir .. 'random_pics/'

	local image_list = scandir(dir)

	function random_image()
		local image_name = image_list[ math.random(1, #image_list) ]
		return dir .. image_name
	end


	rp.widget = wibox.widget.imagebox()
	rp.widget:set_image(random_image())
	
	function update()
		rp.widget:set_image(random_image())
	end

	newtimer("random_pic_" .. math.random(1,65535), interval, update)
	return rp.widget
end

return setmetatable({}, { __call = function(_, ...) return worker(...) end })
