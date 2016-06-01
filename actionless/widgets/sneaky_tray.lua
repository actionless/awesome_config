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
local sneaky_tray = { mt = {}, arrow=false, popup=false }


function sneaky_tray.initialize()
    local st = sneaky_tray
    st.stupid_bug = drawin({})
    st.systrayvisible = true
    st.systray = wibox.layout.fixed.horizontal()
    st.systray:add(wibox.widget.textbox(' ')) -- left margin
    st.systray:add(wibox.widget.systray())
    st.container = wibox.container.constraint()
    st.container:set_widget(st.systray)
    st.container:set_strategy("min")
    st.widget = wibox.layout.fixed.horizontal()
    --st.widget:connect_signal(
        --"mouse::enter", function ()
            --st.toggle()
    --end)
    st.widget:buttons(awful.util.table.join(
        awful.button({ }, 1, st.toggle),
        awful.button({ }, 3, function() end)
    ))
    st.arrow = wibox.widget.imagebox(beautiful.icon_left)
    st.arrow:set_resize(beautiful.hidpi or false)
    st.widget:add(st.container)
    st.widget:add(st.arrow)

    if st.show_on_start == false then
        st.toggle()
    end
end

function sneaky_tray.toggle()
    if sneaky_tray.systrayvisible then
        awesome.systray(sneaky_tray.stupid_bug, 0, 0, 10, true, "#000000", 0, 0)
        sneaky_tray.container:set_widget(nil)
        sneaky_tray.container:set_strategy("exact")
        sneaky_tray.systrayvisible = false
        sneaky_tray.arrow:set_image(beautiful.icon_left)
    else
        sneaky_tray.container:set_strategy("min")
        sneaky_tray.container:set_widget(sneaky_tray.systray)
        sneaky_tray.systrayvisible = true
        sneaky_tray.arrow:set_image(beautiful.icon_right)
    end
end

local function worker(args)
    args = args or {}
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
