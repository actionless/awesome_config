--[[
OH HI
--]]

-- localization
os.setlocale(os.getenv("LANG"))
local terminal = "st" or "urxvt -lsp 1 -geometry 120x30" or "xterm"
local terminal_light = "stl"
local editor = "vim" or os.getenv("EDITOR") or "nano" or "vi"

local eminent = require("third_party").eminent
eminent.create_new_tag = false

local awful = require("awful")
require("awful.autofocus")

context = {

  modkey = "Mod4",
  altkey = "Mod1",

  theme_dir = awful.util.getdir("config") .. "/themes/lcars_xresources/theme.lua",

  config = {
    net_preset = 'netctl-auto',
    wlan_if = 'wlp12s0',
    eth_if = 'enp0s25',
    cpu_cores_num = 2,
    music_players = { 'spotify', 'clementine' },
  },

  cmds = {
    terminal = terminal,
    terminal_light = 'stl',
    editor_cmd = terminal .. " -e " .. editor,
    compositor = "killall compton; compton",
    file_manager = "pcmanfm",
    tmux = terminal .. " -e tmux",
    tmux_light = terminal_light .. " -e tmux",
    tmux_run   = terminal .. " -e tmux new-session",
    dmenu = "~/.config/dmenu/dmenu-recent.sh",
    scrot_preview_cmd = [['mv $f ~/images/ && viewnior ~/images/$f']],
  },

  autorun = {},
  widgets = {},
  menu = {},

  volume_widget = "noapw",
}

local local_settings_result, local_settings_details = pcall(function()
  context = require("config.local").init(context) or context
end)
if local_settings_result ~= true then
  print("!!!WARNING: local settings not found")
  print(local_settings_details)
end

local beautiful	= require("beautiful")
beautiful.init(context.theme_dir)

local config = require("config")
config.notify.init(context)
config.autorun.init(context)
config.layouts.init(context)
config.menus.init(context)
config.clientbuttons.init(context)
config.widgets.init(context)
config.toolbar.init(context)
config.keys.init(context)
config.rules.init(context)
config.signals.init(context)
require("hotkeys")

--require("third_party").collision {
    ----        Normal    Xephyr       Vim      G510
    --up    = { "Up"    , "&"        , "ak"   , "F15" },
    --down  = { "Down"  , "KP_Enter" , "aj"   , "F14" },
    --left  = { "Left"  , "#"        , "ah"   , "F13" },
    --right = { "Right" , "\""       , "al"   , "F17" },
--}

-- vim: set shiftwidth=2:
