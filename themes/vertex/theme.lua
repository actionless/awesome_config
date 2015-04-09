local generate_theme = require("actionless.common_theme").generate_theme
local fill_theme = require("actionless.common_theme").fill_theme
local xresources = require("actionless.xresources")
local dpi = xresources.compute_fontsize

local awful = require("awful")
local theme_dir = awful.util.getdir("config").."/themes/vertex"

local gtk = {
  bg = "#454749",
  base = "#2b2b2c",
  fg = "#f3f3f5",
  select = "#ad7fa8"
}


-- GENERATE DEFAULT THEME:
--
local theme = generate_theme(theme_dir)

-- TERMINAL COLORSCHEME:
--
theme.color = xresources.get_current_theme()
theme.color.b  = gtk.bg
theme.color.f  = gtk.fg
theme.color["0"]  = gtk.base
theme.color["4"]  = gtk.select
theme.color["7"]  = gtk.fg

theme.fg = gtk.fg
theme.bg = gtk.bg
theme.theme   = gtk.select
theme.warning = gtk.select

theme.border_width              = "8"
theme.sel_border                = "#a3c24e"


-- PANEL COLORS:
--
theme.panel_opacity = 1
theme.panel_enbolden_details = true

theme.widget_close_left_decorators = { 'arrl', 'sq', 'sq' }
theme.widget_close_right_decorators = { 'sq', 'sq', 'arrr', }

theme.panel_taglist="theme.bg"
theme.panel_close="theme.bg"
theme.panel_tasklist=nil
theme.panel_media="theme.bg"
theme.panel_info="theme.bg"
theme.panel_layoutbox="theme.bg"

theme.panel_widget_fg = gtk.fg
theme.panel_widget_fg_warning = gtk.fg
theme.panel_widget_fg_error = gtk.fg

theme.taglist_fg_focus		= gtk.fg
theme.taglist_bg_focus		= gtk.bg

theme.tasklist_fg_focus		= gtk.fg
theme.tasklist_fg_minimize	= gtk.bg
theme.tasklist_bg_minimize	= gtk.base

theme.titlebar_fg_normal        = "theme.color.8"

theme.notification_bg = gtk.base
theme.notification_bg = "#111111"

theme.player_artist = gtk.select
theme.player_title = gtk.fg

-- CUSTOMIZE default theme:-----------------------------------------------

-- WALLPAPER:
-- Use wallpaper tile:
--theme.wallpaper = theme_dir .. '/vortex.jpg'
--theme.wallpaper_layout = 'centered'
-- Use nitrogen:
theme.wallpaper_cmd     = "nitrogen --restore"

-- PANEL DECORATIONS:
--
theme.widget_decoration_arrl = 'sq'
theme.widget_decoration_arrr = 'sq'
--theme.widget_decoration_arrl = ''
--theme.widget_decoration_arrr = ''
theme.widget_decoration_image_arrl = theme_dir .. '/icons/common/decoration_l.png'
theme.widget_decoration_image_arrr = theme_dir .. '/icons/common/decoration_r.png'
theme.widget_decoration_image_bg = theme_dir .. '/icons/common/decoration_bg.png'
theme.widget_decoration_image_sq = theme_dir .. '/icons/common/decoration_sq.png'
theme.panel_height		= 22
theme.panel_padding_bottom	= 0
theme.show_widget_icon = true

------------------------------------------------------------------------------
-- FONTS:
theme.font = "Fantasque Sans Mono Bold "..dpi(9)
theme.sans_font = "Sans Bold "..dpi(7)
--theme.sans_font      = "theme.font"
-- }}}

theme = fill_theme(theme)
return theme
