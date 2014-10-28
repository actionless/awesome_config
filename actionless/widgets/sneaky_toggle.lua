---------------------------------------------------------------------------
--based on this wiki article:
--http://awesome.naquadah.org/wiki/widget_Hide/Show
--
--adopted by Yauheni Kirylau
---------------------------------------------------------------------------

local wibox = require("wibox")
local awful = require("awful")
local wbase = require("wibox.widget.base")
local lbase = require("wibox.layout.base")
local beautiful = require("beautiful")

local capi = { client = client,
               mouse = mouse,
               screen = screen,
               awesome = awesome }
local setmetatable = setmetatable
local error = error
local abs = math.abs

local helpers = require("actionless.helpers")
local sneaky_tray = require("actionless.widgets.sneaky_tray")

--- widgets.sneaky_toggle
local sneaky_toggle = { mt = {}, arrow=false, popup=false }


function sneaky_toggle.initialize()
    local st = sneaky_toggle
    if st.enable_sneaky_tray then
        st.sneaky_tray = sneaky_tray({
            show_on_start = st.show_on_start
        })
        st.sneaky_tray_container = st.sneaky_tray.container
    end
    st.widgetvisible = true

    st.export_widget = wibox.layout.fixed.horizontal()
    --st.widget:connect_signal(
        --"mouse::enter", function ()
            --st.toggle()
    --end)
    st.export_widget:buttons(awful.util.table.join(
        awful.button({ }, 1, st.toggle),
        awful.button({ }, 3, function() end)
    ))

        st.container = wibox.layout.constraint()
            st.layout = wibox.layout.fixed.horizontal()
            --st.layout:add(wibox.widget.textbox(' ')) -- left margin
            for _, widget in ipairs(sneaky_toggle.loaded_widgets) do
                st.layout:add(widget)
            end
        st.container:set_widget(st.layout)
        st.container:set_strategy("min")
    st.export_widget:add(st.container)
    if st.sneaky_tray_container then
        st.export_widget:add(st.sneaky_tray_container)
    end

        st.arrow = wibox.widget.imagebox(beautiful.icon_left)
        st.arrow:set_resize(false)
    st.export_widget:add(st.arrow)

    if not st.show_on_start then
        st.toggle()
        st.sneaky_tray.toggle()
    end
end

function sneaky_toggle.toggle()
    if sneaky_toggle.sneaky_tray then
        sneaky_toggle.sneaky_tray.toggle()
    end
    if sneaky_toggle.widgetvisible then
        sneaky_toggle.container:set_widget(nil)
        sneaky_toggle.container:set_strategy("exact")
        sneaky_toggle.widgetvisible = false
        sneaky_toggle.arrow:set_image(beautiful.icon_left)
    else
        sneaky_toggle.container:set_strategy("min")
        sneaky_toggle.container:set_widget(sneaky_toggle.layout)
        sneaky_toggle.widgetvisible = true
        sneaky_toggle.arrow:set_image(beautiful.icon_right)
    end
end

local function worker(args)
    local args = args or {}
    sneaky_toggle.enable_sneaky_tray = args.enable_sneaky_tray
    sneaky_toggle.loaded_widgets = args.widgets
    sneaky_toggle.show_on_start = args.show_on_start or false
    sneaky_toggle.initialize()
    return setmetatable(sneaky_toggle, { __index = sneaky_toggle.export_widget})
end

return setmetatable(
	sneaky_toggle,
	{ __call = function(_, ...)
		return worker(...)
	end }
)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
