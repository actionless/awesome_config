local xresources = require("actionless.xresources")
local load_default_theme = require("actionless.common_theme").init

local theme_dir = os.getenv("HOME") .. "/.config/awesome/themes/lcars_xresources"
local theme = {}
theme.dir = theme_dir

-- BEFORE applyting defakt theme-----------------------------------------------

-- TERMINAL COLORSCHEME:
--
theme.color = xresources.read_theme(
  os.getenv('HOME') .. '/.Xcolours/monovedek'
)

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
theme.wallpaper = theme_dir .. '/umbreon_pattern.png'

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
