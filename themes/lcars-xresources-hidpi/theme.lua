local gears = require("gears")
local awful = require("awful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local create_theme = require("actionless.common_theme").create_theme
local color_utils = require("actionless.util.color")

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
theme.panel_media = theme.xrdb.color14
theme.panel_layoutbox = theme.xrdb.color7

-- PANEL DECORATIONS:
--
theme.show_widget_icon = false

theme.revelation_fg = theme.xrdb.color13
theme.revelation_border_color = theme.xrdb.color13
theme.revelation_bg = theme.panel_bg
theme.revelation_font = "Monospace Bold 24"
-- FONTS:
theme.font = "Monospace Bold 10"
theme.tasklist_font = theme.font
theme.sans_font = "Sans Bold 10"
-- Don't use sans font:
--theme.sans_font	= "theme.font"

--
--MISC:
--

theme.basic_panel_height = dpi(18)
theme.panel_padding_bottom = dpi(3)

--theme.border_width = dpi(3)
--theme.useless_gap = dpi(6)

--theme.border_radius = dpi(5)
--theme.notification_border_radius = dpi(10)
--theme.panel_widget_border_radius = dpi(4)

--theme.border_radius = dpi(8)
theme.notification_border_radius = dpi(8)
theme.panel_widget_border_radius = dpi(4)

theme.notification_shape = function(cr,w,h)
  gears.shape.rounded_rect(
    cr, w, h, theme.notification_border_radius
  )
end

theme.border_width = dpi(4)
theme.useless_gap = dpi(5)

theme.border_width = dpi(5)
theme.useless_gap = dpi(4)
--theme.useless_gap_edge_left = 0
--theme.useless_gap_edge_bottom = 0
--theme.useless_gap_edge_right = 0

theme.border_width = dpi(4)
--theme.border_radius = dpi(5)

local gtk_util = require("actionless.util.gtk")
local gsc = gtk_util.get_theme_variables()
theme.border_radius = dpi((gsc.border_radius or 1)*1.0)
theme.panel_widget_border_radius = dpi((gsc.border_radius or 1)*0.8)

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
theme.taglist_fg_focus		= "theme.bg"
--theme.taglist_bg_focus		= "theme.xrdb.color6"
if color_utils.is_dark(theme.xrdb.background) then
  --theme.taglist_bg_focus		= "theme.xrdb.color15"
  theme.taglist_bg_focus		= color_utils.darker(theme.panel_taglist, -60)
else
  theme.taglist_bg_focus		= "theme.xrdb.color0"
end
--theme.taglist_bg_focus		= "theme.xrdb.color8"
--theme.taglist_fg_focus		= "theme.xrdb.foreground"

theme.titlebar_fg_normal	= "theme.tasklist_fg_normal"
theme.titlebar_bg_normal	= "theme.border_normal"
theme.titlebar_fg_focus		= "theme.titlebar_fg_normal"
theme.titlebar_bg_focus		= "theme.titlebar_bg_normal"
theme.titlebar_bg_focus		= "theme.titlebar_bg_normal"

if theme.border_radius == 0 then
  theme.border_focus = "theme.xrdb.color10"
  theme.titlebar_bg_focus		= "theme.border_focus"
  theme.titlebar_fg_focus		= "theme.xrdb.background"
end



theme.panel_widget_spacing = dpi(8)

--theme.panel_widget_bg		= theme.xrdb.color3
theme.panel_widget_bg_error = theme.xrdb.color1
theme.panel_widget_fg_error = theme.xrdb.color15

theme.widget_music_bg = theme.xrdb.color11
theme.widget_music_fg = theme.bg

--theme.tasklist_fg_focus = "theme.fg"
theme.tasklist_fg_focus = theme.xrdb.foreground

theme.widget_close_bg = "theme.panel_widget_bg"
theme.widget_close_error_color_on_hover = true

theme.bg_systray    = "theme.panel_widget_bg"


theme = create_theme({ theme_name=theme_name, theme=theme, })

if awesome.composite_manager_running then
  --theme.titlebar_bg_normal = theme.titlebar_bg_normal .."66"
  theme.border_normal       = theme.border_normal .."66"
  theme.border_focus        = theme.border_focus .."66"
  theme.titlebar_bg_normal  = theme.titlebar_bg_normal.."dd"
  --theme.actionless_titlebar_bg_normal = theme.titlebar_bg_normal.."dd"
  theme.actionless_titlebar_bg_normal = theme.titlebar_bg_normal.."66"
  theme.titlebar_bg_focus   = theme.titlebar_bg_focus.."dd"
  theme.actionless_titlebar_bg_focus  = theme.titlebar_bg_focus.."dd"
end

local theme_assets = require("beautiful.theme_assets")
theme = theme_assets.recolor_layout(theme, theme.fg_normal)
-- Recolor titlebar icons:
theme = theme_assets.recolor_titlebar_focus(
  theme, theme.titlebar_fg_focus
)
theme = theme_assets.recolor_titlebar(
  theme, color_utils.darker(theme.titlebar_fg_focus, -70), "focus", "hover"
)
theme = theme_assets.recolor_titlebar_normal(
  theme, theme.titlebar_fg_normal
)
theme = theme_assets.recolor_titlebar(
  theme, color_utils.darker(theme.titlebar_fg_normal, -70), "normal", "hover"
)
theme = theme_assets.recolor_titlebar(theme, theme.xrdb.color1, "focus", "press")
theme = theme_assets.recolor_titlebar(theme, theme.xrdb.color1, "normal", "press")


if color_utils.is_dark(theme.xrdb.background) then
  --theme.clock_fg  = theme.xrdb.color15
  theme.clock_fg = color_utils.darker(theme.xrdb.foreground, -16)
  --theme.tasklist_fg_focus = color_utils.darker(theme.fg, -33)
  theme.tasklist_fg_focus = color_utils.darker(theme.xrdb.foreground, 12)
  --theme.border_normal = color_utils.darker(theme.xrdb.background, -20)
else
  --theme.clock_fg  = theme.xrdb.color0
  theme.clock_fg = color_utils.darker(theme.xrdb.foreground, 16)
  --theme.border_normal = color_utils.darker(theme.xrdb.background, 20)
end

-- WALLPAPER:
--theme.wallpaper_layout = "tiled"
theme.wallpaper = nil
theme.wallpaper_cmd     = "nitrogen --restore"


return theme
