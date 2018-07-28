local awful_util = require("awful.util")


local local_config = {}

function local_config.init(awesome_context)

  local conf = awesome_context.config
  conf.wlan_if = 'wlp4s0'
  conf.eth_if = 'enp0s25'
  conf.net_preset = 'systemd'
  conf.music_players = { 'spotify', 'clementine', 'mopidy' }
  --conf.music_players = { 'mopidy', }

  --awesome_context.theme_dir = awful_util.getdir("config") .. "/themes/lcars-xresources-hidpi/theme.lua"
  --awesome_context.theme_dir = awful_util.getdir("config") .. "/themes/twmish/theme.lua"
  awesome_context.theme_dir = awful_util.getdir("config") .. "/themes/gtk/theme.lua"

  --awesome_context.autorun = {
    --"~/.scripts/tp_unmute",
    --"killall compton ; compton",
  --}

  awesome_context.have_battery = false
  awesome_context.sensor = "temp1"


  awesome_context.before_config_loaded = function()
    -- size fixes for Fanstasque Sans Mono:
    local beautiful = require("beautiful")
    beautiful.font = "Monospace Bold 11"
    beautiful.tasklist_font = "Monospace 11"
    beautiful.panel_widget_font = beautiful.tasklist_font
    beautiful.taglist_font =  beautiful.font
    beautiful.titlebar_font =  beautiful.font
    beautiful.sans_font = "Sans 11"
  end

  awesome_context.after_config_loaded = function()
  end


  return awesome_context
end

return local_config


-- vim: set ft=lua:
