local xresources = require("actionless.xresources")
local create_theme = require("actionless.common_theme").create_theme
local dpi = require("actionless.xresources").compute_fontsize

local theme_name = "lcars-xresources-hidpi"

local theme = {}

theme.hidpi = true


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
theme.font = "Monospace Bold "..tostring(dpi(10))
theme.sans_font = "Sans Bold "..tostring(dpi(10))
-- Don't use sans font:
--theme.sans_font	= "theme.font"

--
--MISC:
--

theme.basic_panel_height = dpi(18)
theme.panel_padding_bottom = dpi(3)
theme.border_width = dpi(3)
theme.panel_height = theme.basic_panel_height + theme.panel_padding_bottom
theme.titlebar_height = theme.basic_panel_height + theme.border_width

theme.menu_height		= dpi(16)
theme.menu_width		= dpi(150)
theme.menu_border_color = "theme.color.1"


--theme.taglist_squares_sel       = "theme.null"
--theme.taglist_squares_unsel     = "theme.null"
theme.taglist_fg_focus		= "theme.theme"

theme.titlebar_fg_focus		= "theme.titlebar_border"
theme.titlebar_bg_focus		= "theme.titlebar_focus_border"
theme.titlebar_fg_normal	= "theme.tasklist_fg_normal"
theme.titlebar_bg_normal	= "theme.titlebar_border"


--theme.border_normal            = theme.color["8"]
--theme.border_normal            = "#1d1234"
--theme.titlebar_border           = theme.border_normal

theme.error = theme.color["1"]
theme.warning = theme.color["2"]

theme.panel_widget_bg_error = theme.color["1"]
theme.panel_widget_fg_error = theme.color["15"]

theme.widget_close_bg = theme.tasklist_fg_focus

theme = create_theme({
  theme_name=theme_name,
  theme=theme,
})

--theme.wallpaper_cmd     = "hsetroot -solid \"" .. theme.bg .. "\""

return theme
