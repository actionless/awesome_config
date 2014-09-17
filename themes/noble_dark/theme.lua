local generate_theme = require("actionless.common_theme").generate_theme

local theme_dir = os.getenv("HOME") .. "/.config/awesome/themes/noble_dark"

-- TERMINAL COLORSCHEME:
--
color = {}
color.b  = '#3c3c3c'
color.f  = '#ffffc6'
color.c  = '#cc6699'
color[0]  = '#2E3436'
color[1]  = '#CC0000'
color[2]  = '#4E9A06'
color[3]  = '#C4A000'
color[4]  = '#3465A4'
color[5]  = '#75507B'
color[6]  = '#06989A'
color[7]  = '#D3D7CF'
color[8]  = '#555753'
color[9]  = '#EF2929'
color[10] = '#8AE234'
color[11] = '#FCE94F'
color[12] = '#729FCF'
color[13] = '#AD7FA8'
color[14] = '#34E2E2'
color[15] = '#eeeeec'

-- PANEL COLORS:
--
panel_colors = {
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
