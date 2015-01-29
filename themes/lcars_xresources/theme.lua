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
--
-- Use plain color:
--theme.wallpaper_cmd     = "hsetroot"
-- Use nitrogen:
theme.wallpaper_cmd     = "nitrogen --restore"
-- Use wallpaper tile:
--theme.wallpaper = theme_dir .. '/umbreon_pattern.png'

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

theme.font = "Monospace Bold "..tostring(dpi(8)) -- meslo lg s
theme.sans_font = "Sans Bold "..tostring(dpi(8)) -- ubuntu sans

-- Don't use sans font:
--theme.sans_font	= "theme.font"

--
--MISC:
--

theme.taglist_squares_sel       = nil
theme.taglist_squares_unsel     = nil

theme.titlebar_fg_focus		= "theme.titlebar_border"
theme.titlebar_bg_focus		= "theme.titlebar_focus_border"
theme.titlebar_fg_normal	= "theme.tasklist_fg_normal"
theme.titlebar_bg_normal	= "theme.titlebar_border"

theme.border_width = 6
theme.titlebar_height = 24

--131dpi:
-- {{{
--theme.font = "Meslo LG S Bold 10.2"
--theme.font = "Monospace Bold 12" -- Fantasque Sans Mono
--theme.sans_font = "Ubuntu Sans Bold 10.3"
--theme.sans_font = "Sans Bold 9.6" -- Ubuntu Sans
--theme.sans_font      = "theme.font"
--theme.panel_height             = 26
--theme.panel_padding_bottom     = 6
-- }}}

return create_theme({
  theme_name=theme_name,
  theme=theme,
})
