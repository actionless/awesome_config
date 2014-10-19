local xresources = require("actionless.xresources")
local generate_theme = require("actionless.common_theme").generate_theme

local theme_dir = os.getenv("HOME") .. "/.config/awesome/themes/lcars_xresources"

-- TERMINAL COLORSCHEME:
--
--local colors = xresources.read_theme(
  --os.getenv('HOME') .. '/.Xcolours/monovedek'
--)
--local colors = xresources.read_theme(
--  os.getenv('HOME') .. '/.Xcolours/jwr_dark'
--  )
local colors = xresources.get_current_theme()

-- PANEL COLORS:
--
local panel_colors = {
  taglist=7,
  close=1,
  tasklist='b',
  media=14,
  info=13
}

-- LOAD DEFAULT THEME:
--
local theme = generate_theme(
  theme_dir,
  colors,
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
theme.wallpaper = theme_dir .. '/umbreon_pattern.png'

-- PANEL DECORATIONS:
--
theme.show_widget_icon = false
theme.use_iconfont = true
theme.widget_decoration_arrl = ''
theme.widget_decoration_arrr = ''

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

theme.taglist_font = theme.font
theme.tasklist_font = theme.sans_font
-- Don't use sans font:
--theme.sans_font	= theme.font
--theme.tasklist_font = theme.sans_font

return theme
