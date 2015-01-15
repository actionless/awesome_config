--[[
example of theme which inherits another theme
]]--

local awful = require("awful")
local theme = dofile(awful.util.getdir("config").."/themes/lcars_xresources/theme.lua")

theme.border_normal		= theme.color[8]
theme.border_normal		= "#1d1234"
theme.titlebar_border           = theme.border_normal
--theme.border_focus		= theme.sel_border


return theme
