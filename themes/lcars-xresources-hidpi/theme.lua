local awful = require("awful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local create_theme = require("actionless.common_theme").create_theme
local helpers = require("actionless.helpers")

local theme_name = "lcars-xresources-hidpi"

local theme_dir = awful.util.getdir("config").."/themes/"..theme_name
--local theme = dofile("/usr/share/awesome/themes/xresources/theme.lua")
local theme = {}

theme.xrdb = xresources.get_current_theme()

theme.dir = theme_dir
theme.icons_dir = theme.dir .. "/icons/"

--theme.error = theme.xrdb.color1
--theme.warning = theme.xrdb.color2


-- TERMINAL COLORSCHEME:
--
theme.color = xresources.get_current_theme()
theme.xrdb = xresources.get_current_theme()

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
--theme.widget_decoration_arrl = ''
--theme.widget_decoration_arrr = ''

-- deprecated :
--theme.widget_decoration_arrl = ''
--theme.widget_decoration_arrr = ''

theme.widget_decoration_arrl = '퟾'
theme.widget_decoration_arrr = '퟿'
theme.widget_decoration_arrl = '퟼'
theme.widget_decoration_arrr = '퟽'

theme.revelation_fg = theme.xrdb.color13
theme.revelation_border_color = theme.xrdb.color13
theme.revelation_bg = theme.panel_bg
theme.revelation_font = "Monospace Bold 24"
-- FONTS:
--theme.font = "Monospace Bold "..tostring(dpi(10))
--theme.small_font = "Monospace "..tostring(dpi(7))
--theme.sans_font = "Sans Bold "..tostring(dpi(10))
theme.font = "Monospace Bold 10"
theme.tasklist_font = theme.font
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

--theme.border_width = dpi(3)
--theme.useless_gap = dpi(6)

theme.border_radius = dpi(5)

theme.border_width = dpi(4)
theme.useless_gap = dpi(5)

theme.border_width = dpi(5)
theme.useless_gap = dpi(4)

theme.base_border_width = theme.border_width
theme.border_width = 0

theme.panel_height = theme.basic_panel_height + theme.panel_padding_bottom
theme.titlebar_height = theme.basic_panel_height + theme.base_border_width*2


theme.left_panel_internal_corner_radius = dpi(30)

theme.left_panel_width = dpi(120)
theme.left_widget_min_height = dpi(120)

theme.menu_height		= dpi(16)
theme.menu_width		= dpi(150)
theme.menu_border_color = theme.xrdb.color1

--theme.apw_fg_color = "theme.xrdb.color8"
theme.apw_bg_color = "theme.xrdb.color8"
theme.apw_mute_bg_color = "theme.xrdb.color1"
theme.apw_mute_fg_color = "theme.xrdb.color9"


--theme.taglist_squares_sel       = "theme.null"
--theme.taglist_squares_unsel     = "theme.null"
--theme.taglist_fg_focus		= "theme.theme"
theme.taglist_fg_focus		= "theme.bg"
--theme.taglist_bg_focus		= "theme.xrdb.color6"
theme.taglist_bg_focus		= "theme.xrdb.color15"
--theme.taglist_bg_focus		= "theme.xrdb.color8"
--theme.taglist_fg_focus		= "theme.xrdb.foreground"

--theme.titlebar_fg_focus		= "theme.titlebar_border"
--theme.titlebar_bg_focus		= "theme.titlebar_focus_border"
theme.titlebar_fg_normal	= "theme.tasklist_fg_normal"
theme.titlebar_bg_normal	= "theme.titlebar_border"
theme.titlebar_fg_focus		= "theme.titlebar_fg_normal"
theme.titlebar_bg_focus		= "theme.titlebar_bg_normal"


--if color_utils.is_dark(theme.xrdb.background) then
  --theme.border_normal = color_utils.darker(theme.xrdb.background, -20)
--else
  --theme.border_normal = color_utils.darker(theme.xrdb.background, 20)
--end
--theme.titlebar_border           = theme.border_normal

theme.panel_widget_spacing = dpi(10)
theme.panel_widget_spacing_medium = dpi(8)
theme.panel_widget_spacing_small = dpi(4)

--theme.panel_widget_bg		= theme.xrdb.color3
theme.panel_widget_bg_error = theme.xrdb.color1
theme.panel_widget_fg_error = theme.xrdb.color15

theme.widget_music_bg = theme.xrdb.color11
theme.widget_music_fg = theme.bg

theme.widget_close_bg = theme.tasklist_fg_focus

--theme.wallpaper_cmd     = "hsetroot -solid \"" .. theme.bg .. "\""

theme = create_theme({ theme_name=theme_name, theme=theme, })

--theme.titlebar_bg_normal = theme.titlebar_bg_normal .."66"
theme.border = theme.border .."66"
theme.border_normal = theme.border_normal .."66"
theme.border_focus = theme.border_focus .."66"

-- Recolor titlebar icons:
local theme_assets
pcall(function()
  theme_assets = dofile("/usr/share/awesome/themes/xresources/assets.lua")
end)
if not theme_assets then
  theme_assets = dofile(helpers.get_nix_xresources_theme_path().."/assets.lua")
end
theme = theme_assets.recolor_layout(theme, theme.fg_normal)
theme = theme_assets.recolor_titlebar_normal(theme, theme.titlebar_fg_normal)
theme = theme_assets.recolor_titlebar_focus(theme, theme.titlebar_fg_focus)

return theme
