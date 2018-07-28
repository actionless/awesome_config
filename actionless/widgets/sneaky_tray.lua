---------------------------------------------------------------------------
--based on this wiki article:
--http://awesome.naquadah.org/wiki/Systray_Hide/Show
--
--adopted by Yauheni Kirylau
---------------------------------------------------------------------------

local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")



--- widgets.sneaky_tray
local sneaky_tray = { mt = {} }


function sneaky_tray.initialize()
    sneaky_tray.stupid_bug = drawin({})
    sneaky_tray.widget = wibox.layout.fixed.horizontal()
    --sneaky_tray.widget:connect_signal(
        --"mouse::enter", function ()
            --sneaky_tray.toggle()
    --end)
        sneaky_tray.container = wibox.container.constraint()
            sneaky_tray.systray = wibox.widget.systray()
        sneaky_tray.arrow = wibox.widget.imagebox(beautiful.icon_systray_show)
        sneaky_tray.arrow:buttons(awful.util.table.join(
            awful.button({ }, 1, sneaky_tray.toggle)--,
        ))
        sneaky_tray.arrow:set_resize(beautiful.xresources.get_dpi() > 96)
    sneaky_tray.widget:add(sneaky_tray.container)
    sneaky_tray.widget:add(sneaky_tray.arrow)

    if sneaky_tray.show_on_start then
        sneaky_tray.show()
    else
        sneaky_tray.hide()
    end
end

function sneaky_tray.hide()
    awesome.systray(sneaky_tray.stupid_bug, 0, 0, 10, true, "#000000", 0, 0)
    sneaky_tray.container:set_widget(nil)
    sneaky_tray.container:set_strategy("exact")
    sneaky_tray.systrayvisible = false
    sneaky_tray.arrow:set_image(beautiful.icon_systray_show)
end

function sneaky_tray.show()
    sneaky_tray.container:set_strategy("min")
    sneaky_tray.container:set_widget(sneaky_tray.systray)
    sneaky_tray.systrayvisible = true
    sneaky_tray.arrow:set_image(beautiful.icon_systray_hide)
end

function sneaky_tray.toggle()
    if sneaky_tray.systrayvisible then
        sneaky_tray.hide()
    else
        sneaky_tray.show()
    end
end

local function worker(args)
    args = args or {}
    sneaky_tray.show_on_start = args.show_on_start
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
