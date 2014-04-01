---------------------------------------------------------------------------
-- @author Yauheni Kirylau
-- @copyright 2013-2014 Yauheni Kirylau
---------------------------------------------------------------------------

local wibox     = require("wibox")
local awful     = require("awful")
local wbase = require("wibox.widget.base")
local lbase = require("wibox.layout.base")
local systray_widget = require("wibox.widget.systray")
local beautiful = require("widgets.helpers").beautiful
local asyncshell = require("widgets.asyncshell")
local helpers     = require("widgets.helpers")
local settings     = require("widgets.settings")
local capi = {
    client = client,
    mouse = mouse,
    screen = screen,
    awesome = awesome
}
local setmetatable = setmetatable
local error = error
local abs = math.abs

--- widgets.systray_toggle
local systray_toggle = { mt = {}, arrow=false, popup=false }
local scr = 1

systray_toggle.geometry = {
    icon_size = 24,
    x = settings.screen_width - 350 ,
    y = 18,
    lmargin = 5,
    rmargin = 5,
    tmargin = 2,
    bmargin = 2,
}

local function initialize()
    local mywibox = wibox({})
    mywibox.ontop = true
    mywibox.opacity = beautiful.notification_opacity
    local systray = systray_widget()
    local flayout = wibox.layout.flex.horizontal()
    flayout:add(systray)
    local lmargin = wibox.layout.margin(wibox.widget.textbox(''),
                                       systray_toggle.geometry['lmargin'], 0,
                                       systray_toggle.geometry['tmargin'], systray_toggle.geometry['bmargin']
                                       )
    local rmargin = wibox.layout.margin(wibox.widget.textbox(''),
                                       0, systray_toggle.geometry['rmargin'],
                                       systray_toggle.geometry['tmargin'], systray_toggle.geometry['bmargin']
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
    asyncshell.wait(0.1, systray_toggle.post_check)
end
function systray_toggle.post_check()
    if not systray_toggle.popup and not systray_toggle.arrow then
        systray_toggle.hide()
    end
end

function systray_toggle.show()
    local num_icons = capi.awesome.systray()
    local geometry = systray_toggle.geometry

    if num_icons < 1 then
        num_icons = 2
    end
    local width = num_icons * geometry.icon_size + geometry.lmargin + geometry.rmargin
    local height = geometry.icon_size + geometry.tmargin + geometry.bmargin

    if not systray_toggle.wibox then
        initialize()
    elseif systray_toggle.wibox.visible then -- Menu already shown, exit
        return
    end

    -- Set position and size
    scr = scr or capi.mouse.screen or 1
    local scrgeom = capi.screen[scr].workarea
    systray_toggle.wibox:geometry({x = geometry.x or scrgeom.x,
                             y = geometry.y or scrgeom.y,
                             height = height,
                             width = width})
    systray_toggle.wibox.visible = true
end

function systray_toggle.hide()
    systray_toggle.wibox.visible = false
end

function systray_toggle.toggle()
    if not systray_toggle.wibox then
        systray_toggle.show()
        return
    end
    if systray_toggle.wibox.visible == false then
        systray_toggle.show()
    else
        systray_toggle.hide()
    end
end

function systray_toggle.mt:__call(...)
    scr = ...
    widget = wibox.widget.imagebox(beautiful.dropdown_icon)
    widget:connect_signal("mouse::enter", function ()
        systray_toggle.arrow = true
        systray_toggle.show()
    end)
    widget:connect_signal("mouse::leave", function ()
        systray_toggle.arrow = false
        systray_toggle.check()
    end)
    systray_toggle.widget = widget
    return setmetatable(systray_toggle, { __index = widget})
end

return setmetatable(systray_toggle, systray_toggle.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
