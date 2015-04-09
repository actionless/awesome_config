local generate_theme = require("actionless.common_theme").generate_theme

local awful = require("awful")
local theme_dir = awful.util.getdir("config").."/themes/monovedek"

-- TERMINAL COLORSCHEME:
--
local color = {}
--black
color["0"]  ='#000000'
color["8"]  ='#666699'
--red
color["1"]  ='#cc6666'
color["9"]  ='#ff3300'
--green (actually orange ;) )
color["2"]  ='#ff9966'
color["10"] ='#ff9900'
--yellow
color["3"]  ='#cc9966'
color["11"] ='#ffcc66'
--blue
color["4"]  ='#9966ff'
color["12"] ='#9999ff'
--purple
color["5"]  ='#cc6699'
color["13"] ='#cc99cc'
--cyan
color["6"]  ='#9999cc'
color["14"] ='#99ccff'
--white
color["7"]  ='#ffcc99'
color["15"] ='#ccccff'
--
color.bg  = '#000000'
color.fg  = '#ffffc6'
color.c  = '#cc6699'

-- GENERATE DEFAULT THEME:
--
local theme = generate_theme(
  theme_dir
)

-- CUSTOMIZE default theme:-----------------------------------------------
--

-- PANEL COLORS:
--
theme.panel_taglist = "theme.color.2"
theme.panel_close = "theme.color.1"
theme.panel_tasklist = "theme.color.4"
theme.panel_media = "theme.color.14"
theme.panel_info = "theme.color.13"
theme.panel_layoutbox = "theme.alt_bg"

theme.color = color

-- WALLPAPER:
--
-- Use plain color:
--theme.wallpaper_cmd     = "hsetroot"
-- Use nitrogen:
--theme.wallpaper_cmd     = "nitrogen --restore"
-- Use wallpaper tile:
--theme.wallpaper = theme_dir .. '/pattern.png'

-- PANEL DECORATIONS:
--
theme.show_widget_icon = false
theme.widget_decoration_arrl = ''
theme.widget_decoration_arrr = ''

-- FONTS:
--
--theme.font = "Source Code Pro Bold 10.5"
--theme.sans_font = "Source Sans Pro Bold 10.3"
--
--theme.font = "Meslo LG S for Lcarsline Bold 10.5"
--theme.sans_font = "PT Sans Bold 10.3"
--
-- use ~/.fonts.conf, Luke ;)
theme.font = "Monospace Bold 10.5"
theme.sans_font = "Sans Bold 10.3"
--
-- Don't use sans font:
--theme.sans_font	= theme.font


theme = require("actionless.common_theme").fill_theme(theme)
return theme
