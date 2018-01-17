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
local sneaky_toggle = { mt = {} }


function sneaky_toggle.initialize()
    local st = sneaky_toggle
    st.export_widget = wibox.layout.fixed.horizontal()

    st.lie_layout = wibox.layout.fixed.horizontal()
    for _, widget in ipairs(sneaky_toggle.loaded_widgets) do
        st.lie_layout:add(widget)
    end

    st.container = wibox.container.constraint()
    st.export_widget:add(st.container)

    if st.enable_sneaky_tray then
        st.sneaky_tray = sneaky_tray({
            show_on_start = st.show_on_start
        })
        st.export_widget:add(st.sneaky_tray.container)
    end

    local apply_buttons_widget
    if beautiful.icon_systray_show then
        st.arrow = wibox.widget.imagebox()
        apply_buttons_widget = st.arrow
    else
        st.text_arrow = wibox.widget.textbox()
        apply_buttons_widget = st.text_arrow
    end
    apply_buttons_widget:buttons(awful.util.table.join(
        awful.button({ }, 1, st.toggle)
    ))

    st.export_widget:add(common_widgets.decorated_horizontal({
        widget=st.arrow or st.text_arrow
    }))

    if st.show_on_start then
        st.show()
    else
        st.hide()
    end
end

function sneaky_toggle.hide()
    if sneaky_toggle.sneaky_tray then
        sneaky_toggle.sneaky_tray.hide()
    end
    sneaky_toggle.container:set_widget(nil)
    sneaky_toggle.container:set_strategy("exact")
    sneaky_toggle.widgetvisible = false
    if beautiful.icon_systray_show then
        sneaky_toggle.arrow:set_image(beautiful.icon_systray_show)
    else
        sneaky_toggle.text_arrow:set_markup(' &lt; ')
    end
end

function sneaky_toggle.show()
    if sneaky_toggle.sneaky_tray then
        sneaky_toggle.sneaky_tray.show()
    end
    sneaky_toggle.container:set_strategy("min")
    sneaky_toggle.container:set_widget(sneaky_toggle.lie_layout)
    sneaky_toggle.widgetvisible = true
    if beautiful.icon_systray_show then
        sneaky_toggle.arrow:set_image(beautiful.icon_systray_hide)
    else
        sneaky_toggle.text_arrow:set_markup(' &gt; ')
    end
end

function sneaky_toggle.toggle()
    if sneaky_toggle.widgetvisible then
        sneaky_toggle.hide()
    else
        sneaky_toggle.show()
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
