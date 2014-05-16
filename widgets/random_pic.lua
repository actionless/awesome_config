--[[
     Licensed under GNU General Public License v2
      * (c) 2013-2014, Yauheni Kirylau
--]]

local asyncshell   = require("widgets.asyncshell")
local newtimer     = require("widgets.helpers").newtimer
local icons_dir     = require("widgets.helpers").icons_dir

local wibox        = require("wibox")

local tonumber     = tonumber
local math         = require("math")

local setmetatable = setmetatable
local beautiful    = require("widgets.helpers").beautiful


local function scandir(directory)
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

local rp = {}
rp.widget = wibox.widget.imagebox()

local function worker(args)
	local args     = args or {}

	--local interval  = args.interval or 5
	local interval  = args.interval or math.random(5,15)

	local dir = args.dir or icons_dir .. 'random_pics/'
	local image_list = scandir(dir)
	rp.widget:set_image(random_image())

	function random_image()
		local image_name = image_list[ math.random(1, #image_list) ]
		return dir .. image_name
	end
	
	function rp.update()
		rp.widget:set_image(random_image())
	end
	
	-- random timer id is for possibility to
	-- run different instance of the widget simultaneously
	newtimer("random_pic_" .. math.random(1,65535), interval, rp.update)

	return rp.widget
end

return setmetatable({}, { __call = function(_, ...) return worker(...) end })
