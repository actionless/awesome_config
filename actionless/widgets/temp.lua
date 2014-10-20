--[[
     Licensed under GNU General Public License v2
      * (c) 2013-2014, Yauheni Kirylau
--]]

local beautiful    = require("beautiful")

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
  local bg = args.bg or beautiful.panel_fg or beautiful.fg
  local fg = args.fg or beautiful.panel_bg or beautiful.bg

  function temp.update()
    async.execute("sensors ", function (str) temp.post_update(str) end)
  end

  function temp.post_update(str)
    local coretemp_now = parse.find_in_multiline_string(
      str, sensor .. ":[ ]+(.*)°C.*[(]")
    if tonumber(coretemp_now) >= warning then
      temp.widget:show()
      temp.widget:set_bg(beautiful.error)
    else
      temp.widget:hide()
      temp.widget:set_bg(bg)
    end
    temp.widget:set_fg(fg)
    temp.widget:set_text(string.format("%2i°C ", coretemp_now))
  end

  helpers.newtimer("coretemp", update_interval, temp.update)
  return temp.widget
end

return setmetatable(temp, { __call = function(_, ...) return worker(...) end })
