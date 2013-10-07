theme                               = {}

themes_dir                          = os.getenv("HOME") .. "/.config/awesome/themes/actionless"
theme.wallpaper                     = themes_dir .. "/wall.png"

theme.bg	= "#000000"
theme.alt_bg	= "#000000" -- 313131
theme.fg	= "#eeeeec"
theme.bright	= "#adeb71"
--theme.dark	= "#463c87"
theme.dark	= "#5e468c"
theme.light	= "#897eae"
theme.alt_fg	= "#a562b3"
theme.error	= "#ee82a8"
theme.border	= "#3c3c3c"

-- theme.font                          = "DejaVu Sans Mono 8"
theme.font                          = "tewi"
theme.fg_normal                     = theme.fg
theme.fg_focus                      = theme.bg
theme.fg_urgent                     = theme.bg
theme.bg_normal                     = theme.bg
theme.bg_focus                      = theme.error
theme.bg_urgent                     = theme.error
theme.border_width                  = "3"
theme.border_normal                 = theme.border
theme.border_focus                  = theme.bright
theme.border_marked                 = "#CC9393"
theme.titlebar_fg_focus             = theme.fg
theme.titlebar_bg_focus             = theme.dark
theme.titlebar_bg_normal            = theme.border
theme.taglist_fg	            = "#ff0000"
theme.taglist_bg	            = "#ff0000"
theme.taglist_fg_focus              = theme.fg
theme.taglist_bg_focus              = theme.dark
theme.tasklist_bg_focus             = theme.bg
theme.tasklist_fg_normal            = theme.fg
theme.tasklist_fg_minimize          = theme.alt_fg
theme.tasklist_fg_focus             = theme.light
theme.textbox_widget_margin_top     = 1
theme.notify_fg                     = theme.fg_normal
theme.notify_bg                     = theme.bg_normal
theme.notify_border                 = theme.border_focus
theme.awful_widget_height           = 14
theme.awful_widget_margin_top       = 2
theme.mouse_finder_color            = "#CC9393"
theme.menu_height                   = "16"
theme.menu_width                    = "140"

theme.mpd_text				= theme.light

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
theme.widget_vol                    = themes_dir .. "/icons/vol.png"
theme.widget_vol_low                = themes_dir .. "/icons/vol_low.png"
theme.widget_vol_no                 = themes_dir .. "/icons/vol_no.png"
theme.widget_vol_mute               = themes_dir .. "/icons/vol_mute.png"
theme.widget_mail                   = themes_dir .. "/icons/mail.png"
theme.widget_mail_on                = themes_dir .. "/icons/mail_on.png"

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


return theme
