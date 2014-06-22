theme = {}

themes_dir = os.getenv("HOME") .. "/.config/awesome/themes/lcars_modern"
theme.dir = themes_dir
--theme.wallpaper_cmd     = "hsetroot"
theme.wallpaper_cmd     = "nitrogen --restore"
theme.show_widget_icon = false
theme.show_widget_decorations = true
theme.widget_use_text_decorations = false
--theme.widget_use_text_decorations = true
--theme.font		= "Meslo LG S for Powerline Bold 10.5"
--theme.widget_decoration_arrl = ''
--theme.widget_decoration_arrr = ''

theme.bg		= "#000000"

theme.fg		= "#ffcc99"
theme.alt_fg		= "#ffcc66"
theme.shiny		= "#000000"

theme.theme		= "#cc99cc"
theme.warning           = "#ff9900"
theme.error		= "#ff3300"

theme.border		= "#000000"
theme.sel_border	= "#ff9900"
theme.titlebar		= "#000000"
theme.titlebar_focus	= "#000000"
theme.titlebar_focus_border = theme.sel_border

theme.color1 = '#ff9966'
theme.color2 = '#cc99cc'
theme.color3 = '#cc6666'
theme.color4 = '#99ccff'
theme.color5 = '#9999ff'
theme.color6 = '#6666ff'
theme.color7 = '#cc9966'
theme.color8 = '#6699cc'
theme.color9 = '#9966ff'
theme.color10 = '#666699'

theme.colorf = theme.fg
theme.colorerr = theme.error
theme.colorwarn = theme.warning


theme.alt_bg		= theme.color9
theme.theme2            = theme.color1

--theme.font		= "Dina 9"
--theme.font		= "Terminus Bold 9.8"
--theme.font		= "Fixed Bold 10.5"
theme.font		= "Meslo LG S Bold 10.5"
--theme.font		= "Source Code Pro Bold 10.5"
--theme.font		= "DejaVu Sans Mono Bold 9"
--theme.font		= "LCARS 11"
--theme.font		= "LCARS 17"
--theme.font		= "Fira Mono 8"
theme.sans_font		= "Fira Sans Medium 10.5"
theme.sans_font		= theme.font

theme.fg_normal			= theme.fg
theme.bg_normal			= theme.bg
theme.fg_focus			= theme.shiny
theme.bg_focus			= theme.theme
theme.fg_urgent			= theme.bg
theme.bg_urgent			= theme.error

theme.screen_margin		= 0

theme.border_width		= "10"
theme.border_normal		= theme.border
theme.border_focus		= theme.sel_border
theme.border_marked		= theme.error

theme.panel_bg                  = theme.bg
theme.panel_fg                  = theme.fg
theme.panel_opacity		= 0.96
--theme.panel_height              = 23
theme.panel_height              = 18
theme.panel_margin              = 3
theme.panel_enbolden_details = false

theme.taglist_font		= theme.font
theme.taglist_fg_occupied	= theme.bg
theme.taglist_bg_occupied	= theme.theme2
theme.taglist_fg_empty		= theme.bg
theme.taglist_bg_empty		= theme.theme
theme.taglist_fg_focus		= theme.theme2
theme.taglist_bg_focus		= theme.bg

theme.tasklist_font		= theme.sans_font
theme.tasklist_fg_focus		= theme.alt_bg
theme.tasklist_bg_focus		= theme.bg
theme.tasklist_fg_normal	= theme.fg
theme.tasklist_bg_normal	= theme.bg
theme.tasklist_fg_minimize	= theme.bg
theme.tasklist_bg_minimize	= theme.alt_bg

theme.titlebar_font		= theme.font
theme.titlebar_fg_focus		= theme.tasklist_fg_focus
theme.titlebar_fg_normal	= theme.tasklist_fg_normal
theme.titlebar_bg_focus		= theme.titlebar_focus
theme.titlebar_bg_normal	= theme.titlebar

theme.titlebar_opacity          = 0.7
theme.titlebar_position         = 'top'

theme.notification_opacity	= 0.8
theme.notification_font		= theme.sans_font
theme.notification_monofont	= theme.font
theme.notify_fg			= theme.fg_normal
theme.notify_bg			= theme.bg_normal
theme.notify_border		= theme.border_focus

theme.textbox_widget_margin_top	= 1
theme.awful_widget_height	= 14
theme.awful_widget_margin_top	= 2
theme.mouse_finder_color	= theme.error
theme.menu_border_width		= "3"
theme.menu_height		= "16"
theme.menu_width		= "140"

theme.player_text		= theme.color2



-- ICONS

icons_dir = theme.dir .. "/icons/"
theme.icons_dir = icons_dir

theme.menu_submenu_icon		= icons_dir .. "submenu.png"

theme.taglist_squares_sel	= icons_dir .. "square_sel.png"
theme.taglist_squares_unsel	= icons_dir .. "square_unsel.png"

theme.small_separator		= icons_dir .. "small_separator.png"
theme.arrl			= icons_dir .. "arrl.png"
theme.arrr			= icons_dir .. "arrr.png"
theme.arrlerr			= icons_dir .. "arrl_err.png"
theme.arrrerr			= icons_dir .. "arrr_err.png"
theme.arrlwarn			= icons_dir .. "arrl_warn.png"
theme.arrrwarn			= icons_dir .. "arrr_warn.png"
theme.arrl1			= icons_dir .. "arrl1.png"
theme.arrr1			= icons_dir .. "arrr1.png"
theme.arrl2			= icons_dir .. "arrl2.png"
theme.arrr2			= icons_dir .. "arrr2.png"
theme.arrl3			= icons_dir .. "arrl3.png"
theme.arrr3			= icons_dir .. "arrr3.png"
theme.arrl4			= icons_dir .. "arrl4.png"
theme.arrr4			= icons_dir .. "arrr4.png"
theme.arrl5			= icons_dir .. "arrl5.png"
theme.arrr5			= icons_dir .. "arrr5.png"
theme.arrl6			= icons_dir .. "arrl6.png"
theme.arrr6			= icons_dir .. "arrr6.png"

theme.arrl9			= icons_dir .. "arrl9.png"
theme.arrr9			= icons_dir .. "arrr9.png"

theme.widget_ac			= icons_dir .. "ac.png"
theme.widget_ac_charging	= icons_dir .. "ac_charging.png"
theme.widget_ac_charging_low	= icons_dir .. "ac_charging_low.png"

theme.widget_battery		= icons_dir .. "battery.png"
theme.widget_battery_low	= icons_dir .. "battery_low.png"
theme.widget_battery_empty	= icons_dir .. "battery_empty.png"

theme.widget_mem		= icons_dir .. "mem.png"
theme.widget_cpu		= icons_dir .. "cpu.png"
theme.widget_temp		= icons_dir .. "temp.png"
theme.widget_net		= icons_dir .. "net.png"
theme.widget_hdd		= icons_dir .. "hdd.png"

theme.widget_net_wireless	= icons_dir .. "net_wireless.png"
theme.widget_net_wired		= icons_dir .. "net_wired.png"
theme.widget_net_searching	= icons_dir .. "net_searching.png"

theme.widget_music		= icons_dir .. "note.png"
theme.widget_music_on		= icons_dir .. "note_on.png"
theme.widget_music_off		= icons_dir .. "note_off.png"
theme.widget_vol_high		= icons_dir .. "vol_high.png"
theme.widget_vol		= icons_dir .. "vol.png"
theme.widget_vol_low		= icons_dir .. "vol_low.png"
theme.widget_vol_no		= icons_dir .. "vol_no.png"
theme.widget_vol_mute		= icons_dir .. "vol_mute.png"
theme.widget_mail		= icons_dir .. "mail.png"
theme.widget_mail_on		= icons_dir .. "mail_on.png"

theme.dropdown_icon		= icons_dir .. "dropdown.png"

theme.tasklist_disable_icon = true
--theme.tasklist_floating = "*"
--theme.tasklist_maximized_horizontal = "_"
--theme.tasklist_maximized_vertical = "|"

layout_icons_dir = icons_dir .. "layout/"
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

titlebar_icons_dir = icons_dir .. "titlebar/"
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
