theme                               = {}

themes_dir                          = os.getenv("HOME") .. "/.config/awesome/themes/lcars"
theme.dir			= themes_dir
theme.wallpaper_cmd                     = "hsetroot"

theme.bg	= "#000000"
theme.alt_bg	= "#000000"

theme.fg	= "#ffcc99"
theme.alt_fg	= "#ffcc66"
theme.shiny = "#000000"

theme.light	= "#cc99cc"
theme.dark	= "#cc6699"
theme.error	= "#ff3300"

theme.border	= "#000000"
theme.sel_border = "#cc99cc"
theme.titlebar	= "#000000"
theme.titlebar_focus	= "#cc6699"

theme.font                          = "Meslo LG S 10"
theme.sans_font             		= "Ubuntu 8.9"
theme.fg_normal                     = theme.fg
theme.bg_normal                     = theme.bg
theme.fg_focus                      = theme.error
theme.bg_focus                      = theme.dark
theme.fg_urgent                     = theme.bg
theme.bg_urgent                     = theme.error

theme.border_width                  = "3"
theme.border_normal                 = theme.border
theme.border_focus                  = theme.sel_border
theme.border_marked                 = theme.error

theme.taglist_font                  = theme.font
theme.taglist_fg_focus              = theme.shiny
theme.taglist_bg_focus              = theme.dark

theme.tasklist_font                 = theme.font
theme.tasklist_fg_focus             = theme.light
theme.tasklist_bg_focus             = theme.bg
theme.tasklist_fg_normal            = theme.fg
theme.tasklist_bg_normal            = theme.bg
theme.tasklist_fg_minimize          = theme.shiny
theme.tasklist_bg_minimize          = "#6666ff"

theme.titlebar_font                 = "Ubuntu Bold 9"
theme.titlebar_fg_focus             = theme.shiny
theme.titlebar_fg_normal            = theme.fg
theme.titlebar_bg_focus             = theme.titlebar_focus
theme.titlebar_bg_normal            = theme.titlebar

theme.notification_opacity = 0.8
theme.notification_font             = theme.sans_font
theme.notification_monofont         = theme.font
theme.notify_fg                     = theme.fg_normal
theme.notify_bg                     = theme.bg_normal
theme.notify_border                 = theme.border_focus

theme.textbox_widget_margin_top     = 1
theme.awful_widget_height           = 14
theme.awful_widget_margin_top       = 2
theme.mouse_finder_color            = theme.error
theme.menu_height                   = "16"
theme.menu_width                    = "140"

theme.mpd_text                      = theme.light

-- ICONS

theme.taglist_squares_sel           = themes_dir .. "/icons/square_sel.png"
theme.taglist_squares_unsel         = themes_dir .. "/icons/square_unsel.png"

theme.menu_submenu_icon             = themes_dir .. "/icons/submenu.png"
theme.taglist_squares_sel           = themes_dir .. "/icons/square_sel.png"
theme.taglist_squares_unsel         = themes_dir .. "/icons/square_unsel.png"

theme.layout_tile                   = themes_dir .. "/icons/tile.png"
theme.layout_tilegaps               = themes_dir .. "/icons/tilegaps.png"
theme.layout_tileleft               = themes_dir .. "/icons/tileleft.png"
theme.layout_tilebottom             = themes_dir .. "/icons/tilebottom.png"
theme.layout_tiletop                = themes_dir .. "/icons/tiletop.png"
theme.layout_fairv                  = themes_dir .. "/icons/fairv.png"
theme.layout_fairh                  = themes_dir .. "/icons/fairh.png"
theme.layout_spiral                 = themes_dir .. "/icons/spiral.png"
theme.layout_dwindle                = themes_dir .. "/icons/dwindle.png"
theme.layout_max                    = themes_dir .. "/icons/max.png"
theme.layout_fullscreen             = themes_dir .. "/icons/fullscreen.png"
theme.layout_magnifier              = themes_dir .. "/icons/magnifier.png"
theme.layout_floating               = themes_dir .. "/icons/floating.png"

theme.arrl                          = themes_dir .. "/icons/arrl.png"
theme.arrl_dl                       = themes_dir .. "/icons/arrl_dl.png"
theme.arrl_ld                       = themes_dir .. "/icons/arrl_ld.png"

theme.widget_ac                     = themes_dir .. "/icons/ac.png"
theme.widget_battery                = themes_dir .. "/icons/battery.png"
theme.widget_battery_low            = themes_dir .. "/icons/battery_low.png"
theme.widget_battery_empty          = themes_dir .. "/icons/battery_empty.png"
theme.widget_mem                    = themes_dir .. "/icons/mem.png"
theme.widget_cpu                    = themes_dir .. "/icons/cpu.png"
theme.widget_temp                   = themes_dir .. "/icons/temp.png"
theme.widget_net                    = themes_dir .. "/icons/net.png"
theme.widget_hdd                    = themes_dir .. "/icons/hdd.png"
theme.widget_music                  = themes_dir .. "/icons/note.png"
theme.widget_music_on               = themes_dir .. "/icons/note_on.png"
theme.widget_vol_high                    = themes_dir .. "/icons/vol_high.png"
theme.widget_vol                    = themes_dir .. "/icons/vol.png"
theme.widget_vol_low                = themes_dir .. "/icons/vol_low.png"
theme.widget_vol_no                 = themes_dir .. "/icons/vol_no.png"
theme.widget_vol_mute               = themes_dir .. "/icons/vol_mute.png"
theme.widget_mail                   = themes_dir .. "/icons/mail.png"
theme.widget_mail_on                = themes_dir .. "/icons/mail_on.png"

theme.dropdown_icon                = themes_dir .. "/icons/dropdown.png"

theme.tasklist_disable_icon         = true
--theme.tasklist_floating             = "*"
--theme.tasklist_maximized_horizontal = "_"
--theme.tasklist_maximized_vertical   = "|"

theme.titlebar_close_button_focus               = themes_dir .. "/icons/titlebar/close_focus.png"
theme.titlebar_close_button_normal              = themes_dir .. "/icons/titlebar/close_normal.png"

theme.titlebar_ontop_button_focus_active        = themes_dir .. "/icons/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active       = themes_dir .. "/icons/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive      = themes_dir .. "/icons/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive     = themes_dir .. "/icons/titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active       = themes_dir .. "/icons/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active      = themes_dir .. "/icons/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive     = themes_dir .. "/icons/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive    = themes_dir .. "/icons/titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active     = themes_dir .. "/icons/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active    = themes_dir .. "/icons/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive   = themes_dir .. "/icons/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive  = themes_dir .. "/icons/titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active    = themes_dir .. "/icons/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active   = themes_dir .. "/icons/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = themes_dir .. "/icons/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = themes_dir .. "/icons/titlebar/maximized_normal_inactive.png"

theme.titlebar_minimized_button_focus               = themes_dir .. "/icons/titlebar/minimized_focus.png"
theme.titlebar_minimized_button_normal              = themes_dir .. "/icons/titlebar/minimized_normal.png"

return theme
