--[[
  Licensed under GNU General Public License v2
   * (c) 2013-2014, Yauheni Kirylau
--]]

local beautiful		= require("beautiful")
local awful             = require("awful")
local gears_timer = require("gears.timer")

local common_widget	= require("actionless.widgets.common").decorated
local parse		= require("actionless.util.parse")
local s_helpers		= require("actionless.util.string")


local netctl = {
  widget = common_widget()
}

local function worker(args)
  args = args or {}
  local update_interval = args.update_interval or 15
  local bg = args.bg or beautiful.panel_widget_bg or beautiful.panel_bg or beautiful.bg
  local fg = args.fg or beautiful.panel_widget_fg or beautiful.panel_fg or beautiful.fg
  local font = args.font or beautiful.panel_widget_font or beautiful.panel_font or beautiful.font
  netctl.timeout = args.timeout or 0
  netctl.font = args.font or font

  netctl.widget:set_bg(bg)
  netctl.widget:set_fg(fg)

  netctl.preset = args.preset or 'bond' -- or netctl or netctl-auto
  netctl.wlan_if = args.wlan_if or 'wlan0'
  netctl.eth_if = args.eth_if or 'eth0'

  local function do_update_wifi(wargs)
    local cmd = wargs.cmd
    local match = wargs.match
    local found = wargs.found or 'wifi up'
    local fallback = wargs.fallback or 'searching...'
    awful.spawn.easy_async(
      cmd,
      function(stdout)
        local got_match = stdout:match(match)
        --netctl.update_widget(got_match or fallback)
        --
        netctl.widget:set_text(found or got_match or fallback)
        if got_match then
          netctl.widget:set_image(beautiful.widget_net_wifi)
        else
          netctl.widget:set_image(beautiful.widget_net_searching)
        end
      end)
  end

  function netctl.update()
    if netctl.preset == 'bond' then
      netctl.update_bond()
    elseif netctl.preset == 'netctl-auto' then
      netctl.netctl_auto_update()
    elseif netctl.preset == 'netctl' then
      netctl.netctl_update()
    elseif netctl.preset == 'systemd' then
      do_update_wifi{
        cmd = "systemctl list-unit-files systemd-networkd.service",
        match = "systemd%-(networkd)%.service.*enabled.*",
        found = 'networkd up',
        fallback = 'networkd...'
      }
    elseif netctl.preset == 'wpa_supplicant' then
      do_update_wifi{
        cmd = "systemctl status wpa_supplicant.service",
        match = "Active: active",
        found = 'wpa up',
        fallback = 'wpa_supplicant...'
      }
    end
  end

  function netctl.update_bond()
    netctl.interface = parse.find_in_file(
      "/proc/net/bonding/bond0",
      "Currently Active Slave: (.*)"
    ) or 'bndng.err'
    if netctl.interface == netctl.eth_if then
      netctl.update_widget('ethernet')
    elseif netctl.interface == netctl.wlan_if then
      netctl.wpa_update()
    elseif netctl.interface == "None" then
      netctl.update_widget("bndng...")
    else
      netctl.update_widget(netctl.interface)
    end
  end

  function netctl.wpa_update()
    awful.spawn.easy_async(
      "sudo wpa_cli status",
      function(stdout)
        netctl.update_widget(
          stdout:match(".*ssid=(.*)\n.*"
          ) or 'wpa...')
      end)
  end

  function netctl.netctl_auto_update()
    awful.spawn.easy_async(
      'sudo netctl-auto current',
      function(stdout)
        netctl.update_widget(stdout:match("^(.*)\n.*") or 'nctl-a...')
      end)
  end

  function netctl.netctl_update()
    awful.spawn.easy_async(
      "systemctl list-unit-files 'netctl*'",
      function(stdout)
        netctl.update_widget(
          s_helpers.split(
            stdout:match("netctl(.*)%.service.*enabled") or 'nctl...',
            "\n"
          )[1]
        )
      end)
  end

  function netctl.update_widget(network_name)
    netctl.widget:set_text(network_name)
    if netctl.interface == netctl.eth_if then
      netctl.widget:set_image(beautiful.widget_net_wired)
    elseif netctl.interface == netctl.wlan_if then
      netctl.widget:set_image(beautiful.widget_net_wifi)
    else
      netctl.widget:set_image(beautiful.widget_net_searching)
    end
  end

  gears_timer({
    callback=netctl.update,
    timeout=update_interval,
    autostart=true,
    call_now=true,
  })

  return setmetatable(
    netctl,
    { __index = netctl.widget }
  )
end

return setmetatable(
  netctl,
  { __call = function(_, ...)
    return worker(...)
  end }
)
