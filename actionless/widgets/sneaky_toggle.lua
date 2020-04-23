---------------------------------------------------------------------------
--based on this wiki article:
--http://awesome.naquadah.org/wiki/widget_Hide/Show
--
--adopted by Yauheni Kirylau
---------------------------------------------------------------------------

local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local gmath = require("gears.math")

local sneaky_tray = require("actionless.widgets.sneaky_tray")
local common_widgets = require("actionless.widgets.common")


--- widgets.sneaky_toggle
local sneaky_toggle = { mt = {} }


local function widget_factory(args)
  -- ARGUMENTS: ---------------------------------------------------------------
    args = args or {}
    local loaded_widgets = args.widgets
    local enable_sneaky_tray = args.enable_sneaky_tray
    local show_on_start = false
    if args.show_on_start ~= nil then show_on_start = args.show_on_start end

  -- WIDGET: ------------------------------------------------------------------
    local widget = wibox.layout.fixed.horizontal()
    local st = {}

    st.user_widgets_layout = wibox.layout.fixed.horizontal()
    for _, _widget in ipairs(loaded_widgets) do
        st.user_widgets_layout:add(_widget)
    end

    st.container = wibox.container.constraint()

    widget:add(st.container)

    if enable_sneaky_tray then
        st.sneaky_tray = sneaky_tray({
            show_on_start = show_on_start
        })
        widget:add(st.sneaky_tray.container)
    end

    local padding = args.padding
    local icon_widget
    if beautiful.icon_systray_show then
        st.image_arrow = wibox.widget.imagebox()
        icon_widget = st.image_arrow
    else
        st.text_arrow = wibox.widget.textbox('&lt;')
        icon_widget = st.text_arrow
        if not padding then
            padding = gmath.round(
                (beautiful.basic_panel_height - st.text_arrow:get_preferred_size()) / 2
            )
        end
    end
    args.widget=icon_widget
    args.widgets = {
      common_widgets.constraint{width=padding},
      icon_widget,
      common_widgets.constraint{width=padding},
    }
    args.spacing = 0
    local icon_layout = common_widgets.decorated_horizontal(args)
    icon_layout:buttons(awful.util.table.join(
        awful.button({ }, 1, function() st:toggle() end)
    ))

    widget:add(icon_layout)

  -- METHODS: -----------------------------------------------------------------
    function st:hide()
        if self.sneaky_tray then
            self.sneaky_tray.hide()
        end
        self.container:set_widget(nil)
        self.container:set_strategy("exact")
        self.widgetvisible = false
        if self.text_arrow then
            self.text_arrow:set_markup('&lt;')
        elseif self.image_arrow then
            self.image_arrow:set_image(beautiful.icon_systray_show)
        end
    end

    function st:show()
        if self.sneaky_tray then
            self.sneaky_tray.show()
        end
        self.container:set_strategy("min")
        self.container:set_widget(self.user_widgets_layout)
        self.widgetvisible = true
        if self.text_arrow then
            self.text_arrow:set_markup('&gt;')
        elseif self.image_arrow then
            self.image_arrow:set_image(beautiful.icon_systray_hide)
        end
    end

    function st:toggle()
        if self.widgetvisible then
            self:hide()
        else
            self:show()
        end
    end

  -- INIT: --------------------------------------------------------------------
    if show_on_start then
        st:show()
    else
        st:hide()
    end

    return setmetatable(st, { __index = widget})
end

return setmetatable(
    sneaky_toggle,
    { __call = function(_, ...)
        return widget_factory(...)
    end }
)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
