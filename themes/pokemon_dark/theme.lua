local generate_theme = require("actionless.common_theme").generate_theme

local awful = require("awful")
local theme_dir = awful.util.getdir("config").."/themes/pokemon_dark"

-- TERMINAL COLORSCHEME:
--
local color = {}
--black
color[0] = '#000000'
color[8] = '#465457'
--red
color[1] = '#960050'
color[9] = '#F92672'
--green
color[2] = '#008877'
color[10] = '#A6E22E'
--yellow
color[3] = '#FD971F'
color[11] = '#e6db74'
--blue
color[4] = '#7711dd'
color[12] = '#8432ff'
--purple
color[5] = '#890089'
color[13] = '#85509b'
--cyan
color[6] = '#00d6b5'
color[14] = '#51edbc'
--white
color[7] = '#888a85'
color[15] = '#ffffff'

color.b  = '#0e0021'
color.f  = '#bcbcbc'
color.c  = '#ae81ff'

-- PANEL COLORS:
--
local panel_colors = {
  taglist=7,
  close=1,
  tasklist='b',
  media=14,
  info=13
}

-- GENERATE DEFAULT THEME:
--
local theme = generate_theme(
  theme_dir,
  color,
  panel_colors
)

-- CUSTOMIZE default theme:-----------------------------------------------

-- WALLPAPER:
--
-- Use plain color:
--theme.wallpaper_cmd     = "hsetroot"
-- Use nitrogen:
--theme.wallpaper_cmd     = "nitrogen --restore"
-- Use wallpaper tile:
theme.wallpaper = theme_dir .. '/pattern.png'

-- PANEL DECORATIONS:
--
theme.widget_decoration_arrl = 'sq'
theme.widget_decoration_arrr = 'sq'
theme.show_widget_icon = true

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


return theme
