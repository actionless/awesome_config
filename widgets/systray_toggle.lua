---------------------------------------------------------------------------
-- @author Uli Schlachter
-- @copyright 2010 Uli Schlachter
-- @release v3.5.2
---------------------------------------------------------------------------

local wibox     = require("wibox")
local awful     = require("awful")
local wbase = require("wibox.widget.base")
local systray_widget = require("wibox.widget.systray")
local lbase = require("wibox.layout.base")
local beautiful = require("beautiful")
--local capi = { awesome = awesome }
local capi = {
    client = client,
    mouse = mouse,
    screen = screen,
    awesome = awesome
}
local setmetatable = setmetatable
local error = error
local abs = math.abs

local helpers     = require("widgets.helpers")
local scr = 1
--- wibox.widget.systray
local systray_toggle = { mt = {} }

--systray_toggle.text = ' ↧ '

systray_toggle.geometry = {
    height = 24,
    width = 340,
    x = 1340,
    y = 18
}

local function initialize()
    local mywibox = wibox({})
    mywibox.ontop = true
    local layout = wibox.layout.fixed.horizontal()
    local systray = systray_widget()
    layout:add(systray)
    mywibox:set_widget(layout)
    mywibox:connect_signal("mouse::leave", function () systray_toggle.hide() end)
    systray_toggle.wibox = mywibox
end

function systray_toggle.show()
    if not systray_toggle.wibox then
        initialize()
    elseif systray_toggle.wibox.visible then -- Menu already shown, exit
        return
    end

    -- Set position and size
    scr = scr or capi.mouse.screen or 1
    local scrgeom = capi.screen[scr].workarea
    local geometry = systray_toggle.geometry
    systray_toggle.wibox:geometry({x = geometry.x or scrgeom.x,
                             y = geometry.y or scrgeom.y,
                             height = geometry.height or theme.get_font_height() * 1.5,
                             width = geometry.width or scrgeom.width})

    systray_toggle.wibox.visible = true
end

function systray_toggle.hide()
    systray_toggle.wibox.visible = false
end

function systray_toggle.mt:__call(...)
    scr = ...
--    widget = wibox.widget.textbox(systray_toggle.text)
    widget = wibox.widget.imagebox(beautiful.dropdown_icon)
    widget:connect_signal("mouse::enter", function () systray_toggle.show() end)
    systray_toggle.widget = widget
    return widget
end

--helpers.newtimer("systray", timeout, mpd.update)

return setmetatable(systray_toggle, systray_toggle.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
