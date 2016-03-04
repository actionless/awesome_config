--[[
  Licensed under GNU General Public License v2
   * (c) 2014, Yauheni Kirylau
--]]

local awful		= require("awful")
local beautiful		= require("beautiful")

local helpers 		= require("actionless.helpers")
local h_string 		= require("utils.string")
local parse 		= require("utils.parse")
local common_widget	= require("actionless.widgets.common").decorated


-- Batterys info
local bat = {}

local function worker(args)
  args = args or {}
  local exec = args.exec or "xfce4-power-manager-settings"
  local update_interval = args.update_interval or 30
  local device = args.device or "battery_BAT0"
  local bg = args.bg or beautiful.panel_fg or beautiful.fg
  local fg = args.fg or beautiful.panel_bg or beautiful.bg
  local show_when_charged = args.show_when_charged or false

  local widget = common_widget()
  bat.now = {
    percentage = "N/A",
    state = "N/A",
    on_low_battery = nil
  }
  widget:buttons(awful.util.table.join(
    awful.button({ }, 1, function()
      awful.spawn.with_shell(exec)
    end)
  ))

  local function update_widget_data()
    widget:set_markup(
      string.format("%-2s%% ", bat.now.percentage)
    )
    -- charged:
    if bat.now.state == 'fully-charged' then
      widget:set_image(beautiful.widget_ac)
      widget:set_bg(bg)
      widget:set_fg(fg)
    -- charging:
    elseif bat.now.state == 'charging' then
      if bat.now.percentage and bat.now.percentage < 30 then
        widget:set_image(beautiful.widget_ac_charging_low)
        widget:set_bg(beautiful.panel_widget_bg_warning)
        widget:set_fg(beautiful.panel_widget_fg_warning)
      else
        widget:set_image(beautiful.widget_ac_charging)
        widget:set_bg(bg)
        widget:set_fg(fg)
      end
    -- on battery:
    else
      if bat.now.on_low_battery == 'yes' then
        widget:set_image(beautiful.widget_battery_empty)
        widget:set_bg(beautiful.panel_widget_bg_error)
        widget:set_fg(beautiful.panel_widget_fg_error)
      elseif bat.now.percentage and bat.now.percentage < 30 then
        widget:set_image(beautiful.widget_battery_low)
        widget:set_bg(beautiful.panel_widget_bg_warning)
        widget:set_fg(beautiful.panel_widget_fg_warning)
      else
        widget:set_image(beautiful.widget_battery)
        widget:set_bg(bg)
        widget:set_fg(fg)
      end
    end
  end

  local function post_update(stdout)
    bat.now = parse.find_values_in_string(
      stdout, "[ ]+(.*):[ ]+(.*)",
      { percentage='percentage',
        state='state',
        on_low_battery='on-low-battery' }
    )
    bat.now.percentage = h_string.only_digits(bat.now.percentage)
    if bat.now.state == 'fully-charged' and not show_when_charged then
      widget:hide()
    else
      update_widget_data()
      widget:show()
    end
  end

  local function update()
    awful.spawn.easy_async(
      'upower -i /org/freedesktop/UPower/devices/' .. device,
      post_update)
  end

  helpers.newinterval(update_interval, update)

  return widget
end

return setmetatable(bat, { __call = function(_, ...) return worker(...) end })
