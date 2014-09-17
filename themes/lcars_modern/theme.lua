local generate_theme = require("actionless.common_theme").generate_theme

local theme_dir = os.getenv("HOME") .. "/.config/awesome/themes/monovedek"

-- TERMINAL COLORSCHEME:
--
color = {}
--black
color[0]  ='#000000'
color[8]  ='#666699'
--red
color[1]  ='#cc6666'
color[9]  ='#ff3300'
--green (actually orange ;) )
color[2]  ='#ff9966'
color[10] ='#ff9900'
--yellow
color[3]  ='#cc9966'
color[11] ='#ffcc66'
--blue
color[4]  ='#9966ff'
color[12] ='#9999ff'
--purple
color[5]  ='#cc6699'
color[13] ='#cc99cc'
--cyan
color[6]  ='#9999cc'
color[14] ='#99ccff'
--white
color[7]  ='#ffcc99'
color[15] ='#ccccff'

color.b  = '#000000'
color.f  = '#ffffc6'
color.c  = '#cc6699'

-- PANEL COLORS:
--
panel_colors = {
  taglist=2,
  close=1,
  tasklist=4,
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
--theme.wallpaper = theme_dir .. '/pattern.png'

-- PANEL DECORATIONS:
--
theme.show_widget_icon = false
theme.show_widget_decorations = true
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


return theme
