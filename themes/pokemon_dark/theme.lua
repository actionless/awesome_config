local generate_theme = require("actionless.common_theme").generate_theme

local awful = require("awful")
local theme_dir = awful.util.getdir("config").."/themes/pokemon_dark"


-- GENERATE DEFAULT THEME:
--
local theme = generate_theme(
  theme_dir
)

-- CUSTOMIZE default theme:-----------------------------------------------

-- TERMINAL COLORSCHEME:
--
theme.color = {
  --black
  ["0"] = '#000000',
  ["8"] = '#465457',
  --red
  ["1"] = '#960050',
  ["9"] = '#F92672',
  --green
  ["2"] = '#008877',
  ["10"] = '#A6E22E',
  --yellow
  ["3"] = '#FD971F',
  ["11"] = '#e6db74',
  --blue
  ["4"] = '#7711dd',
  ["12"] = '#8432ff',
  --purple
  ["5"] = '#890089',
  ["13"] = '#85509b',
  --cyan
  ["6"] = '#00d6b5',
  ["14"] = '#51edbc',
  --white
  ["7"] = '#888a85',
  ["15"] = '#ffffff',
  --
  bg  = '#0e0021',
  fg  = '#bcbcbc',
  c  = '#ae81ff',
}

-- PANEL COLORS:
--
theme.panel_taglist = "theme.color.7"
theme.panel_close = "theme.color.1"
theme.panel_tasklist = "theme.color.bg"
theme.panel_media = "theme.color.14"
theme.panel_info = "theme.color.13"
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


theme = require("actionless.common_theme").fill_theme(theme)
return theme
