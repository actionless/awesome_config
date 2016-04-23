--[[
Licensed under GNU General Public License v2
* (c) 2013-2014, Yauheni Kirylau
--]]

local wibox        = require("wibox")
local math         = require("math")
local beautiful = require("beautiful")



local helpers = require("actionless.helpers")
local newinterval     = helpers.newinterval


local function scandir(directory)
  local i, popen, result = 0, io.popen, {}
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
  args = args or {}

  --local interval  = args.interval or 5
  local interval  = args.interval or math.random(5,15)

  rp.dir = args.dir or beautiful.icons_dir .. 'random_pics/'
  rp.image_list = scandir(rp.dir)

  function rp.random_image()
    local image_name = rp.image_list[ math.random(1, #rp.image_list) ]
    return rp.dir .. image_name
  end

  function rp.update()
    rp.widget:set_image(rp.random_image())
  end

  rp.widget:set_image(rp.random_image())

  -- random timer id is for possibility to
  -- run different instance of the widget simultaneously
  newinterval(interval, rp.update)
  return rp.widget
end

return setmetatable({}, { __call = function(_, ...) return worker(...) end })
