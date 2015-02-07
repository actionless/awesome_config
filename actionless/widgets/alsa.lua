--[[
  Licensed under GNU General Public License v2
   * (c) 2013-2014, Yauhen Kirylau
   * (c) 2013, Luke Bonham
   * (c) 2010, Adrian C. <anrxc@sysphere.org>
--]]

local awful		= require("awful")
local beautiful		= require("beautiful")

local async	        = require("actionless.async")
local decorated_widget	= require("actionless.widgets.common").decorated
local newinterval	= require("actionless.helpers").newinterval


-- ALSA volume
local alsa = {
  volume = {
    status = "N/A",
    level = "0",
    in_progress = false,
    delta = 0
  },
}

local function worker(args)
  local args = args or {}

  args.fg = args.fg or beautiful.panel_widget_fg or beautiful.bg or '#000000'
  args.bg = args.bg or beautiful.panel_widget_bg or beautiful.fg or '#ffffff'
  alsa.step = args.step or 2
  alsa.update_interval  = args.update_interval or 5
  alsa.channel  = args.channel or "Master"
  alsa.mic_channel = args.mic_channel or "Capture"
  alsa.channels_toggle = args.channels_toggle or {alsa.channel, }

  alsa.widget = decorated_widget(args)
  alsa.widget:buttons(awful.util.table.join(
    awful.button({ }, 1, function () alsa.toggle() end),
    awful.button({ }, 5, function () alsa.down() end),
    awful.button({ }, 4, function () alsa.up() end)
  ))

  function alsa.apply_volume()
    if alsa.volume.in_progress then
      return
    end
    alsa.volume.in_progress = true
    local volume_delta = alsa.volume.delta
    local direction = "%+"
    local volume_delta_command = volume_delta
    if volume_delta < 0 then
      direction = "%-"
      volume_delta_command = -volume_delta
    end
    async.execute(
      "amixer -q set " .. alsa.channel ..
      ",0 " .. volume_delta_command .. direction,
      function()
        alsa.volume.in_progress = false
        alsa.volume.level = alsa.volume.level + volume_delta
        alsa.update_indicator()

        local new_volume_delta = alsa.volume.delta
        alsa.volume.delta =  new_volume_delta - volume_delta
        if new_volume_delta ~= 0 then alsa.apply_volume() end
      end)
  end

  function alsa.get_step()
    if alsa.volume.in_progress then
      return alsa.step * 2
    else
      return alsa.step
    end
  end

  function alsa.up()
    if alsa.volume.level < 100 then
      alsa.volume.delta = alsa.volume.delta + alsa.get_step()
    end
    alsa.apply_volume()
  end

  function alsa.down()
    if alsa.volume.level > 0 then
      alsa.volume.delta = alsa.volume.delta - alsa.get_step()
    end
    alsa.apply_volume()
  end

  function alsa.toggle()
    if alsa.volume.status == 'off' then
      for _, channel in pairs(alsa.channels_toggle) do
        awful.util.spawn_with_shell("amixer -q set " .. channel .. ",0 on")
      end
    else
      awful.util.spawn_with_shell("amixer -q set " .. alsa.channel .. ",0 off")
    end
    if alsa.volume.status == 'off' then
      alsa.volume.status = 'on'
    else
      alsa.volume.status = 'off'
    end
    alsa.update_indicator()
  end

  function alsa.toggle_mic()
    awful.util.spawn("amixer -q set " .. alsa.mic_channel .. ",0 toggle")
  end

  function alsa.update_indicator()
    if alsa.volume.status == "off" then
      alsa.widget:set_warning()
      alsa.widget:set_icon('vol_mute')
    elseif alsa.volume.level == 0 then
      alsa.widget:set_error()
      alsa.widget:set_icon('vol')
    else
      alsa.widget:set_normal()
      if alsa.volume.level <= 25 then
        alsa.widget:set_icon('vol_low')
      elseif alsa.volume.level <= 75 then
        alsa.widget:set_icon('vol')
      else
        alsa.widget:set_icon('vol_high')
      end
    end
    alsa.widget:set_text(
      string.format(
        "%4s",
        alsa.volume.level .. "%"
    ))
  end

  function alsa.update()
    async.execute(
      'amixer get ' .. alsa.channel,
      function(str)
        local level, status = str:match("([%d]+)%%.*%[([%l]*)")
        level = tonumber(level) or nil

        if level == nil
        then
          level  = 0
          status = "off"
        end

        if status == ""
        then
          if level == 0
          then
            status = "off"
          else
            status = "on"
          end
        end

        alsa.volume.level = level
        alsa.volume.status = status
        alsa.update_indicator()
      end
    )
  end

  newinterval("alsa", alsa.update_interval, alsa.update)
  return setmetatable(alsa, { __index = alsa.widget })
end

return setmetatable(alsa, { __call = function(_, ...) return worker(...) end })
