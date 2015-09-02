--[[
OH HI
--]]

-- localization
os.setlocale(os.getenv("LANG"))
local editor = "vim" or os.getenv("EDITOR") or "nano" or "vi"

local xresources = require("beautiful.xresources")
local awful = require("awful")
require("awful.autofocus")

local debug = require("utils.debug")


local function st_color_line(theme_table)
  local colors = {}
  for k, v in pairs(theme_table) do
    table.insert(colors, (
      k:match("color(.*)") or
      (k=='background' and "257") or
      (k=='foreground' and "256")
    ).."="..v)
  end
  return table.concat(colors, ",")
end

local colorscheme = xresources.get_current_theme()
local terminal = 'st -b "' .. st_color_line(colorscheme) .. '" '
colorscheme.background, colorscheme.foreground = colorscheme.foreground, colorscheme.background
local terminal_light = 'st -b "' .. st_color_line(colorscheme) .. '" '


-- GLOBALS:
nlog = debug.nlog
log = debug.log

context = {

  modkey = "Mod4",
  altkey = "Mod1",

  theme_dir = awful.util.getdir("config") .. "/themes/lcars-xresources-hidpi/theme.lua",

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
    scrot_preview_cmd = [['mv $f ~/images/ && viewnior ~/images/$f']],
  },

  autorun = {},
  widgets = {},
  menu = {},

  have_battery = true,
  new_top = false,
  --sensor = "temp1",
  sensor = "Core 0",

}

local local_settings_result, local_settings_details = pcall(function()
  context = require("config.local").init(context) or context
end)
if local_settings_result ~= true then
  nlog("!!!WARNING: local settings not found")
  print(local_settings_details)
end

local beautiful	= require("beautiful")
beautiful.init(context.theme_dir)

local config = require("config")
config.notify.init(context)
config.autorun.init(context)
config.menus.init(context)
config.widgets.init(context)
config.toolbar.init(context)
config.toolbar_fallback.init(context)
config.keys.init(context)
config.signals.init(context)
config.lcars_layout.init(context)
config.layouts.init(context)
config.rules.init(context)
require("hotkeys")

--require("third_party").collision {
    ----        Normal    Xephyr       Vim      G510
    --up    = { "Up"    , "&"        , "ak"   , "F15" },
    --down  = { "Down"  , "KP_Enter" , "aj"   , "F14" },
    --left  = { "Left"  , "#"        , "ah"   , "F13" },
    --right = { "Right" , "\""       , "al"   , "F17" },
--}

-- vim: set shiftwidth=2:
