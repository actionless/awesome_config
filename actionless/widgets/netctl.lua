--[[
  Licensed under GNU General Public License v2
   * (c) 2013-2014, Yauheni Kirylau
--]]

local beautiful		= require("beautiful")
local awful             = require("awful")

local helpers           = require("actionless.helpers")
local common_widget	= require("actionless.widgets.common").widget
local parse		= require("utils.parse")


local netctl = {
  lie_widget = common_widget()
}

local function worker(args)
  args = args or {}
  local update_interval = args.update_interval or 5
  local font = args.font or beautiful.tasklist_font or beautiful.font
  local bg = args.bg or beautiful.panel_bg or beautiful.bg
  local fg = args.fg or beautiful.panel_fg or beautiful.fg
  netctl.timeout = args.timeout or 0
  netctl.font = args.font or font

  netctl.lie_widget:set_bg(bg)
  netctl.lie_widget:set_fg(fg)

  netctl.preset = args.preset or 'bond' -- or netctl or netctl-auto
  netctl.wlan_if = args.wlan_if or 'wlan0'
  netctl.eth_if = args.eth_if or 'eth0'

  function netctl.update()
    if netctl.preset == 'bond' then
      netctl.update_bond()
    elseif netctl.preset == 'netctl-auto' then
      netctl.netctl_auto_update()
    elseif netctl.preset == 'netctl' then
      netctl.netctl_update()
    elseif netctl.preset == 'systemd' then
      netctl.common_update(
        "systemctl list-unit-files systemd-networkd.service",
        "systemd%-(networkd)%.service.*enabled.*",
        'networkd...'
      )
    elseif netctl.preset == 'wpa_supplicant' then
      netctl.common_update(
        "systemctl status wpa_supplicant.service",
        "Active: active",
        'wpa_supplicant...'
      )
    end
  end

  function netctl.common_update(cmd, match, fallback)
    awful.spawn.easy_async(
      cmd,
      function(stdout)
        netctl.update_widget(stdout:match(match) or fallback)
      end)
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
      "systemctl list-unit-files 'netctl@*'",
      function(stdout)
        netctl.update_widget(
          stdout:match("netctl@(.*)%.service.*enabled"
          ) or 'nctl...')
      end)
  end

  function netctl.update_widget(network_name)
    netctl.lie_widget:set_text(network_name)
    if netctl.interface == netctl.eth_if then
      netctl.lie_widget:set_image(beautiful.lie_widget_net_wired)
    elseif netctl.interface == netctl.wlan_if then
      netctl.lie_widget:set_icon('net_wifi')
    else
      netctl.lie_widget:set_image(beautiful.lie_widget_net_searching)
    end
  end

  helpers.newinterval(update_interval, netctl.update)

  return setmetatable(
    netctl,
    { __index = netctl.lie_widget })
end

return setmetatable(
  netctl,
  { __call = function(_, ...)
    return worker(...)
  end }
)
