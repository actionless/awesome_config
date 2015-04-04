--[[
	Licensed under GNU General Public License v2
	* (c) 2014 Yauheni Kirylau
--]]

local awful = require("awful")

local h_string = require("utils.string")
local h_table = require("utils.table")


local common_theme = {}

function common_theme.generate_theme(theme_dir)

  local theme = {}

  theme.null = nil
  -- TERMINAL COLORSCHEME:
  --
  theme.color = {
    --black
    ["0"] = '#000000',
    ["8"] = '#465457',
    --red
    ["1"] = '#960050',
    ["9"] = '#F92672',
    --green
    ["2"] = '#008877',
    ["10"] = '#A6E22E',
    --yellow
    ["3"] = '#FD971F',
    ["11"] = '#e6db74',
    --blue
    ["4"] = '#7711dd',
    ["12"] = '#8432ff',
    --purple
    ["5"] = '#890089',
    ["13"] = '#85509b',
    --cyan
    ["6"] = '#00d6b5',
    ["14"] = '#51edbc',
    --white
    ["7"] = '#888a85',
    ["15"] = '#ffffff',
    --
    c  = '#ae81ff',
    bg  = '#0e0021',
    fg  = '#bcbcbc',
  }

  theme.color.b = theme.color.bg
  theme.color.f = theme.color.fg
  theme.dir = theme_dir

  theme.hidpi = false

  -- Use plain color:
  theme.wallpaper_cmd     = "hsetroot"
  -- Use nitrogen:
  --theme.wallpaper_cmd     = "nitrogen --restore"
  -- Use wallpaper tile:
  --theme.wallpaper = theme.dir .. '/pattern.png'

  theme.iconfont = "FontAwesome 10"
  theme.use_iconfont = false
  theme.show_widget_icon = false
  theme.widget_decoration_arrl = ''
  theme.widget_decoration_arrr = ''

  --Source*Pro:
  --theme.font = "Source Code Pro Bold 10.5"
  --theme.sans_font = "Source Sans Pro Bold 10.3"
  --Meslo+Paratype:
  --theme.font = "Meslo LG S for Lcarsline Bold 10.5"
  --theme.sans_font = "PT Sans Bold 10.3"
  -- use ~/.fonts.conf, Luke ;)
  theme.font = "Monospace Bold 10.5"
  theme.sans_font = "Sans Bold 10.3"
  -- Don't use sans font:
  --theme.sans_font	= theme.font

  -- COLORS:

  theme.error = "theme.color.9"
  theme.warning = "theme.color.10"
  theme.theme = "theme.color.13"

  theme.bg = "theme.color.bg"
  theme.alt_bg = "theme.color.4"

  theme.fg = "theme.color.7"
  theme.alt_fg = "theme.color.fg"


  theme.border                  = "theme.bg"
  theme.sel_border              = "theme.color.10"
  theme.titlebar_border         = "theme.border"
  theme.titlebar_focus_border   = "theme.sel_border"
  theme.border_width		= "6"
  theme.border_normal		= "theme.border"
  theme.border_focus		= "theme.sel_border"
  theme.border_marked		= "theme.error"

  theme.useless_gap_width = 20
  theme.useless_gap_width = 40

  theme.fg_normal		= "theme.fg"
  theme.bg_normal		= "theme.bg"
  theme.fg_focus		= "theme.bg"
  theme.bg_focus		= "theme.theme"
  theme.fg_urgent		= "theme.bg"
  theme.bg_urgent		= "theme.error"

  theme.screen_padding		= 0

  theme.panel_bg		= "theme.bg"
  theme.panel_fg		= "theme.fg"
  theme.panel_widget_bg		= "theme.fg"
  theme.panel_widget_fg		= "theme.bg"
  theme.panel_widget_bg_warning	= "theme.warning"
  theme.panel_widget_fg_warning	= "theme.bg"
  theme.panel_widget_bg_error 	= "theme.error"
  theme.panel_widget_fg_error 	= "theme.bg"
  --theme.panel_opacity		= 0.96
  theme.panel_opacity		= 0.92
  theme.panel_height		= 24
  theme.panel_padding_bottom	= 6
  theme.panel_enbolden_details	= false

  -- PANEL COLORS:
  --
  theme.panel_taglist = "theme.color.7"
  theme.panel_close = "theme.color.1"
  theme.panel_tasklist = "theme.color.bg"
  theme.panel_media = "theme.color.14"
  theme.panel_info = "theme.color.13"
  theme.panel_layoutbox = "theme.alt_bg"

  theme.widget_taglist_bg = "theme.panel_taglist"
  theme.widget_taglist_fg = "theme.panel_widget_fg"

  theme.taglist_font		= "theme.font"
  theme.taglist_fg_occupied	= "theme.bg"
  theme.taglist_bg_occupied	= "theme.panel_taglist"
  theme.taglist_fg_empty	= "theme.bg"
  theme.taglist_bg_empty	= "theme.theme"
  theme.taglist_fg_focus	= "theme.panel_taglist"
  theme.taglist_bg_focus	= "theme.bg"

  theme.widget_close_bg = "theme.panel_close"
  theme.widget_close_fg = "theme.panel_widget_fg"
  theme.widget_close_left_decorators = { 'arrl' }
  theme.widget_close_right_decorators = { 'sq' }

  theme.tasklist_font		= "theme.sans_font"
  theme.tasklist_fg_focus	= "theme.alt_bg"
  theme.tasklist_bg_focus	= "theme.bg"
  theme.tasklist_fg_normal	= "theme.fg"
  theme.tasklist_bg_normal	= "theme.bg"
  theme.tasklist_fg_minimize	= "theme.bg"
  theme.tasklist_bg_minimize	= "theme.alt_bg"

  theme.widget_netctl_bg = "theme.panel_media"
  theme.widget_netctl_fg = "theme.panel_widget_fg"
  theme.widget_music_bg = "theme.panel_media"
  theme.widget_music_fg = "theme.panel_widget_fg"
  theme.widget_alsa_bg = "theme.panel_media"
  theme.widget_alsa_fg = "theme.panel_widget_fg"

  theme.widget_mem_bg  = "theme.panel_info"
  theme.widget_mem_fg  = "theme.panel_widget_fg"
  theme.widget_cpu_bg  = "theme.panel_info"
  theme.widget_cpu_fg  = "theme.panel_widget_fg"
  theme.widget_temp_bg = "theme.panel_info"
  theme.widget_temp_fg = "theme.panel_widget_fg"
  theme.widget_bat_bg  = "theme.panel_info"
  theme.widget_bat_fg  = "theme.panel_widget_fg"

  theme.widget_layoutbox_bg = "theme.panel_layoutbox"
  theme.widget_layoutbox_fg = "theme.panel_widget_fg"


  theme.titlebar_height		= 28
  theme.titlebar_opacity	= 0.7
  theme.titlebar_position	= 'top'
  theme.titlebar_font		= "theme.font"
  theme.titlebar_fg_focus	= "theme.tasklist_fg_focus"
  theme.titlebar_bg_focus	= "theme.bg"
  theme.titlebar_fg_normal	= "theme.tasklist_fg_normal"
  theme.titlebar_bg_normal	= "theme.bg"

  theme.hotkeys_widget_fg = "theme.bg"

  theme.notification_opacity	= 0.8
  theme.notification_font	= "theme.sans_font"
  theme.notification_monofont	= "theme.font"
  theme.notification_bg = "theme.bg_normal"
  theme.notification_fg = "theme.fg_normal"
  theme.notification_border_color = "theme.theme"

  theme.textbox_widget_margin_top	= 1
  theme.awful_widget_height	= 14
  theme.awful_widget_margin_top	= 2
  theme.mouse_finder_color	= "theme.error"
  theme.menu_border_width		= 3
  theme.menu_height		= 16
  theme.menu_width		= 140

  theme.player_artist		= "theme.color.13"
  theme.player_title      = "theme.panel_media"

  theme.apw_bg_color = "theme.panel_bg"
  theme.apw_fg_color = "theme.panel_media"

  -- ICONS

  local icons_dir = theme.dir .. "/icons/"
  theme.icons_dir = icons_dir

  local common_icons_dir = icons_dir .. "common/"

  theme.icon_down 		= common_icons_dir .. "arrow_down.png"
  theme.icon_left 		= common_icons_dir .. "arrow_left.png"
  theme.icon_right 		= common_icons_dir .. "arrow_right.png"

  theme.menu_submenu_icon		= common_icons_dir .. "submenu.png"
  theme.dropdown_icon		= theme.icon_down

  theme.taglist_squares_sel	= common_icons_dir .. "square_sel.png"
  theme.taglist_squares_unsel	= common_icons_dir .. "square_unsel.png"

  theme.taglist_squares_sel_empty	= nil
  theme.taglist_squares_unsel_empty	= nil

  theme.small_separator		= common_icons_dir .. "small_separator.png"


  local widgets_icons_dir = icons_dir .. "widgets/"

  theme.widget_ac			= widgets_icons_dir .. "ac.png"
  theme.widget_ac_charging	= widgets_icons_dir .. "ac_charging.png"
  theme.widget_ac_charging_low	= widgets_icons_dir .. "ac_charging_low.png"

  theme.widget_battery		= widgets_icons_dir .. "battery.png"
  theme.widget_battery_low	= widgets_icons_dir .. "battery_low.png"
  theme.widget_battery_empty	= widgets_icons_dir .. "battery_empty.png"

  theme.widget_mem		= widgets_icons_dir .. "mem.png"
  theme.widget_cpu		= widgets_icons_dir .. "cpu.png"
  theme.widget_temp		= widgets_icons_dir .. "temp.png"
  theme.widget_net		= widgets_icons_dir .. "net.png"
  theme.widget_hdd		= widgets_icons_dir .. "hdd.png"

  theme.widget_net_wifi	        = widgets_icons_dir .. "net_wireless.png"
  theme.widget_net_wired		= widgets_icons_dir .. "net_wired.png"
  theme.widget_net_searching	= widgets_icons_dir .. "net_searching.png"

  theme.widget_music_pause      	= widgets_icons_dir .. "music_pause.png"
  theme.widget_music_play		= widgets_icons_dir .. "music_play.png"
  theme.widget_music_stop		= widgets_icons_dir .. "music_stop.png"
  theme.widget_vol_high		= widgets_icons_dir .. "vol_high.png"
  theme.widget_vol		= widgets_icons_dir .. "vol.png"
  theme.widget_vol_low		= widgets_icons_dir .. "vol_low.png"
  theme.widget_vol_no		= widgets_icons_dir .. "vol_no.png"
  theme.widget_vol_mute		= widgets_icons_dir .. "vol_mute.png"
  theme.widget_mail		= widgets_icons_dir .. "mail.png"
  theme.widget_mail_on		= widgets_icons_dir .. "mail_on.png"

  theme.tasklist_disable_icon = true
  --theme.tasklist_floating = "*"
  --theme.tasklist_maximized_horizontal = "_"
  --theme.tasklist_maximized_vertical = "|"

  local layout_icons_dir = icons_dir .. "layout/"
  theme.layout_icons_dir = layout_icons_dir
  theme.layout_tile		= layout_icons_dir .. "tile.png"
  theme.layout_tilegaps		= layout_icons_dir .. "tilegaps.png"
  theme.layout_tileleft		= layout_icons_dir .. "tileleft.png"
  theme.layout_tilebottom		= layout_icons_dir .. "tilebottom.png"
  theme.layout_tiletop		= layout_icons_dir .. "tiletop.png"
  theme.layout_fairv		= layout_icons_dir .. "fairv.png"
  theme.layout_fairh		= layout_icons_dir .. "fairh.png"
  theme.layout_spiral		= layout_icons_dir .. "spiral.png"
  theme.layout_dwindle		= layout_icons_dir .. "dwindle.png"
  theme.layout_max		= layout_icons_dir .. "max.png"
  theme.layout_fullscreen		= layout_icons_dir .. "fullscreen.png"
  theme.layout_magnifier		= layout_icons_dir .. "magnifier.png"
  theme.layout_floating		= layout_icons_dir .. "floating.png"

  theme.layout_uselesstile		= theme.layout_tile
  theme.lain_icons         = os.getenv("HOME") .. "/.config/awesome/third_party/lain/icons/layout/default/"
  theme.layout_termfair    = theme.lain_icons .. "termfair.png"
  theme.layout_cascade     = theme.lain_icons .. "cascade.png"
  theme.layout_cascadetile = theme.lain_icons .. "cascadetile.png"
  theme.layout_centerwork  = theme.lain_icons .. "centerwork.png"


  local titlebar_icons_dir = icons_dir .. "titlebar/"
  theme.titlebar_icons_dir = titlebar_icons_dir
  theme.titlebar_close_button_focus = titlebar_icons_dir .. "/close_focus.png"
  theme.titlebar_close_button_normal = titlebar_icons_dir .. "/close_normal.png"

  theme.titlebar_ontop_button_focus_active = titlebar_icons_dir .. "/ontop_focus_active.png"
  theme.titlebar_ontop_button_normal_active = titlebar_icons_dir .. "/ontop_normal_active.png"
  theme.titlebar_ontop_button_focus_inactive = titlebar_icons_dir .. "/ontop_focus_inactive.png"
  theme.titlebar_ontop_button_normal_inactive = titlebar_icons_dir .. "/ontop_normal_inactive.png"

  theme.titlebar_sticky_button_focus_active = titlebar_icons_dir .. "/sticky_focus_active.png"
  theme.titlebar_sticky_button_normal_active = titlebar_icons_dir .. "/sticky_normal_active.png"
  theme.titlebar_sticky_button_focus_inactive = titlebar_icons_dir .. "/sticky_focus_inactive.png"
  theme.titlebar_sticky_button_normal_inactive = titlebar_icons_dir .. "/sticky_normal_inactive.png"

  theme.titlebar_floating_button_focus_active = titlebar_icons_dir .. "/floating_focus_active.png"
  theme.titlebar_floating_button_normal_active = titlebar_icons_dir .. "/floating_normal_active.png"
  theme.titlebar_floating_button_focus_inactive = titlebar_icons_dir .. "/floating_focus_inactive.png"
  theme.titlebar_floating_button_normal_inactive = titlebar_icons_dir .. "/floating_normal_inactive.png"

  theme.titlebar_maximized_button_focus_active = titlebar_icons_dir .. "/maximized_focus_active.png"
  theme.titlebar_maximized_button_normal_active = titlebar_icons_dir .. "/maximized_normal_active.png"
  theme.titlebar_maximized_button_focus_inactive = titlebar_icons_dir .. "/maximized_focus_inactive.png"
  theme.titlebar_maximized_button_normal_inactive = titlebar_icons_dir .. "/maximized_normal_inactive.png"

  theme.titlebar_minimize_button_focus_active = titlebar_icons_dir .. "/minimized_focus.png"
  theme.titlebar_minimize_button_normal_active = titlebar_icons_dir .. "/minimized_normal.png"
  theme.titlebar_minimize_button_focus_inactive = titlebar_icons_dir .. "/minimized_focus.png"
  theme.titlebar_minimize_button_normal_inactive = titlebar_icons_dir .. "/minimized_normal.png"

return theme
end

function common_theme.fill_theme(theme)
  local new_theme = {}
  local templates_found = false
  for key, value in pairs(theme) do
    if type(value)=="string" and h_string.starts(value, "theme.") then
      local actual_key_path = h_string.split(value, ".")
      local actual_value = theme
      for i=2,#actual_key_path do
        actual_value = actual_value[actual_key_path[i]]
      end
      new_theme[key] = actual_value
      if actual_value and h_string.starts(actual_value, "theme.") then
        templates_found = true
      end
    else
      new_theme[key] = value
    end
  end
  if templates_found then
    new_theme = common_theme.fill_theme(new_theme)
  end
  return new_theme
end

function common_theme.create_theme(args)
  args = args or {}
  local theme_dir = args.theme_dir
  local theme_name = args.theme_name
  local theme = args.theme

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

  return common_theme.fill_theme(
    h_table.merge(
      common_theme.generate_theme(theme_dir),
      theme
    )
  )
end

return common_theme
