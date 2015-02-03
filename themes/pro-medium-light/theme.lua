--[[
imported from here: https://github.com/barwinco/pro
]]--

local create_theme = require("actionless.common_theme").create_theme
local xresources = require("actionless.xresources")
local dpi = xresources.compute_fontsize

local awful = require("awful")
local theme_dir = awful.util.getdir("config").."/themes/pro-medium-light"

local gtk = {}
gtk.bg = "#B8B8B8"
gtk.fg = "#404040"
gtk.base = "#888888"
gtk.select = "#7d4f78"


-- GENERATE DEFAULT THEME:
--
local theme = {}

-- TERMINAL COLORSCHEME:
--
local color = xresources.get_current_theme()
color.bg    = gtk.bg
color.fg    = gtk.fg
theme.color = color

theme.fg      = gtk.fg
theme.bg      = gtk.bg
theme.alt_bg  = gtk.base
theme.theme   = gtk.select
theme.warning = "theme.color.2"
theme.error   = "theme.color.1"

theme.border_width              = "8"
theme.border_focus              = "#34a890"
theme.titlebar_focus_border     = "theme.border_focus"

theme.panel_opacity = 1
theme.panel_enbolden_details	= true

theme.widget_close_left_decorators = { 'arrl', 'sq', 'sq' }
theme.widget_close_right_decorators = { 'sq', 'sq', 'arrr', }

-- PANEL COLORS:
--
theme.panel_taglist="theme.bg"
theme.panel_close="theme.bg"
theme.panel_tasklist="theme.null"
theme.panel_media="theme.bg"
theme.panel_info="theme.bg"
theme.panel_layoutbox="theme.bg"

--theme.panel_widget_fg_warning	= "theme.warning"
--theme.panel_widget_fg_error 	= "theme.error"
theme.panel_widget_fg_warning	= "theme.fg"
theme.panel_widget_fg_error 	= "theme.fg"

theme.fg_urgent		= "theme.error"

theme.panel_widget_fg = gtk.fg
theme.panel_widget_bg = gtk.bg

theme.taglist_fg_occupied	= gtk.fg
theme.taglist_fg_empty		= gtk.fg
theme.taglist_fg_focus		= "#ddbb99"

theme.tasklist_fg_focus		= gtk.fg
theme.tasklist_fg_minimize	= gtk.fg
theme.tasklist_bg_minimize	= gtk.base

theme.titlebar_fg_focus         = "theme.tasklist_fg_focus"
theme.titlebar_fg_normal        = gtk.fg

theme.notification_bg = gtk.base
theme.notification_bg = "#111111"
theme.notification_fg = "#111109"
theme.notification_fg = gtk.bg

theme.player_artist = gtk.select
theme.player_title = gtk.fg

theme.hotkey_widget_fg = "theme.fg"

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

local common_icons_dir = theme_dir .. '/icons/common/'
  theme.taglist_squares_sel_empty	= common_icons_dir .. "square_empty.png"
  theme.taglist_squares_unsel_empty	= common_icons_dir .. "square_empty.png"

--theme.widget_decoration_arrl = ''
--theme.widget_decoration_arrr = ''

  theme.titlebar_height		= 24
theme.panel_height		= 22
theme.panel_padding_bottom	= 0

theme.show_widget_icon = true
------------------------------------------------------------------------------
-- FONTS:
--Ubuntu patches:
--theme.font = "Monospace 10.5"
--theme.sans_font = "Sans 10.3"
--theme.tasklist_font = "Sans Bold 10.3"

theme.font = "Monospace Bold " .. tostring(dpi(8))
theme.sans_font = "Sans Bold " .. tostring(dpi(8))
-- Don't use sans font:
--theme.sans_font	= theme.font
--

return create_theme({
  theme=theme, theme_dir=theme_dir
})
