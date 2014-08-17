local load_default_theme= require("actionless.common_theme").init

local theme_dir = os.getenv("HOME") .. "/.config/awesome/themes/lcars_modern"
local theme = {}
theme.dir = theme_dir

-- BEFORE applyting defakt theme-----------------------------------------------

-- TERMINAL COLORSCHEME:
--
theme.color = {}
--black
theme.color[0]  ='#000000'
theme.color[8]  ='#666699'
--red
theme.color[1]  ='#cc6666'
theme.color[9]  ='#ff3300'
--green (actually orange ;) )
theme.color[2]  ='#ff9966'
theme.color[10] ='#ff9900'
--yellow
theme.color[3]  ='#cc9966'
theme.color[11] ='#ffcc66'
--blue
theme.color[4]  ='#9966ff'
theme.color[12] ='#9999ff'
--purple
theme.color[5]  ='#cc6699'
theme.color[13] ='#cc99cc'
--cyan
theme.color[6]  ='#9999cc'
theme.color[14] ='#99ccff'
--white
theme.color[7]  ='#ffcc99'
theme.color[15] ='#ccccff'

theme.color.b  = '#000000'
theme.color.f  = '#ffffc6'
theme.color.c  = '#cc6699'

-- PANEL COLORS:
--
theme.panel_colors = {
  taglist=2,
  close=1,
  tasklist=4,
  media=14,
  info=13
}

-- LOAD DEFAULT THEME:
--
theme = load_default_theme(theme)


-- AFTER applying default theme:-----------------------------------------------

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
