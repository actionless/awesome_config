-- localization
os.setlocale(os.getenv("LANG"))

require("eminent")
local awful = require("awful")
require("awful.autofocus")
local naughty = require("naughty")
local beautiful	= require("beautiful")
local status = {
  widgets = {},
  menu = {},
  modkey = "Mod4",
  altkey = "Mod1",
  theme_dir = awful.util.getdir("config") .. "/themes/lcars/theme.lua",
  config = {
    net_preset = 'netctl-auto',
    wlan_if = 'wlp12s0',
    eth_if = 'enp0s25',
    cpu_cores_num = 2,
  },
}

pcall(function()
  local local_config = require("config.local")
  if local_config then
    local_config.init(status)
  end
end)
beautiful.init(status.theme_dir)

local config = require("config")

config.notify.init(status)
config.variables.init(status)
config.autorun.init(status)
config.layouts.init(status)
config.menus.init(status)
config.toolbar.init(status)
config.keys.init(status)
config.rules.init(status)
config.signals.init(status)
