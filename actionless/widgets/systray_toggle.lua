---------------------------------------------------------------------------
-- @author Yauheni Kirylau
-- @copyright 2013-2014 Yauheni Kirylau
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

--- widgets.systray_toggle
local systray_toggle = { mt = {}, arrow=false, popup=false }
systray_toggle.widget = wibox.widget.imagebox(beautiful.dropdown_icon)
systray_toggle.widget:connect_signal("mouse::enter", function ()
    systray_toggle.arrow = true
    systray_toggle.show()
end)
systray_toggle.widget:connect_signal("mouse::leave", function ()
    systray_toggle.arrow = false
    systray_toggle.check()
end)


function systray_toggle.initialize()
    local mywibox = wibox({})
    mywibox.ontop = true
    mywibox.opacity = beautiful.notification_opacity
    local systray = systray_widget()
    local flayout = wibox.layout.flex.horizontal()
    flayout:add(systray)
    local sg = systray_toggle.geometry
    local lmargin = wibox.layout.margin(
        wibox.widget.textbox(''),
        sg['lmargin'], 0,
        sg['tmargin'], sg['bmargin']
    )
    local rmargin = wibox.layout.margin(
        wibox.widget.textbox(''),
        0, sg['rmargin'],
        sg['tmargin'], sg['bmargin']
    )
    local layout = wibox.layout.align.horizontal()
    layout:set_left(lmargin)
    layout:set_middle(flayout)
    layout:set_right(rmargin)

    mywibox:set_widget(layout)
    mywibox:connect_signal("mouse::enter", function () systray_toggle.popup=true end)
    mywibox:connect_signal("mouse::leave", function () systray_toggle.popup=false systray_toggle.check() end)
    systray_toggle.wibox = mywibox
end

function systray_toggle.check()
    helpers.newdelay('systray_toggle', 0.3, systray_toggle.post_check)
end
function systray_toggle.post_check()
    if not systray_toggle.popup and not systray_toggle.arrow then
        systray_toggle.hide()
    end
end

function systray_toggle.show()
    systray_toggle.num_icons = capi.awesome.systray()
    if systray_toggle.num_icons < 1 then
        systray_toggle.num_icons = 2
    end

    local geometry = systray_toggle.geometry
    local width
        = systray_toggle.num_icons * geometry.icon_size
        + geometry.lmargin + geometry.rmargin
    local height
        = geometry.icon_size
        + geometry.tmargin + geometry.bmargin

    -- Set position and size
    systray_toggle.wibox.visible = true
    systray_toggle.wibox:geometry({x = geometry.x or systray_toggle.scrgeom.x,
                             y = geometry.y or systray_toggle.scrgeom.y,
                             height = height,
                             width = width})
end

function systray_toggle.hide()
    systray_toggle.wibox.visible = false
end

function systray_toggle.toggle()
    if systray_toggle.wibox.visible == false then
        systray_toggle.show()
    else
        systray_toggle.hide()
    end
end

local function worker(args)
    local args = args or {}
    local scr = args.screen or capi.mouse.screen or 1
    systray_toggle.scrgeom = capi.screen[scr].workarea
    systray_toggle.geometry = {
        scr = scr,
        icon_size = 32,
        x = systray_toggle.scrgeom.width - 350 ,
        y = 18,
        lmargin = 5,
        rmargin = 5,
        tmargin = 2,
        bmargin = 2,
    }
    systray_toggle.initialize()
    return setmetatable(systray_toggle, { __index = systray_toggle.widget})
end

return setmetatable(
	systray_toggle,
	{ __call = function(_, ...)
		return worker(...)
	end }
)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
