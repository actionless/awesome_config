--[[
        Licensed under GNU General Public License v2
        * (c) 2014 Yauheni Kirylau
--]]

local awful = require("awful")
local xresources = require("beautiful").xresources
local dpi = xresources.apply_dpi
local g_string = require("gears.string")
local surface = require("gears.surface")
local recolor_image = require("gears.color").recolor_image

local h_string = require("actionless.util.string")

local h_table = require("actionless.util.table")
local h_parse = require("actionless.util.parse")
local h_color = require("actionless.util.color")


local common_theme = {}

function common_theme.create_default_theme(theme_dir, icons_dir)

  local theme
  pcall(function()
    theme = dofile("/usr/share/awesome/themes/xresources/theme.lua")
  end)
  if not theme then
    local nixos = require("actionless.util.nixos")
    theme = dofile(nixos.get_nix_xresources_theme_path().."/theme.lua")
  end
  theme.dir = theme_dir
  theme.null = nil

  theme.xrdb = xresources.get_current_theme()

  theme.icon_theme = h_parse.find_in_file(
    os.getenv("HOME").."/.xsettingsd", '^Net/IconThemeName.*"(.*)"'
  ) or "gnome"

  theme.wallpaper = nil
  theme.wallpaper_cmd = "nitrogen --restore"

  theme.show_widget_icon = false

  theme.mono_font = "Monospace Bold 10"
  theme.font = theme.mono_font
  theme.mono_text_font = "Monospace 10"
  theme.sans_font = "Sans Bold 10"
  -- Don't use sans font:
  --theme.sans_font	= theme.font

  -- COLORS:

  theme.bg = "theme.xrdb.background"
  theme.alt_bg = "theme.xrdb.color4"

  theme.fg = "theme.xrdb.color7"

  theme.error = "theme.xrdb.color9"
  theme.warning = "theme.xrdb.color10"

  theme.fg_normal		= "theme.fg"
  theme.bg_normal		= "theme.bg"
  theme.fg_focus		= "theme.bg"
  theme.bg_focus		= "theme.xrdb.color13"
  theme.fg_urgent		= "theme.bg"
  theme.bg_urgent		= "theme.error"

  theme.border_normal		= "theme.bg"
  theme.border_focus		= "theme.xrdb.color10"
  theme.border_marked		= "theme.error"

  -- GLOBAL BORDERS:

  theme.base_border_width	= dpi(3)
  ----handled by titlebar (base_border_width) instead:
  --theme.border_width		= "theme.base_border_width"
  theme.border_width = 0
  theme.border_radius = 0
  theme.client_border_radius = "theme.border_radius"

  theme.highlight_border_on_hover = false

  theme.useless_gap	        = dpi(10)
  theme.screen_padding		= 0

  -- PANEL OPTIONS:

  --theme.panel_opacity		= 0.96
  --theme.panel_opacity		= 0.92
  theme.panel_opacity		= 0.87
  theme.basic_panel_height	= dpi(18)
  theme.panel_padding_bottom	= dpi(6)
  theme.panel_height		= theme.basic_panel_height + theme.panel_padding_bottom
  theme.panel_widget_spacing	= dpi(8)
  theme.panel_widget_border_radius = dpi(2)
  theme.panel_widget_width	= dpi(20)

  theme.left_panel_width = dpi(120)
  theme.left_widget_min_height = dpi(120)
  theme.left_panel_internal_corner_radius = dpi(30)
  --theme.widget_notification_position = "top_left"
  theme.widget_notification_position = "top_right"


  -- PANEL COLORS:

  theme.panel_bg		= "theme.bg"
  theme.panel_fg		= "theme.fg"
  theme.panel_widget_bg		= "theme.fg"
  theme.panel_widget_fg		= "theme.bg"
  theme.panel_widget_bg		= "theme.fg"
  theme.panel_widget_bg_warning	= "theme.warning"
  theme.panel_widget_fg_warning	= "theme.panel_bg"
  theme.panel_widget_bg_error 	= "theme.error"
  theme.panel_widget_fg_error 	= "theme.panel_bg"
  theme.panel_widget_bg_disabled = "theme.xrdb.color8"
  theme.panel_widget_fg_disabled = "theme.bg"

  theme.panel_taglist = "theme.fg"
  theme.panel_close = "theme.xrdb.color1"
  theme.panel_media = "theme.xrdb.color14"
  theme.panel_layoutbox = "theme.alt_bg"

  theme.taglist_font		= "theme.font"
  theme.taglist_fg_occupied	= "theme.bg"
  theme.taglist_bg_occupied	= "theme.panel_taglist"
  theme.taglist_fg_empty	= "theme.bg"
  theme.taglist_bg_empty	= "theme.tasklist_bg_minimize"
  theme.taglist_fg_focus	= "theme.panel_taglist"
  theme.taglist_bg_focus	= "theme.bg"

  theme.tasklist_spacing	= "theme.panel_padding_bottom"
  theme.tasklist_font		= "theme.sans_font"
  theme.tasklist_fg_focus	= "theme.alt_bg"
  theme.tasklist_bg_focus	= "theme.bg"
  theme.tasklist_fg_normal	= "theme.fg"
  theme.tasklist_bg_normal	= "theme.bg"
  theme.tasklist_fg_minimize	= "theme.bg"
  theme.tasklist_bg_minimize	= "theme.alt_bg"

  theme.widget_close_bg = "theme.panel_close"
  theme.widget_close_fg = "theme.panel_widget_fg"
  theme.widget_music_bg = "theme.panel_media"
  theme.widget_music_fg = "theme.panel_widget_fg"
  theme.widget_layoutbox_bg = "theme.panel_layoutbox"
  theme.widget_layoutbox_fg = "theme.panel_widget_fg"

  theme.apw_bg_color = "theme.panel_bg"
  theme.apw_fg_color = "theme.panel_media"


  theme.titlebar_height		= dpi(14)
  --theme.titlebar_opacity	= 0.7
  theme.titlebar_opacity	= 0.6
  theme.titlebar_position	= 'top'
  theme.titlebar_font		= "theme.font"
  theme.titlebar_fg_focus	= "theme.tasklist_fg_focus"
  theme.titlebar_bg_focus	= "theme.bg"
  theme.titlebar_fg_normal	= "theme.tasklist_fg_normal"
  --theme.titlebar_bg_normal	= "theme.bg"
  theme.titlebar_bg_normal      = "theme.border_normal"
  theme.actionless_titlebar_bg_focus	= "theme.titlebar_bg_focus"
  theme.actionless_titlebar_bg_normal      = "theme.titlebar_bg_normal"

  --theme.notification_opacity	= 0.8
  theme.notification_opacity	= 1.0
  theme.notification_font	= "theme.sans_font"
  theme.notification_bg = "theme.bg_normal"
  theme.notification_fg = "theme.fg_normal"
  theme.notification_border_color = "theme.bg_focus"
  theme.notification_border_color = "theme.xrdb.color8"
  theme.notification_border_width = dpi(2)
  theme.notification_margin = dpi(8)
  theme.notification_icon_size = dpi(200)
  --theme.notification_max_width = math.ceil(screen[1].geometry.width / 3)
  theme.notification_max_width = math.ceil(screen[1].geometry.width / 2)
  --theme.notification_spacing = dpi(8)
  theme.notification_spacing = dpi(4)
  --
  theme.notification_sidebar_width = math.ceil(screen[1].geometry.width / 4)
  theme.notification_border_radius = dpi(2)

  theme.mouse_finder_color	= "theme.error"
  theme.menu_border_width		= dpi(3)
  theme.menu_height		= dpi(18)
  theme.menu_width		= dpi(140)
  theme.menu_submenu_icon = nil
  theme.menu_submenu = "▸ "

  theme.hotkeys_shape = "theme.notification_shape"
  theme.hotkeys_modifiers_fg	= "theme.panel_widget_bg_disabled"
  -- @TODO: check is_dark_bg ?
  theme.hotkeys_label_bg	= "theme.xrdb.foreground"
  theme.hotkeys_label_fg	= "theme.xrdb.background"
  theme.hotkeys_border_color = "theme.hotkeys_modifiers_fg"
  theme.hotkeys_border_width = dpi(2)



  -- ICONS

  icons_dir = icons_dir or (theme.dir .. "/icons/")
  theme.icons_dir = icons_dir

  --theme.icon_systray_show 		= icons_dir .. "systray_show.png"
  --theme.icon_systray_hide 		= icons_dir .. "systray_hide.png"
  theme.icon_systray_show	= nil
  theme.icon_systray_hide	= nil

  theme.icon_layout_expand = icons_dir .. "expand.svg"
  theme.icon_layout_master_width_factor = icons_dir .. "master_width_factor.svg"

  --theme.taglist_squares_sel	= icons_dir .. "square_sel.png"
  --theme.taglist_squares_unsel	= icons_dir .. "square_unsel.png"
  theme.taglist_squares_sel	= nil
  theme.taglist_squares_unsel	= nil
  --theme.taglist_squares_sel_empty	= nil
  --theme.taglist_squares_unsel_empty	= nil

  theme.widget_ac		= icons_dir .. "ac.png"
  theme.widget_ac_charging	= icons_dir .. "ac_charging.png"
  theme.widget_ac_charging_low	= icons_dir .. "ac_charging_low.png"

  theme.widget_battery		= icons_dir .. "battery.png"
  theme.widget_battery_low	= icons_dir .. "battery_low.png"
  theme.widget_battery_empty	= icons_dir .. "battery_empty.png"

  theme.widget_hdd		= icons_dir .. "hdd.png"
  theme.widget_updates		= icons_dir .. "updates.png"

  theme.widget_mem		= icons_dir .. "mem.png"
  theme.widget_mem_high		= icons_dir .. "mem_high.png"
  theme.widget_mem_critical	= icons_dir .. "mem_critical.png"

  theme.widget_cpu		= icons_dir .. "cpu.png"
  theme.widget_cpu_high		= icons_dir .. "cpu_high.png"
  theme.widget_cpu_critical	= icons_dir .. "cpu_critical.png"

  theme.widget_temp		= icons_dir .. "temp.png"
  theme.widget_temp_high	= icons_dir .. "temp_high.png"

  theme.widget_net_wifi	        = icons_dir .. "net_wireless.png"
  theme.widget_net_wired	= icons_dir .. "net_wired.png"
  theme.widget_net_searching	= icons_dir .. "net_searching.png"

  theme.widget_music_pause      = icons_dir .. "music_pause.png"
  theme.widget_music_play	= icons_dir .. "music_play.png"
  theme.widget_music_stop	= icons_dir .. "music_stop.png"
  theme.widget_music_off        = icons_dir .. "music_off.png"

  theme.widget_disk		= icons_dir .. "disk.png"
  theme.widget_disk_high	= icons_dir .. "disk_high.png"

  theme.widget_notifications	= icons_dir .. "notifications.png"

  theme.recolor_widget_icons = true

  theme.tasklist_disable_icon = true
  --theme.tasklist_floating = "*"
  --theme.tasklist_maximized_horizontal = "_"
  --theme.tasklist_maximized_vertical = "|"

  theme.layout_uselesstile		= theme.layout_tile
  theme.layout_uselesstiletop		= theme.layout_tiletop
  theme.layout_lcars		        = theme.layout_tiletop -- @TODO: add icon
  theme.layout_uselessfair		= theme.layout_fairv
  theme.layout_uselessfairh		= theme.layout_fairh
  theme.layout_uselesspiral		= theme.layout_spiral

return theme
end


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

function common_theme.recolor_widget_icons(theme, color)
  for full_name, value in pairs(theme) do
    if (
        type(value)=="string" and
        g_string.startswith(value, theme.icons_dir) and
        (value ~= theme.icons_dir)
    ) then
      local image = surface.duplicate_surface(theme[full_name])
      theme[full_name] = recolor_image(image, color)
    end
  end
  return theme
end

-------------------------------------------------------------------------------

function common_theme.fill_theme(theme, recursion_counter)
  local new_theme = {}
  local templates_found = false
  recursion_counter = recursion_counter or 0
  for key, value in pairs(theme) do
    if type(value)=="string" and g_string.startswith(value, "theme.") then
      --local actual_key_path = g_string.split(value, ".")
      local actual_key_path = h_string.split(value, ".")
      local actual_value = theme
      for i=2,#actual_key_path do
        actual_value = actual_value[actual_key_path[i]]
      end
      new_theme[key] = actual_value
      if actual_value and type(actual_value)=="string" and g_string.startswith(actual_value, "theme.") then
        templates_found = true
      end
    else
      new_theme[key] = value
    end
  end
  if templates_found and recursion_counter < 100 then
    recursion_counter = recursion_counter + 1
    new_theme = common_theme.fill_theme(new_theme, recursion_counter)
  elseif recursion_counter > 10 then
    print("common_theme: recursion counter is " + tostring(recursion_counter))
  end

  if new_theme.show_widget_icon and new_theme.recolor_widget_icons then
    local color = new_theme.panel_widget_fg
    new_theme = common_theme.recolor_widget_icons(new_theme, color)
  end
  return new_theme
end

-------------------------------------------------------------------------------
--
function common_theme.create_theme(args)
  args = args or {}
  local theme_name = args.theme_name
  local theme = args.theme or {}
  local theme_dir = args.theme_dir or theme.dir
  local icons_dir = args.icons_dir or theme.icons_dir

  if not theme then
    error("theme is not provided")
  end

  if not theme_dir then
    if theme_name then
      theme_dir = awful.util.getdir("config").."/themes/"..theme_name
    else
      error("theme_name or theme_dir are not provided")
    end
  end

  theme = common_theme.fill_theme(
    h_table.merge(
      common_theme.create_default_theme(theme_dir, icons_dir),
      theme
    )
  )
  theme.fg_urgent = h_color.choose_contrast_color(
    theme.bg_urgent, theme.fg, theme.bg
  )
  return theme
end

return common_theme
