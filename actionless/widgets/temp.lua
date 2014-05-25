--[[
     Licensed under GNU General Public License v2
      * (c) 2013-2014, Yauheni Kirylau
--]]

local beautiful    = require("beautiful")
local tonumber     = tonumber
local setmetatable = setmetatable

local async        = require("actionless.async")
local helpers      = require("actionless.helpers")
local parse        = require("actionless.parse")
local common_widget= require("actionless.widgets.common").widget


-- coretemp
local temp = {}
temp.widget = common_widget()
temp.widget:set_image(beautiful.widget_temp)

local function worker(args)
  local args = args or {}
  local update_interval = args.update_interval or 5
  local warning = args.warning or 75
  local sensor = args.sensor or "CPU Temperature"

  function temp.update()
    async.execute("sensors ", function (str) temp.post_update(str) end)
  end

  function temp.post_update(str)
    local coretemp_now = parse.find_in_multiline_string(
      str, sensor .. ":[ ]+(.*)°C.*[(]")
    if tonumber(coretemp_now) >= warning then
      temp.widget:set_bg(beautiful.error)
    else
      temp.widget:set_bg(beautiful.bg)
    end
    temp.widget:set_fg(beautiful.fg)
    temp.widget:set_text(string.format("%2i", coretemp_now) .. '°C')
  end

  helpers.newtimer("coretemp", update_interval, temp.update)
  return temp.widget
end

return setmetatable(temp, { __call = function(_, ...) return worker(...) end })
