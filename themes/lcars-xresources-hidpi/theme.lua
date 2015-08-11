local awful = require("awful")
local recolor_image = require("gears").color.recolor_image
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local create_theme = require("actionless.common_theme").create_theme

local theme_name = "lcars-xresources-hidpi"

theme_dir = awful.util.getdir("config").."/themes/"..theme_name
--local theme = dofile("/usr/share/awesome/themes/xresources/theme.lua")
local theme = {}

theme.xrdb = xresources.get_current_theme()

theme.dir = theme_dir
theme.icons_dir = theme.dir .. "/icons/"

--theme.hidpi = true

theme.error = theme.xrdb.color1
theme.warning = theme.xrdb.color2


-- TERMINAL COLORSCHEME:
--
theme.color = xresources.get_current_theme()

-- PANEL COLORS:
--
theme.panel_taglist = theme.xrdb.color7
theme.panel_close = theme.xrdb.color1
theme.panel_tasklist = theme.xrdb.background
theme.panel_media = theme.xrdb.color14
theme.panel_info = theme.xrdb.color13
theme.panel_layoutbox = theme.xrdb.color7
--theme.widget_layoutbox_bg = theme.panel_layoutbox
--theme.widget_layoutbox_fg = theme.panel_widget_fg

-- WALLPAPER:
-- Use nitrogen:
theme.wallpaper = nil
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
--theme.font = "Monospace Bold "..tostring(dpi(10))
--theme.small_font = "Monospace "..tostring(dpi(7))
--theme.sans_font = "Sans Bold "..tostring(dpi(10))
theme.font = "Monospace Bold 10"
theme.small_font = "Monospace 7"
theme.sans_font = "Sans Bold 10"
-- Don't use sans font:
--theme.sans_font	= "theme.font"

--theme.font = "Roboto Condensed Bold "..tostring(dpi(10))
--theme.sans_font = "Roboto Condensed Bold "..tostring(dpi(10))

--
--MISC:
--

theme.basic_panel_height = dpi(18)
theme.panel_padding_bottom = dpi(3)
theme.border_width = dpi(3)
theme.useless_gap = dpi(10)
theme.panel_height = theme.basic_panel_height + theme.panel_padding_bottom
theme.titlebar_height = theme.basic_panel_height + theme.border_width

theme.left_panel_internal_corner_radius = dpi(30)

theme.left_panel_width = dpi(120)
theme.left_widget_min_height = dpi(120)

theme.menu_height		= dpi(16)
theme.menu_width		= dpi(150)
theme.menu_border_color = theme.xrdb.color1


--theme.taglist_squares_sel       = "theme.null"
--theme.taglist_squares_unsel     = "theme.null"
--theme.taglist_fg_focus		= "theme.theme"

theme.titlebar_fg_focus		= "theme.titlebar_border"
theme.titlebar_bg_focus		= "theme.titlebar_focus_border"
theme.titlebar_fg_normal	= "theme.tasklist_fg_normal"
theme.titlebar_bg_normal	= "theme.titlebar_border"


--theme.border_normal            = theme.color["8"]
--theme.border_normal            = "#1d1234"
--theme.titlebar_border           = theme.border_normal



--theme.panel_widget_bg		= theme.xrdb.color3
theme.panel_widget_bg_error = theme.xrdb.color1
theme.panel_widget_fg_error = theme.xrdb.color15

theme.widget_music_bg = theme.xrdb.color11
theme.widget_music_fg = theme.bg

theme.widget_close_bg = theme.tasklist_fg_focus

--theme.wallpaper_cmd     = "hsetroot -solid \"" .. theme.bg .. "\""

theme = create_theme({ theme_name=theme_name, theme=theme, })

-- Recolor titlebar icons:
for _, titlebar_icon in ipairs({
    'titlebar_close_button_normal',
    'titlebar_minimize_button_normal_inactive',
    'titlebar_ontop_button_normal_inactive',
    'titlebar_ontop_button_normal_active',
    'titlebar_sticky_button_normal_inactive',
    'titlebar_sticky_button_normal_active',
    'titlebar_floating_button_normal_inactive',
    'titlebar_floating_button_normal_active',
    'titlebar_maximized_button_normal_inactive',
    'titlebar_maximized_button_normal_active',
}) do
    theme[titlebar_icon] = recolor_image(theme[titlebar_icon], theme.titlebar_fg_normal)
end
for _, titlebar_icon in ipairs({
    'titlebar_close_button_focus',
    'titlebar_minimize_button_focus_inactive',
    'titlebar_ontop_button_focus_inactive',
    'titlebar_ontop_button_focus_active',
    'titlebar_sticky_button_focus_inactive',
    'titlebar_sticky_button_focus_active',
    'titlebar_floating_button_focus_inactive',
    'titlebar_floating_button_focus_active',
    'titlebar_maximized_button_focus_inactive',
    'titlebar_maximized_button_focus_active',
}) do
    theme[titlebar_icon] = recolor_image(theme[titlebar_icon], theme.titlebar_fg_focus)
end

return theme
