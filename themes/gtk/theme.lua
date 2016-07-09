local awful = require("awful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local create_theme = require("actionless.common_theme").create_theme
local helpers = require("actionless.helpers")
local color_utils = require("utils").color
local parse = require("utils.parse")


local theme_name = "gtk"

local oomox_theme_keys = {}
for _, key in ipairs({
  "BG",
  "FG",
  "MENU_BG",
  "MENU_FG",
  "SEL_BG",
  "SEL_FG",
  "TXT_BG",
  "TXT_FG",
  "BTN_BG",
  "BTN_FG",
  "HDR_BTN_BG",
  "HDR_BTN_FG",

  "ROUNDNESS",
  "GRADIENT",

  "ICONS_LIGHT_FOLDER",
  "ICONS_LIGHT",
  "ICONS_MEDIUM",
  "ICONS_DARK",
}) do
  oomox_theme_keys[key] = key
end

local oomox_theme_name = "retro/uzi"
--local oomox_theme_name = "retro/pale_sun"
--local oomox_theme_name = "retro/twg"
--local oomox_theme_name = "monovedek-gray"
--local oomox_theme_name = "lcars"
--local oomox_theme_name = "numix"
--local oomox_theme_name = "Base-16/Ashes-Light"

local gtk = parse.find_values_in_file(
  os.getenv("HOME").."/projects/oomox/colors/"..oomox_theme_name,
  "(.*)=(.*)",
  oomox_theme_keys,
  function(value)
    return "#"..value
  end
)
gtk.ROUNDNESS = tonumber(gtk.ROUNDNESS:sub(2,#gtk.ROUNDNESS))
gtk.GRADIENT = tonumber(gtk.GRADIENT:sub(2,#gtk.GRADIENT))
gtk.MENU_BG = color_utils.darker(gtk.MENU_BG, -math.ceil(gtk.GRADIENT*100))
log(gtk)


local MAIN_COLOR = gtk.SEL_BG
if oomox_theme_name == 'retro/uzi' then
  MAIN_COLOR = gtk.BTN_BG
end

local theme_dir = awful.util.getdir("config").."/themes/"..theme_name
--local theme = dofile("/usr/share/awesome/themes/xresources/theme.lua")
local theme = {}

theme.fg = gtk.FG
theme.fg_normal = gtk.FG
theme.bg = gtk.BG
theme.bg_normal = gtk.BG

theme.panel_fg = gtk.MENU_FG
theme.panel_bg = gtk.MENU_BG

theme.panel_widget_bg = gtk.TXT_BG
theme.panel_widget_fg = gtk.TXT_FG

--theme.border_radius = dpi(gtk.ROUNDNESS*2)
theme.border_radius = dpi(5)
theme.panel_widget_border_radius = dpi(gtk.ROUNDNESS*0.7)
theme.panel_widget_border_width = dpi(2)
theme.panel_widget_border_color = color_utils.mix(gtk.MENU_FG, gtk.MENU_BG, 0.5)

theme.widget_close_bg = gtk.HDR_BTN_BG
theme.widget_close_fg = gtk.HDR_BTN_FG

theme.tasklist_fg_focus = gtk.MENU_FG
theme.tasklist_fg_normal = gtk.MENU_FG
theme.tasklist_bg_focus = gtk.MENU_BG
theme.tasklist_bg_normal = gtk.MENU_BG

theme.xrdb = xresources.get_current_theme()

theme.dir = theme_dir
theme.icons_dir = theme.dir .. "/icons/"

--theme.error = theme.xrdb.color1
--theme.warning = theme.xrdb.color2


-- TERMINAL COLORSCHEME:
--
theme.color = xresources.get_current_theme()

-- PANEL COLORS:
--
theme.panel_taglist = gtk.TXT_BG
theme.panel_close = MAIN_COLOR
--theme.panel_tasklist = gtk.MENU_BG
theme.panel_media = MAIN_COLOR
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
--theme.font = "Sans Bold 10"
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


theme.apw_fg_color = MAIN_COLOR
theme.apw_fg_color = gtk.SEL_BG
--theme.apw_bg_color = color_utils.darker(gtk.MENU_BG, 40)
theme.apw_bg_color = gtk.TXT_BG
theme.apw_mute_bg_color = "theme.xrdb.color1"
theme.apw_mute_fg_color = "theme.xrdb.color9"


--theme.taglist_squares_sel       = "theme.null"
--theme.taglist_squares_unsel     = "theme.null"
--theme.taglist_fg_focus		= "theme.theme"
theme.taglist_fg_focus		= gtk.SEL_FG
theme.taglist_bg_focus		= gtk.SEL_BG
theme.taglist_fg_occupied	= gtk.TXT_FG
theme.taglist_bg_occupied	= gtk.TXT_BG

theme.taglist_fg_occupied	= gtk.HDR_BTN_FG
theme.taglist_bg_occupied	= gtk.HDR_BTN_BG
log(theme.taglist_fg_occupied)

--theme.titlebar_fg_focus		= "theme.titlebar_border"
--theme.titlebar_bg_focus		= "theme.titlebar_focus_border"
theme.titlebar_fg_normal	= color_utils.mix(gtk.MENU_FG, gtk.MENU_BG)
theme.titlebar_bg_normal	= "theme.titlebar_border"
theme.titlebar_fg_focus		= gtk.MENU_FG
theme.titlebar_bg_focus		= "theme.titlebar_bg_normal"

--theme.border_normal
theme.border_focus = MAIN_COLOR
theme.titlebar_border = gtk.MENU_BG


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

theme.widget_music_bg = color_utils.mix(MAIN_COLOR, gtk.MENU_FG, 0.6)
--theme.widget_music_fg = MAIN_COLOR


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
