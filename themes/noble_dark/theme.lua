local generate_theme = require("actionless.common_theme").generate_theme
local xresources = require("actionless.xresources")
local dpi = require("actionless.xresources").compute_fontsize

local awful = require("awful")
local theme_dir = awful.util.getdir("config").."/themes/noble_dark"

local gtk = {}


--gtk.bg = "#454749"
gtk.bg = "#3d3e40"
gtk.base = "#2b2b2c"
gtk.fg = "#f3f3f5"
gtk.select = "#ad7fa8"


-- GENERATE DEFAULT THEME:
--
local theme = generate_theme(theme_dir)

theme.bg = gtk.bg
theme.fg = gtk.fg


-- TERMINAL COLORSCHEME:
--
local color = xresources.get_current_theme()
color.b  = gtk.bg
color.f  = gtk.fg
color["8"]  = gtk.base
color["4"]  = gtk.select
color["7"]  = gtk.fg
color["0"] = gtk.bg
theme.color = color

theme.panel_enbolden_details	= true

-- PANEL COLORS:
theme.panel_taglist = "theme.bg"
theme.panel_close = "theme.color.8"
theme.panel_tasklist = nil
theme.panel_media = "theme.color.8"
theme.panel_info = "theme.color.8"

theme.panel_layoutbox = "theme.color.8"
theme.widget_layoutbox_fg = "theme.panel_layoutbox"
theme.widget_layoutbox_bg = "theme.panel_widget_fg"

theme.theme = gtk.select
theme.warning = gtk.select

theme.border_width              = "8"
theme.border_focus              = "#94a870"
theme.border_focus              = "#a6e22e"
theme.border_focus              = "#a3c24e"


theme.panel_widget_fg = gtk.fg
theme.panel_widget_bg = gtk.bg
theme.panel_opacity = 1

theme.taglist_fg_occupied	= gtk.fg
theme.taglist_fg_empty		= gtk.select
theme.taglist_fg_focus		= gtk.fg

theme.taglist_bg_occupied	= gtk.bg
theme.taglist_bg_empty		= gtk.bg
theme.taglist_bg_focus		= gtk.base

theme.taglist_squares_sel       = nil
theme.taglist_squares_unsel     = nil


theme.tasklist_fg_focus		= gtk.fg
theme.tasklist_fg_minimize	= gtk.bg
theme.tasklist_bg_minimize	= gtk.base

theme.titlebar_fg_focus         = "theme.tasklist_fg_focus"
theme.titlebar_fg_normal        = "theme.color.8"

theme.notification_bg = gtk.base
theme.notification_bg = "#111111"

theme.player_artist = gtk.select
theme.player_title = gtk.fg

-- CUSTOMIZE default theme:-----------------------------------------------

-- WALLPAPER:
-- Use nitrogen:
theme.wallpaper_cmd     = "nitrogen --restore"
-- Use wallpaper tile:
--theme.wallpaper = theme_dir .. '/pattern.png'

-- PANEL DECORATIONS:
--
theme.widget_decoration_arrl = 'sq'
theme.widget_decoration_arrr = 'sq'
--theme.widget_decoration_arrl = ''
--theme.widget_decoration_arrr = ''

theme.show_widget_icon = true
------------------------------------------------------------------------------
-- FONTS:

theme.font = "Monospace Bold "..tostring(dpi(8)) -- meslo lg s
theme.sans_font = "Sans Bold "..tostring(dpi(8)) -- ubuntu sans

theme = require("actionless.common_theme").fill_theme(theme)
return theme
