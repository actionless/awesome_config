local gears = require("gears")
local awful = require("awful")
local xresources = require("beautiful.xresources")
local theme_assets = require("beautiful.theme_assets")
local dpi = xresources.apply_dpi
local create_theme = require("actionless.common_theme").create_theme
local color_utils = require("actionless.util").color
local gtk_util = require("beautiful.gtk")
local recolor_image = require("gears.color").recolor_image
local surface = require("gears.surface")


local theme_name = "gtk"
local gsc = gtk_util.get_theme_variables()

local MAIN_COLOR = gsc.selected_bg_color
local TRANSPARENT = "#00000000"

local theme_dir = awful.util.getdir("config").."/themes/"..theme_name
--local theme = dofile("/usr/share/awesome/themes/xresources/theme.lua")
local theme = {}
theme.dir = theme_dir
theme.icons_dir = theme.dir .. "/icons/"


theme.gtk = gsc
theme.gsc = gsc
theme.xrdb = xresources.get_current_theme()

theme.fg = gsc.fg_color
theme.fg_normal = gsc.fg_color
theme.bg = gsc.bg_color
theme.bg_normal = gsc.bg_color
theme.fg_focus = gsc.selected_fg_color
theme.bg_focus = gsc.selected_bg_color

theme.panel_fg = gsc.menubar_fg_color
theme.panel_bg = gsc.menubar_bg_color

theme.panel_widget_bg = gsc.base_color
theme.panel_widget_fg = gsc.text_color

theme.basic_panel_height = dpi(18)
theme.panel_padding_bottom = dpi(3)
theme.panel_height = theme.basic_panel_height + theme.panel_padding_bottom


local gtk_border_radius = gsc.button_border_radius
local gtk_border_width = gsc.button_border_width
if gtk_border_width < 1 then
  gtk_border_width = 1
end

--theme.border_radius = dpi(gtk_border_radius*1.0)
--theme.client_border_radius = theme.border_radius * 0.8
--theme.panel_widget_border_radius = dpi(gtk_border_radius*0.8)
------ the 3 lines above confirmed to display well with 1x scaling
------ @TODO: double-check on hidpi setup if GDK_SCALE need to be used or not
theme.border_radius = dpi(gtk_border_radius*0.8)
theme.border_radius = math.min(theme.border_radius, theme.basic_panel_height/2)
theme.client_border_radius = "theme.border_radius"
theme.panel_widget_border_radius = "theme.border_radius"

--theme.panel_widget_border_radius = dpi(gtk_border_radius*1.0)
--theme.border_radius = dpi(5)
--theme.panel_widget_border_radius = dpi(5)
local gdk_scale = tonumber(os.getenv("GDK_SCALE") or 1.0)
theme.panel_widget_border_width = gtk_border_width * gdk_scale
--theme.panel_widget_border_width = dpi(gtk_border_width)
--theme.panel_widget_border_width = dpi(gtk_border_width*2)
--theme.panel_widget_border_color = color_utils.mix(gsc.menubar_fg_color, gsc.menubar_bg_color, 0.5)
theme.panel_widget_border_color = color_utils.mix(gsc.menubar_fg_color, gsc.menubar_bg_color, 0.3)
theme.panel_widget_border_color = color_utils.mix(gsc.menubar_fg_color, gsc.menubar_bg_color, 0.2)
--theme.panel_widget_border_color = color_utils.mix(gsc.menubar_fg_color, gsc.menubar_bg_color, 0.15)
--theme.panel_widget_border_color = color_utils.mix(gsc.menubar_fg_color, gsc.menubar_bg_color, 0.12)


theme.widget_close_bg = gsc.header_button_bg_color
theme.widget_close_fg = gsc.header_button_fg_color

theme.tasklist_fg_focus = theme.panel_fg
theme.tasklist_fg_normal = theme.panel_fg
--theme.tasklist_bg_focus = theme.panel_bg
theme.tasklist_bg_focus = TRANSPARENT
theme.tasklist_bg_normal = theme.panel_bg
theme.tasklist_fg_minimize	= theme.xrdb.background
theme.tasklist_bg_minimize	= theme.xrdb.color4


--theme.error = theme.xrdb.color1
--theme.warning = theme.xrdb.color2
theme.warning = theme.xrdb.color3
theme.panel_widget_fg_warning = theme.xrdb.background

-------------------------------------------------------------------------------
-- Colorize tasklist status icons:
-------------------------------------------------------------------------------
local markup = require('actionless.util.markup')
local tasklist_status_icons = {
  ontop = '^',
  sticky = '▪',
  above = '▴',
  below = '▾',
  floating = '✈',
  maximized = '+',
  maximized_horizontal = '⬌',
  maximized_vertical = '⬍',
}
--local tasklist_status = theme.bg_focus
--local tasklist_status = theme.warning
--local tasklist_status = theme.xrdb.color12
--local tasklist_status = theme.xrdb.color14
local tasklist_status = theme.xrdb.color6
local tasklist_status_template = '%s'

tasklist_status_template = markup.bg.color(
  tasklist_status, markup.fg.color(theme.panel_bg, ' '..tasklist_status_template..' ')
)..' '

for icon_name, icon_markup in pairs(tasklist_status_icons) do
  theme['tasklist_'..icon_name] = string.format(tasklist_status_template, icon_markup)
end
-------------------------------------------------------------------------------


-- TERMINAL COLORSCHEME:
--
theme.color = xresources.get_current_theme()

-- PANEL COLORS:
--
theme.panel_taglist = gsc.base_color
theme.panel_close = MAIN_COLOR
theme.panel_media = MAIN_COLOR
theme.panel_layoutbox = theme.xrdb.color7

-- WALLPAPER:
-- Use nitrogen:
theme.wallpaper = nil
theme.wallpaper_cmd     = "nitrogen --restore"
-- Use wallpaper tile:
--theme.wallpaper = theme_dir .. '/umbreon_pattern.png'
-- Specify wallpaper layout:
--theme.wallpaper_layout = 'maximized'
--theme.wallpaper = theme_dir .. '/much_awesome.svg'

-- PANEL DECORATIONS:
--
theme.show_widget_icon = false

theme.revelation_fg = theme.xrdb.color13
theme.revelation_border_color = theme.xrdb.color13
theme.revelation_bg = theme.panel_bg
theme.revelation_font = "Monospace Bold 24"

-- FONTS:
theme.font          = theme.gtk.font_family .. ' ' .. theme.gtk.font_size
theme.sans_font = theme.font

theme.taglist_font = theme.font
theme.tasklist_font = theme.font
if not theme.font:match('Bold') then
  local bold_font = theme.gtk.font_family .. ' Bold ' .. theme.gtk.font_size
  theme.bold_font = bold_font
  theme.titlebar_font = bold_font
  theme.taglist_font = bold_font
else
  theme.bold_font = theme.font
end

theme.mono_font          = "Monospace Bold " .. theme.gtk.font_size - 1
theme.mono_text_font          = "Monospace " .. theme.gtk.font_size - 1
--theme.mono_text_font = theme.mono_font
--theme.hotkeys_description_font = theme.sans_font

-- Don't use sans font:
--theme.sans_font	= "theme.font"

--
--MISC:
--

--theme.border_width = dpi(3)
--theme.useless_gap = dpi(6)

--theme.border_width = dpi(4)
--theme.useless_gap = dpi(5)

--theme.border_width = dpi(5)
--theme.useless_gap = dpi(4)

--theme.border_width = dpi(4)
theme.useless_gap = dpi(4)

theme.border_width = dpi(gtk_border_width) * 4

theme.base_border_width = theme.border_width
theme.border_width = 0

theme.titlebar_height = theme.basic_panel_height + theme.base_border_width*2


theme.left_panel_internal_corner_radius = dpi(30)

theme.left_panel_width = dpi(120)
theme.left_widget_min_height = dpi(120)

theme.menu_height		= dpi(16)
theme.menu_height		= dpi(20)
theme.menu_height		= dpi(22)
theme.menu_width		= dpi(150)
theme.menu_border_color = theme.xrdb.color1
--theme.menu_border_color = gsc.header_button_border_color
theme.menu_border_width		= dpi(gsc.button_border_width)
theme.menu_bg_normal = gsc.menubar_bg_color
theme.menu_fg_normal = gsc.menubar_fg_color


theme.apw_fg_color = MAIN_COLOR
theme.apw_fg_color = gsc.selected_bg_color
--theme.apw_bg_color = color_utils.darker(gsc.menubar_bg_color, 40)
theme.apw_bg_color = gsc.base_color
theme.apw_mute_bg_color = "theme.xrdb.color1"
theme.apw_mute_fg_color = "theme.xrdb.color9"


--theme.taglist_squares_sel       = "theme.null"
--theme.taglist_squares_unsel     = "theme.null"
theme.taglist_fg_focus		= gsc.selected_fg_color
theme.taglist_bg_focus		= gsc.selected_bg_color
--theme.taglist_bg_focus		= {
        --type  = "linear" ,
        --from  = { 0, 0, },
        --to    = { 0, theme.panel_height, },
        --stops = {
            --{ 0, gsc.selected_bg_color },
            --{ 0.49, color_utils.darker(gsc.selected_bg_color, -20)..88 },
            --{ 1, gsc.selected_bg_color },
        --}
    --}
theme.taglist_fg_occupied	= gsc.text_color
theme.taglist_bg_occupied	= gsc.base_color

theme.taglist_fg_occupied = gsc.header_button_fg_color
theme.taglist_bg_occupied = gsc.header_button_bg_color


--theme.border_normal = gsc.menubar_bg_color
theme.border_normal = gsc.wm_border_unfocused_color
theme.border_focus = gsc.wm_border_focused_color
theme.titlebar_fg_normal	= color_utils.mix(gsc.menubar_fg_color, gsc.menubar_bg_color)
theme.titlebar_bg_normal	= gsc.menubar_bg_color
theme.notification_border_radius = "theme.border_radius"
theme.notification_sidebar_bg = color_utils.transparentize(gsc.menubar_bg_color, 0.66)

  local rounded_rect_shape = function(cr,w,h)
    gears.shape.rounded_rect(
      cr, w, h, theme.notification_border_radius
    )
  end
  local less_rounded_rect_shape = function(cr,w,h)
    gears.shape.rounded_rect(
      cr, w, h, theme.panel_widget_border_radius
    )
  end

  theme.titlebar_bg_focus		= "theme.titlebar_bg_normal"
  theme.notification_shape = rounded_rect_shape
if theme.border_radius > 0 and not awesome.composite_manager_running then
  theme.titlebar_fg_focus		= gsc.menubar_fg_color
  --theme.titlebar_bg_focus		= "theme.titlebar_bg_normal"
  --theme.notification_shape = rounded_rect_shape
else
  theme.titlebar_fg_focus		= gsc.selected_fg_color
  --theme.titlebar_bg_focus		= gsc.wm_border_focused_color
  ----theme.actionless_titlebar_bg_focus = gsc.wm_border_focused_color
  --theme.notification_shape = nil
end

theme.tasklist_shape_minimized = less_rounded_rect_shape
theme.tasklist_shape_border_width_minimized = theme.panel_widget_border_width
theme.tasklist_shape_border_color_minimized = color_utils.mix(
  theme.tasklist_fg_minimize, theme.tasklist_bg_minimize, 0.7
)

theme.panel_widget_spacing = dpi(8)
theme.tasklist_spacing = gears.math.round(theme.panel_widget_spacing/4)

theme.panel_widget_bg_error = theme.xrdb.color1
theme.panel_widget_fg_error = theme.xrdb.color15

theme.widget_music_bg = color_utils.mix(theme.border_focus, theme.panel_fg, 0.8)


-------------------------------------------------------------------------------

theme = create_theme({ theme_name=theme_name, theme=theme, })

-------------------------------------------------------------------------------


-- Recolor titlebar icons:
theme = theme_assets.recolor_layout(theme, theme.panel_fg)
theme = theme_assets.recolor_titlebar_normal(theme, theme.titlebar_fg_normal)
theme = theme_assets.recolor_titlebar_focus(theme, theme.titlebar_fg_focus)
for full_name, color in pairs({
  icon_layout_expand=theme.panel_fg,
  icon_layout_master_width_factor=theme.panel_fg,
}) do
  theme[full_name] = recolor_image(surface.duplicate_surface(theme[full_name]), color)
end


if color_utils.is_dark(theme.panel_bg) then
  theme.clock_fg = color_utils.darker(theme.panel_fg, -16)
  --theme.tasklist_fg_focus = color_utils.darker(theme.xrdb.foreground, 12)
else
  theme.clock_fg = color_utils.darker(theme.panel_fg, 16)
end

theme.actionless_titlebar_bg_normal = theme.titlebar_bg_normal
if theme.border_radius > 0 then
  theme.actionless_titlebar_bg_focus  = theme.border_focus
else
  theme.actionless_titlebar_bg_focus  = theme.gtk.wm_border_focused_color
end

if theme.border_radius > dpi(15) then
  theme.border_radius = dpi(15)
end


if awesome.composite_manager_running then
  for _, theme_var in ipairs({
    'border_normal',
    'border_focus',
    'notification_bg',
    'panel_bg',
    'menu_bg_normal',
    'titlebar_bg_normal',
    'titlebar_bg_focus',
  }) do
    --theme[theme_var] = color_utils.transparentize(theme[theme_var], 0.86)
    theme[theme_var] = color_utils.transparentize(theme[theme_var], 0.93)
    --theme[theme_var] = color_utils.transparentize(theme[theme_var], 0.53)
  end
  for _, theme_var in ipairs({
    'actionless_titlebar_bg_normal',
    'actionless_titlebar_bg_focus',
  }) do
    theme[theme_var] = color_utils.transparentize(theme[theme_var], 0.36)
    --theme[theme_var] = color_utils.transparentize(theme[theme_var], 0.57)
  end
  theme['notification_bg'] = color_utils.transparentize(theme['notification_bg'], 0.8)
end

--theme.bg_systray = TRANSPARENT

return theme
