local load_default_theme= require("actionless.common_theme").init

local theme_dir = os.getenv("HOME") .. "/.config/awesome/themes/lcars_modern_monokai"
local theme = {}
theme.dir = theme_dir

-- BEFORE applyting defakt theme-----------------------------------------------

-- TERMINAL COLORSCHEME:
--
theme.color = {}
--black
theme.color[0] = '#000000'
theme.color[8] = '#465457'
--red
theme.color[1] = '#960050'
theme.color[9] = '#F92672'
--green
theme.color[2] = '#008877'
theme.color[10] = '#A6E22E'
--yellow
theme.color[3] = '#FD971F'
theme.color[11] = '#e6db74'
--blue
theme.color[4] = '#7711dd'
theme.color[12] = '#8432ff'
--purple
theme.color[5] = '#890089'
theme.color[13] = '#85509b'
--cyan
theme.color[6] = '#00d6b5'
theme.color[14] = '#51edbc'
--white
theme.color[7] = '#888a85'
theme.color[15] = '#ffffff'

theme.color.b  = '#0e0021'
theme.color.f  = '#bcbcbc'
theme.color.c  = '#ae81ff'

-- PANEL COLORS:
--
theme.panel_colors = {
  taglist=7,
  close=1,
  tasklist='b',
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
