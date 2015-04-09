local awful = require("awful")

local theme = dofile(awful.util.getdir("config").."/themes/lcars_xresources/theme.lua")

theme.border_normal            = theme.color["8"]
theme.border_normal            = "#1d1234"
theme.titlebar_border           = theme.border_normal

theme.error = theme.color["1"]
theme.warning = theme.color["2"]

theme.panel_widget_bg_error = theme.color["1"]
theme.panel_widget_fg_error = theme.color["15"]

theme.widget_close_bg = theme.tasklist_fg_focus
theme.apw_bg_color = theme.panel_info

return theme
