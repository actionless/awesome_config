--[[
     Licensed under GNU General Public License v2
      * (c) 2013-2014, Yauheni Kirylau
--]]
local beautiful = require("beautiful")
local awful = require("awful")

local helpers = require("actionless.helpers")
local parse = require("utils.parse")
local common_widget= require("actionless.widgets.common").widget
local decorated_widget= require("actionless.widgets.common").decorated


-- coretemp
local temp = {}

local function worker(args)
  args = args or {}
  local update_interval = args.update_interval or 5
  local warning = args.warning or 75
  local sensor = args.sensor or "CPU Temperature"
  local bg = args.bg or beautiful.panel_widget_bg or beautiful.panel_fg or beautiful.fg
  local fg = args.fg or beautiful.panel_widget_fg or beautiful.panel_bg or beautiful.bg

  args.widget = common_widget(args)
  temp.widget = decorated_widget(args)
  temp.widget:set_image(beautiful.widget_temp)

  function temp.update()
    awful.spawn.easy_async("sensors ", temp.post_update)
  end

  function temp.post_update(str)
    local coretemp_now = parse.find_in_multiline_string(
      str, sensor .. ":[ ]+(.*)°C.*[(]")
    if not coretemp_now then return end
    if tonumber(coretemp_now) >= warning then
      temp.widget:show()
      temp.widget:set_bg(beautiful.panel_widget_bg_error)
      temp.widget:set_fg(beautiful.panel_widget_fg_error)
    else
      temp.widget:hide()
      temp.widget:set_bg(bg)
      temp.widget:set_fg(fg)
    end
    temp.widget:set_text(string.format("%2i°C ", coretemp_now))
  end

  helpers.newinterval(update_interval, temp.update)
  return temp.widget
end

return setmetatable(temp, { __call = function(_, ...) return worker(...) end })
