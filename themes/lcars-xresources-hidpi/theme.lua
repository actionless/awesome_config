local awful = require("awful")
local dpi = require("actionless.xresources").compute_fontsize

local theme = dofile(awful.util.getdir("config").."/themes/lcars_xresources/theme.lua")

theme.hidpi = true

--theme.border_normal            = theme.color["8"]
--theme.border_normal            = "#1d1234"
--theme.titlebar_border           = theme.border_normal

theme.error = theme.color["1"]
theme.warning = theme.color["2"]

theme.panel_widget_bg_error = theme.color["1"]
theme.panel_widget_fg_error = theme.color["15"]

theme.widget_close_bg = theme.tasklist_fg_focus

local basic_panel_height = 36
theme.panel_height = basic_panel_height + theme.panel_padding_bottom
theme.titlebar_height = basic_panel_height + theme.border_width

 -- FONTS:
theme.font = "Monospace Bold "..tostring(dpi(10))
theme.sans_font = "Sans Bold "..tostring(dpi(10))

theme.taglist_font = theme.font
theme.tasklist_font = theme.sans_font
theme.titlebar_font = theme.font
theme.notification_font = theme.sans_font
theme.notification_monofont = theme.font


return theme
