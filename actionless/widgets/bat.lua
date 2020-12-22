--[[
  Licensed under GNU General Public License v2
   * (c) 2014, Yauheni Kirylau
--]]

local awful		= require("awful")
local beautiful		= require("beautiful")
local gears_timer = require("gears.timer")
local dpi = beautiful.xresources.apply_dpi

local h_string 		= require("actionless.util.string")
local parse 		= require("actionless.util.parse")
local common_widget	= require("actionless.widgets.common").decorated



local function worker(args)
  args = args or {}
  args.padding = args.padding or {left = dpi(3), right=dpi(5)}
  local update_interval = args.update_interval or 30
  local device = args.device or "battery_BAT0"
  local bg = args.bg or beautiful.panel_fg or beautiful.fg
  local fg = args.fg or beautiful.panel_bg or beautiful.bg
  local show_when_charged = args.show_when_charged or false
  local exec = args.exec or "xfce4-power-manager-settings"

  local bat = {
    now = {
      percentage = "N/A",
      state = "N/A",
      on_low_battery = nil
    },
    widget = common_widget(args),
  }
  bat.widget:buttons(awful.util.table.join(
    awful.button({ }, 1, function()
      awful.spawn.with_shell(exec)
    end)
  ))
  if beautiful.widget_ac then
    bat.widget:set_image(beautiful.widget_ac)
  end

  local function update_widget_data()
    local widget_text = string.format("%-2s%%", bat.now.percentage)
    -- charged:
    if bat.now.state == 'fully-charged' then
      if beautiful.widget_ac then
        bat.widget:set_image(beautiful.widget_ac)
      end
      bat.widget:set_bg(bg)
      bat.widget:set_fg(fg)
    -- charging:
    elseif bat.now.state == 'charging' then
      if not beautiful.show_widget_icon then
        widget_text = 'c:'..widget_text
      end
      if bat.now.percentage and bat.now.percentage < 30 then
        if beautiful.widget_ac_charging_low then
          bat.widget:set_image(beautiful.widget_ac_charging_low)
        end
        bat.widget:set_bg(bg)
        bat.widget:set_fg(fg)
      else
        if beautiful.widget_ac_charging then
          bat.widget:set_image(beautiful.widget_ac_charging)
        end
        bat.widget:set_bg(bg)
        bat.widget:set_fg(fg)
      end
    -- on battery:
    else
      if bat.now.on_low_battery == 'yes' then
        if beautiful.widget_battery_empty then
          bat.widget:set_image(beautiful.widget_battery_empty)
        end
        bat.widget:set_bg(beautiful.panel_widget_bg_error)
        bat.widget:set_fg(beautiful.panel_widget_fg_error)
      elseif bat.now.percentage and bat.now.percentage < 30 then
        if beautiful.widget_battery_low then
          bat.widget:set_image(beautiful.widget_battery_low)
        end
        bat.widget:set_bg(beautiful.panel_widget_bg_warning)
        bat.widget:set_fg(beautiful.panel_widget_fg_warning)
      else
        if beautiful.widget_battery then
          bat.widget:set_image(beautiful.widget_battery)
        end
        bat.widget:set_bg(bg)
        bat.widget:set_fg(fg)
      end
    end
    bat.widget:set_markup(widget_text)
  end

  local function _post_update(stdout)
    bat.now = parse.find_values_in_string(
      stdout, "[ ]+(.*):[ ]+(.*)",
      { percentage='percentage',
        state='state',
        on_low_battery='on-low-battery' }
    )
    bat.now.percentage = h_string.only_digits(bat.now.percentage)
    if bat.now.state == 'fully-charged' and not show_when_charged then
      bat.widget:hide()
    else
      update_widget_data()
      bat.widget:show()
    end
  end

  local function update()
    awful.spawn.easy_async(
      'upower -i /org/freedesktop/UPower/devices/' .. device,
      _post_update)
  end

  gears_timer({
    callback=update,
    timeout=update_interval,
    autostart=true,
    call_now=true,
  })

  return setmetatable(bat, { __index = bat.widget })
end

return setmetatable({}, { __call = function(_, ...) return worker(...) end })
