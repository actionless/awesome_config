theme		= {}

themes_dir		= os.getenv("HOME") .. "/.config/awesome/themes/actionless"
theme.dir		= themes_dir
theme.wallpaper= themes_dir .. "/vulcarona_pattern.png"

theme.bg		= "#d8d8d8"
theme.alt_bg	= "#a8a8a8"

theme.fg		= "#101010"
theme.alt_fg	= "#a562b3"
theme.shiny		= "#ffffff"

theme.theme		= "#ad7fa8"
theme.error		= "#f92672"

theme.border					= "#000000"
theme.sel_border				= "#d33862"
theme.titlebar					= "#3c3c3c"
theme.titlebar_focus			= "#66436C"

--theme.font					= "PT Mono 8"
--theme.font					= "DejaVu Sans Mono 9"
--theme.font					= "tewi 9"
--theme.font					= "Dina 8"
--theme.font					= "Meslo LG S 10"
--theme.font					= "Share Tech Mono 11"
theme.font					= "monoOne 10"
--theme.font					= "Fira Mono 9"
--theme.font						= "Source Code Pro Medium 9.4"
--theme.sans_font				= "Share Tech 11"
theme.sans_font					= "Source Sans Pro Regular 11.06"
theme.fg_normal					= theme.fg
theme.bg_normal					= theme.bg
theme.fg_focus					= theme.fg
theme.bg_focus					= theme.theme
theme.fg_urgent					= theme.bg
theme.bg_urgent					= theme.error

theme.screen_margin				= 0

theme.border_width				= "3"
theme.border_normal				= theme.border
theme.border_focus				= theme.sel_border
theme.border_marked				= theme.error

theme.panel_opacity				= 1.0

theme.taglist_font				= theme.font
theme.taglist_fg_focus			= theme.shiny
theme.taglist_bg_focus			= theme.theme

theme.tasklist_font				= theme.sans_font
theme.tasklist_fg_focus			= theme.fg
theme.tasklist_bg_focus			= theme.bg
theme.tasklist_fg_normal		= theme.fg
theme.tasklist_bg_normal		= theme.bg
theme.tasklist_fg_minimize		= theme.bg
theme.tasklist_bg_minimize		= "#6c6c6c"

--theme.titlebar_font				= theme.sans_font
--theme.titlebar_font			= "PT Caption Bold 9"
theme.titlebar_font				= "Source Sans Pro Bold 10.5"
theme.titlebar_fg_focus			= theme.shiny
theme.titlebar_fg_normal		= theme.fg
theme.titlebar_bg_focus			= theme.titlebar_focus
theme.titlebar_bg_normal		= theme.titlebar

theme.notification_opacity		= 0.9
theme.notification_font			= theme.sans_font
theme.notification_monofont		= theme.font
theme.notify_fg					= theme.fg_normal
theme.notify_bg					= theme.bg_normal
theme.notify_border				= theme.border_focus

theme.textbox_widget_margin_top	= 1
theme.awful_widget_height		= 14
theme.awful_widget_margin_top	= 2
theme.mouse_finder_color		= theme.error
theme.menu_height				= "16"
theme.menu_width				= "140"

theme.player_text				= "#8d5f88"

-- ICONS

icons_dir = theme.dir .. "/icons/"
theme.icons_dir = icons_dir

theme.taglist_squares_sel		= icons_dir .. "square_sel.png"
theme.taglist_squares_unsel		= icons_dir .. "square_unsel.png"

theme.menu_submenu_icon			= icons_dir .. "submenu.png"
theme.taglist_squares_sel		= icons_dir .. "square_sel.png"
theme.taglist_squares_unsel		= icons_dir .. "square_unsel.png"

theme.layout_tile				= icons_dir .. "tile.png"
theme.layout_tilegaps			= icons_dir .. "tilegaps.png"
theme.layout_tileleft			= icons_dir .. "tileleft.png"
theme.layout_tilebottom			= icons_dir .. "tilebottom.png"
theme.layout_tiletop			= icons_dir .. "tiletop.png"
theme.layout_fairv				= icons_dir .. "fairv.png"
theme.layout_fairh				= icons_dir .. "fairh.png"
theme.layout_spiral				= icons_dir .. "spiral.png"
theme.layout_dwindle			= icons_dir .. "dwindle.png"
theme.layout_max				= icons_dir .. "max.png"
theme.layout_fullscreen			= icons_dir .. "fullscreen.png"
theme.layout_magnifier			= icons_dir .. "magnifier.png"
theme.layout_floating			= icons_dir .. "floating.png"

theme.arrl						= icons_dir .. "arrl.png"
theme.arrl_dl					= icons_dir .. "arrl_dl.png"
theme.arrl_ld					= icons_dir .. "arrl_ld.png"

theme.widget_ac = icons_dir .. "ac.png"
theme.widget_ac_charging = icons_dir .. "ac_charging.png"
theme.widget_ac_charging_low = icons_dir .. "ac_charging_low.png"

theme.widget_battery			= icons_dir .. "battery.png"
theme.widget_battery_low		= icons_dir .. "battery_low.png"
theme.widget_battery_empty		= icons_dir .. "battery_empty.png"

theme.widget_mem				= icons_dir .. "mem.png"
theme.widget_cpu				= icons_dir .. "cpu.png"
theme.widget_temp				= icons_dir .. "temp.png"
theme.widget_net				= icons_dir .. "net.png"
theme.widget_hdd				= icons_dir .. "hdd.png"

theme.widget_net_wireless			= icons_dir .. "net_wireless.png"
theme.widget_net_wired				= icons_dir .. "net_wired.png"
theme.widget_net_searching				= icons_dir .. "net_searching.png"

theme.widget_music				= icons_dir .. "note.png"
theme.widget_music_on			= icons_dir .. "note_on.png"
theme.widget_vol_high			= icons_dir .. "vol_high.png"
theme.widget_vol				= icons_dir .. "vol.png"
theme.widget_vol_low			= icons_dir .. "vol_low.png"
theme.widget_vol_no				= icons_dir .. "vol_no.png"
theme.widget_vol_mute			= icons_dir .. "vol_mute.png"
theme.widget_mail				= icons_dir .. "mail.png"
theme.widget_mail_on			= icons_dir .. "mail_on.png"

theme.dropdown_icon				= icons_dir .. "dropdown.png"

theme.tasklist_disable_icon = true
--theme.tasklist_floating = "*"
--theme.tasklist_maximized_horizontal = "_"
--theme.tasklist_maximized_vertical = "|"

theme.titlebar_close_button_focus = icons_dir .. "titlebar/close_focus.png"
theme.titlebar_close_button_normal = icons_dir .. "titlebar/close_normal.png"

theme.titlebar_ontop_button_focus_active = icons_dir .. "titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active = icons_dir .. "titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive = icons_dir .. "titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive = icons_dir .. "titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active = icons_dir .. "titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active = icons_dir .. "titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive = icons_dir .. "titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive  = icons_dir .. "titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active = icons_dir .. "titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active = icons_dir .. "titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive = icons_dir .. "titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive = icons_dir .. "titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active = icons_dir .. "titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active = icons_dir .. "titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive = icons_dir .. "titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = icons_dir .. "titlebar/maximized_normal_inactive.png"

theme.titlebar_minimize_button_focus_active = icons_dir .. "titlebar/minimized_focus.png"
theme.titlebar_minimize_button_normal_active = icons_dir .. "titlebar/minimized_normal.png"
theme.titlebar_minimize_button_focus_inactive = icons_dir .. "titlebar/minimized_focus.png"
theme.titlebar_minimize_button_normal_inactive = icons_dir .. "titlebar/minimized_normal.png"

return theme
