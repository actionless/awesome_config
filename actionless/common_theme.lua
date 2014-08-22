local common_theme = {}

function common_theme.generate_theme(theme_dir, colors16, panel_colors)

local theme = {}
theme.color = colors16
theme.panel_colors = panel_colors
theme.dir = theme_dir


-- Use plain color:
theme.wallpaper_cmd     = "hsetroot"
-- Use nitrogen:
--theme.wallpaper_cmd     = "nitrogen --restore"
-- Use wallpaper tile:
--theme.wallpaper = theme.dir .. '/pattern.png'

theme.show_widget_icon = false
theme.show_widget_decorations = true
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

theme.error = theme.color[9]
theme.warning = theme.color[10]
theme.color.err = theme.error
theme.color.warn = theme.warning

theme.bg = theme.color.b
theme.alt_bg = theme.color[4]

theme.fg = theme.color[7]
theme.alt_fg = theme.color.f
theme.shiny = theme.color.b

theme.theme = theme.color[13]
theme.theme2 = theme.color[2]

theme.border = theme.bg
theme.sel_border = theme.color[10]
theme.titlebar_border = theme.border
theme.titlebar_focus_border = theme.sel_border

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

theme.panel_bg			= theme.bg
theme.panel_fg			= theme.fg
--theme.panel_opacity		= 0.96
theme.panel_opacity		= 0.92
theme.panel_height		= 24
theme.panel_margin		= 3
theme.panel_enbolden_details	= false

theme.taglist_font		= theme.font
theme.taglist_fg_occupied	= theme.bg
theme.taglist_bg_occupied	= theme.color[theme.panel_colors.taglist]
theme.taglist_fg_empty		= theme.bg
theme.taglist_bg_empty		= theme.theme
theme.taglist_fg_focus		= theme.color[theme.panel_colors.taglist]
theme.taglist_bg_focus		= theme.bg

theme.tasklist_font		= theme.sans_font
theme.tasklist_fg_focus		= theme.alt_bg
theme.tasklist_bg_focus		= theme.bg
theme.tasklist_fg_normal	= theme.fg
theme.tasklist_bg_normal	= theme.bg
theme.tasklist_fg_minimize	= theme.bg
theme.tasklist_bg_minimize	= theme.alt_bg

theme.titlebar_opacity		= 0.7
theme.titlebar_position		= 'top'
theme.titlebar_font		= theme.font
theme.titlebar_fg_focus		= theme.tasklist_fg_focus
theme.titlebar_bg_focus		= theme.bg
theme.titlebar_fg_normal	= theme.tasklist_fg_normal
theme.titlebar_bg_normal	= theme.bg

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

theme.player_text		= theme.color[13]

-- ICONS

local icons_dir = theme.dir .. "/icons/"
theme.icons_dir = icons_dir


theme.menu_submenu_icon		= icons_dir .. "submenu.png"

theme.taglist_squares_sel	= icons_dir .. "square_sel.png"
theme.taglist_squares_unsel	= icons_dir .. "square_unsel.png"

theme.small_separator		= icons_dir .. "small_separator.png"

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


function common_theme.generate_default_theme(theme_dir)
-- TERMINAL COLORSCHEME:
--
color = {}
--black
color[0] = '#000000'
color[8] = '#465457'
--red
color[1] = '#960050'
color[9] = '#F92672'
--green
color[2] = '#008877'
color[10] = '#A6E22E'
--yellow
color[3] = '#FD971F'
color[11] = '#e6db74'
--blue
color[4] = '#7711dd'
color[12] = '#8432ff'
--purple
color[5] = '#890089'
color[13] = '#85509b'
--cyan
color[6] = '#00d6b5'
color[14] = '#51edbc'
--white
color[7] = '#888a85'
color[15] = '#ffffff'

color.b  = '#0e0021'
color.f  = '#bcbcbc'
color.c  = '#ae81ff'

-- PANEL COLORS:
--
panel_colors = {
  taglist=7,
  close=1,
  tasklist='b',
  media=14,
  info=13
}

-- GENERATE DEFAULT THEME:
--
return generate_theme(
  theme_dir,
  color,
  panel_colors
)
end


return common_theme
