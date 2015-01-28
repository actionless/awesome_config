--[[
imported from here: https://github.com/barwinco/pro
]]--

local generate_theme = require("actionless.common_theme").generate_theme
local xresources = require("actionless.xresources")
local h_table = require("actionless.table")

local awful = require("awful")
local theme_dir = awful.util.getdir("config").."/themes/pro-medium-light"

local gtk = {}
gtk.bg = "#B8B8B8"
gtk.fg = "#404040"
gtk.base = "#888888"
gtk.select = "#7d4f78"


-- GENERATE DEFAULT THEME:
--
local theme = generate_theme(
  theme_dir
)

-- TERMINAL COLORSCHEME:
--
local color = xresources.get_current_theme()
color.bg    = gtk.bg
color.fg    = gtk.fg
color["0"]  = gtk.base
color["4"]  = gtk.select
color["7"]  = gtk.fg

theme.color = color

theme.panel_opacity = 1
theme.panel_enbolden_details	= true

-- PANEL COLORS:
--
theme.panel_taglist="theme.bg"
theme.panel_close="theme.bg"
theme.panel_tasklist=nil
theme.panel_media="theme.bg"
theme.panel_info="theme.bg"
theme.panel_layoutbox="theme.bg"

theme.fg      = gtk.fg
theme.bg      = gtk.bg
theme.alt_bg  = gtk.base
theme.theme   = gtk.select
theme.warning = gtk.select
theme.error   = "#cc4433"

theme.border_width              = "8"
theme.border_focus              = "#94a870"
theme.border_focus              = "#34a890"
theme.titlebar_focus_border     = "theme.border_focus"


theme.panel_widget_fg = gtk.fg
theme.panel_widget_bg = gtk.bg

theme.taglist_fg_occupied	= gtk.fg
theme.taglist_fg_empty		= gtk.fg
theme.taglist_fg_focus		= "#ddbb99"

theme.taglist_bg_focus		= gtk.base
theme.tasklist_fg_focus		= gtk.fg
theme.tasklist_fg_minimize	= gtk.fg
theme.tasklist_bg_minimize	= gtk.base

theme.titlebar_fg_focus         = "theme.tasklist_fg_focus"
theme.titlebar_fg_normal        = gtk.fg

theme.naughty_preset.bg = gtk.base
theme.naughty_preset.bg = "#111111"
theme.naughty_preset.border_color = theme.naughty_preset.bg
theme.naughty_mono_preset = h_table.deepcopy(theme.naughty_preset)

theme.player_artist = gtk.select
theme.player_title = gtk.fg

-- CUSTOMIZE default theme:-----------------------------------------------

-- WALLPAPER:
-- Use nitrogen:
--theme.wallpaper_cmd     = "nitrogen --restore"
-- Use wallpaper tile:
theme.wallpaper = theme_dir .. '/pro-medium-light-shadow.png'
theme.wallpaper_layout = "centered"

-- PANEL DECORATIONS:
--
theme.widget_decoration_arrl = 'sq'
theme.widget_decoration_arrr = 'sq'
theme.widget_decoration_image_arrl = theme_dir .. '/icons/common/decoration_l.png'
theme.widget_decoration_image_arrr = theme_dir .. '/icons/common/decoration_r.png'
theme.widget_decoration_image_bg = theme_dir .. '/icons/common/decoration_bg.png'
theme.widget_decoration_image_sq = theme_dir .. '/icons/common/decoration_sq.png'
--theme.widget_decoration_arrl = ''
--theme.widget_decoration_arrr = ''

theme.panel_height		= 22
theme.panel_padding_bottom	= 0

theme.show_widget_icon = true
------------------------------------------------------------------------------
-- FONTS:
--Ubuntu patches:
--theme.font = "Monospace 10.5"
--theme.sans_font = "Sans 10.3"
--theme.tasklist_font = "Sans Bold 10.3"

theme.font = "Monospace 10"
theme.sans_font = "Sans 10"
-- Don't use sans font:
--theme.sans_font	= theme.font
--
theme.tasklist_font = "Sans Bold 10"
theme.naughty_preset.font = theme.sans_font
theme.naughty_mono_preset.font = theme.font

theme = require("actionless.common_theme").fill_theme(theme)
return theme
