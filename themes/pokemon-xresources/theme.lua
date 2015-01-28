local xresources = require("actionless.xresources")
local generate_theme = require("actionless.common_theme").generate_theme

local awful = require("awful")
local theme_dir = awful.util.getdir("config").."/themes/pokemon-xresources"


-- LOAD DEFAULT THEME:
--
local theme = generate_theme(theme_dir)

-- TERMINAL COLORSCHEME:
--
--theme.colors = xresources.read_theme(
--  os.getenv('HOME') .. '/.Xcolours/jwr_dark'
--  )
theme.colors = xresources.get_current_theme()

-- PANEL COLORS:
--
theme.panel_taglist = "theme.color.7"
theme.panel_close = "theme.color.1"
theme.panel_tasklist = "theme.color.bg"
theme.panel_media = "theme.color.14"
theme.panel_info = "theme.color.13"

-- CUSTOMIZE default theme:-----------------------------------------------

-- WALLPAPER:
--
-- Use plain color:
--theme.wallpaper_cmd     = "hsetroot"
-- Use nitrogen:
theme.wallpaper_cmd     = "nitrogen --restore"
-- Use wallpaper tile:
--theme.wallpaper = theme_dir .. '/umbreon_pattern.png'

-- PANEL DECORATIONS:
--
theme.show_widget_icon = true
theme.use_iconfont = false
--theme.widget_decoration_arrl = ''
--theme.widget_decoration_arrr = ''
theme.widget_decoration_arrl = 'sq'
theme.widget_decoration_arrr = 'sq'

-- FONTS:
--
--theme.font = "Source Code Pro Bold 10.5"
--theme.sans_font = "Source Sans Pro Bold 10.3"
--
--theme.font = "Meslo LG S for Lcarsline Bold 10.5" -- 10.7
--theme.sans_font = "PT Sans Bold 10.3"
--
-- use ~/.fonts.conf, Luke ;)

--infinality:
--theme.font = "Monospace Bold 10.6" -- pt mono
--theme.font = "Monospace Bold 11.2" -- ubuntu mono
--theme.font = "Monospace Bold 10.7" -- meslo lg s
--theme.sans_font = "Sans Bold 10.3" -- ubuntu sans

theme.font = "Monospace Bold 10" -- meslo lg s
theme.sans_font = "Sans Bold 10" -- ubuntu sans

-- Don't use sans font:
--theme.sans_font	= "theme.font"

--
--MISC:
--

theme.taglist_squares_sel       = nil
theme.taglist_squares_unsel     = nil

theme = require("actionless.common_theme").fill_theme(theme)
return theme
