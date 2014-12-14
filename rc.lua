--[[
OH HI
--]]

-- localization
os.setlocale(os.getenv("LANG"))

local eminent = require("eminent")
eminent.create_new_tag = false
local awful = require("awful")
require("awful.autofocus")
local beautiful	= require("beautiful")

local context = {

  widgets = {},
  menu = {},

  modkey = "Mod4",
  altkey = "Mod1",
  theme_dir = awful.util.getdir("config") .. "/themes/noble_dark/theme.lua",
  config = {
    net_preset = 'netctl-auto',
    wlan_if = 'wlp12s0',
    eth_if = 'enp0s25',
    cpu_cores_num = 2,
    music_players = { 'mpd' },
    music_dir = '~/music/',
  },

  autorun = {},

}

local local_settings_result, local_settings_details = pcall(function()
  local local_config = require("config.local")
  if local_config then
    context = local_config.init(context) or context
  end
end)
if local_settings_result ~= true then
  local naughty = require("naughty")
  naughty.notify({ preset = naughty.config.presets.critical,
                   title = "Oops, there were errors during loading local config!",
                   text = local_settings_details })
end
beautiful.init(context.theme_dir)

local widget_config = require("actionless.config")
widget_config.init(context)

local config = require("config")
config.notify.init(context)
config.variables.init(context)
config.autorun.init(context)
config.layouts.init(context)
config.menus.init(context)
config.widgets.init(context)
config.toolbar.init(context)
config.keys.init(context)
config.rules.init(context)
config.signals.init(context)

    --require("collision") {
        ----        Normal    Xephyr       Vim      G510
        --up    = { "Up"    , "&"        , "ak"   , "F15" },
        --down  = { "Down"  , "KP_Enter" , "aj"   , "F14" },
        --left  = { "Left"  , "#"        , "ah"   , "F13" },
        --right = { "Right" , "\""       , "al"   , "F17" },
    --}

-- vim: set shiftwidth=2:
local hotkeys	= require("hotkeys")
