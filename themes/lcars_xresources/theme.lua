local xresources = require("actionless.xresources")
local create_theme = require("actionless.common_theme").create_theme
local dpi = require("actionless.xresources").compute_fontsize

local theme_name = "lcars_xresources"

local theme = {}

-- TERMINAL COLORSCHEME:
--
theme.color = xresources.get_current_theme()

-- PANEL COLORS:
--
theme.panel_taglist = "theme.color.7"
theme.panel_close = "theme.color.1"
theme.panel_tasklist = "theme.color.bg"
theme.panel_media = "theme.color.14"
theme.panel_info = "theme.color.13"
theme.panel_layoutbox = "theme.color.7"

-- WALLPAPER:
-- Use nitrogen:
theme.wallpaper_cmd     = "nitrogen --restore"
-- Use wallpaper tile:
--theme.wallpaper = theme_dir .. '/umbreon_pattern.png'

-- PANEL DECORATIONS:
--
theme.show_widget_icon = false
theme.use_iconfont = true
--theme.widget_decoration_arrl = ''
--theme.widget_decoration_arrr = ''
theme.widget_decoration_arrl = ''
theme.widget_decoration_arrr = ''

-- FONTS:
theme.font = "Monospace Bold "..tostring(dpi(9)) -- meslo lg s
theme.sans_font = "Sans Bold "..tostring(dpi(9)) -- ubuntu sans
-- Don't use sans font:
theme.sans_font	= "theme.font"

--
--MISC:
--

theme.panel_padding_bottom = 6
theme.panel_height = 18 + theme.panel_padding_bottom

theme.border_width = 6
theme.titlebar_height = 18 + theme.border_width


theme.taglist_squares_sel       = "theme.null"
theme.taglist_squares_unsel     = "theme.null"

theme.titlebar_fg_focus		= "theme.titlebar_border"
theme.titlebar_bg_focus		= "theme.titlebar_focus_border"
theme.titlebar_fg_normal	= "theme.tasklist_fg_normal"
theme.titlebar_bg_normal	= "theme.titlebar_border"


return create_theme({
  theme_name=theme_name,
  theme=theme,
})
