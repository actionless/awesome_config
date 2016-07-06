---------------------------------------------------------------------------
--based on this wiki article:
--http://awesome.naquadah.org/wiki/widget_Hide/Show
--
--adopted by Yauheni Kirylau
---------------------------------------------------------------------------

local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")



local sneaky_tray = require("actionless.widgets.sneaky_tray")
local common_widgets = require("actionless.widgets.common")

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

        st.container = wibox.container.constraint()
            st.lie_layout = wibox.layout.fixed.horizontal()
            for _, widget in ipairs(sneaky_toggle.loaded_widgets) do
                st.lie_layout:add(widget)
            end
        st.container:set_widget(st.lie_layout)
        st.container:set_strategy("min")
    st.export_widget = wibox.layout.fixed.horizontal()
    st.export_widget:buttons(awful.util.table.join(
        awful.button({ }, 1, st.toggle)
    ))
    st.export_widget:add(st.container)
    if st.sneaky_tray_container then
        st.export_widget:add(st.sneaky_tray_container)
    end

        if beautiful.widget_tray_left then
            st.arrow = wibox.widget.imagebox(beautiful.widget_tray_left)
        else
            st.text_arrow = wibox.widget.textbox('')
        end
        st.export_widget:add(common_widgets.decorated_horizontal({
            left_separators = {'arrl'},
            right_separators = {'arrr', ' '},
            widget=beautiful.widget_tray_left and st.arrow or st.text_arrow
        }))

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
        if beautiful.widget_tray_left then
            sneaky_toggle.arrow:set_image(beautiful.widget_tray_left)
        else
            sneaky_toggle.text_arrow:set_markup(' &lt; ')
        end
    else
        sneaky_toggle.container:set_strategy("min")
        sneaky_toggle.container:set_widget(sneaky_toggle.lie_layout)
        sneaky_toggle.widgetvisible = true
        if beautiful.widget_tray_left then
            sneaky_toggle.arrow:set_image(beautiful.widget_tray_right)
        else
            sneaky_toggle.text_arrow:set_markup(' &gt; ')
        end
    end
end

local function worker(args)
    args = args or {}
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
