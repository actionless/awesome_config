--[[            
  Licensed under GNU General Public License v2 
   * (c) 2013-2014, Yauheni Kirylau             
--]]
local helpers		= require("widgets.helpers")
local newtimer		= helpers.newtimer
local font		= helpers.font
local beautiful		= helpers.beautiful
local mono_preset	= helpers.mono_preset
local first_line	= helpers.first_line
local common_widget	= require("widgets.common").widget

local naughty		= require("naughty")

local string		= { format = string.format }
local setmetatable	= setmetatable


local netctl = {
  widget = common_widget()
}
--netctl.widget:connect_signal(
--  "mouse::enter", function () netctl.show_notification() end)
--netctl.widget:connect_signal(
--  "mouse::leave", function () netctl.hide_notification() end)

local function worker(args)
  local args = args or {}
  local interval = args.interval or 5
  netctl.timeout = args.timeout or 0
  netctl.font = args.font or font

  netctl.preset = args.preset or 'bond' -- or netctl or netctl-auto
  netctl.wireless_if = args.wireless_if or 'wlan0'
  netctl.wired_if = args.wired_if or 'eth0'

  function netctl.hide_notification()
    if netctl.id ~= nil then
      naughty.destroy(netctl.id)
      netctl.id = nil
    end
  end

  function netctl.show_notification()
    netctl.hide_notification()
    netctl.id = naughty.notify({
      text = output,
      timeout = netctl.timeout,
      preset = mono_preset
    })
  end

  function netctl.update()
    if netctl.preset == 'bond' then
      netctl.update_bond()
    elseif netctl.preset == 'netctl-auto' then
      netctl.netctl_auto_update()
    elseif netctl.preset == 'netctl' then
      netctl.netctl_update()
    end
  end

  function netctl.update_bond()
    netctl.interface = helpers.find_value_in_file(
      "/proc/net/bonding/bond0",
      "(.*): (.*)",
      "Currently Active Slave"
    ) or 'bndng.err'
    if netctl.interface == netctl.wired_if then
      netctl.update_widget('ethernet')
    elseif netctl.interface == netctl.wireless_if then
      netctl.netctl_auto_update()
    elseif netctl.interface == "None" then
      netctl.update_widget("bndng...")
    else
      netctl.update_widget(netctl.interface)
    end
  end

  function netctl.netctl_auto_update()
    asyncshell.request(
      'netctl-auto current',
      function(f)
        netctl.update_widget(
          helpers.first_line_in_fo(f)
          or 'nctl-a...')
      end)
  end

  function netctl.netctl_update()
    asyncshell.request(
      "systemctl list-unit-files 'netctl@*'",
      function(f)
        netctl.update_widget(
          helpers.find_in_fo(
            f, "netctl@(.*)%.service.*enabled"
          ) or 'nctl...')
      end)
  end

  function netctl.update_widget(network_name)
    netctl.widget:set_text(string.format("%-6s", network_name))
    if netctl.interface == netctl.wired_if then
      netctl.widget:set_image(beautiful.widget_net_wired)
    elseif netctl.interface == netctl.wireless_if then
      netctl.widget:set_image(beautiful.widget_net_wireless)
    else
      netctl.widget:set_image(beautiful.widget_net_searching)
    end
  end

  newtimer("netctl", interval, netctl.update)

  return setmetatable(
    netctl,
    { __index = netctl.widget })
end

return setmetatable(
  netctl,
  { __call = function(_, ...)
    return worker(...)
  end }
)
