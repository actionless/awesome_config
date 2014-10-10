---------------------------------------------------------------------------
--based on this wiki article:
--http://awesome.naquadah.org/wiki/Systray_Hide/Show
--
--adopted by Yauheni Kirylau
---------------------------------------------------------------------------

local wibox = require("wibox")
local awful = require("awful")
local wbase = require("wibox.widget.base")
local lbase = require("wibox.layout.base")
local systray_widget = require("wibox.widget.systray")
local beautiful = require("beautiful")

local capi = { client = client,
               mouse = mouse,
               screen = screen,
               awesome = awesome }
local setmetatable = setmetatable
local error = error
local abs = math.abs

local helpers = require("actionless.helpers")

--- widgets.sneaky_tray
local sneaky_tray = { mt = {}, arrow=false, popup=false }


function sneaky_tray.initialize()
    sneaky_tray.stupid_bug = drawin({})
    sneaky_tray.systrayvisible = true
    sneaky_tray.systray = wibox.layout.fixed.horizontal()
    sneaky_tray.systray:add(wibox.widget.systray())
    sneaky_tray.systray:add(wibox.widget.textbox(' ')) -- right margin
    sneaky_tray.container = wibox.layout.constraint()
    sneaky_tray.container:set_widget(sneaky_tray.systray)
    sneaky_tray.container:set_strategy("min")
    sneaky_tray.container:set_width(4)
    sneaky_tray.widget = wibox.layout.fixed.horizontal()
    sneaky_tray.widget:connect_signal(
        "mouse::enter", function ()
            sneaky_tray.toggle()
    end)
    sneaky_tray.widget:connect_signal(
        "mouse::leave", function ()
    end)
    sneaky_tray.arrow = wibox.widget.imagebox(beautiful.dropdown_icon)
    sneaky_tray.widget:add(sneaky_tray.arrow)
    sneaky_tray.widget:add(sneaky_tray.container)

    if sneaky_tray.show_on_start == false then
        sneaky_tray.toggle()
    end
end

function sneaky_tray.toggle()
    if sneaky_tray.systrayvisible then
        awesome.systray(sneaky_tray.stupid_bug, 0, 0, 10, true, "#000000", 0, 0)
        sneaky_tray.container:set_widget(nil)
        sneaky_tray.container:set_strategy("exact")
        sneaky_tray.systrayvisible = false
    else
        sneaky_tray.container:set_strategy("min")
        sneaky_tray.container:set_widget(sneaky_tray.systray)
        sneaky_tray.systrayvisible = true
    end
end

local function worker(args)
    local args = args or {}
    sneaky_tray.show_on_start = args.show_on_start or false
    sneaky_tray.initialize()
    return setmetatable(sneaky_tray, { __index = sneaky_tray.widget})
end

return setmetatable(
	sneaky_tray,
	{ __call = function(_, ...)
		return worker(...)
	end }
)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
