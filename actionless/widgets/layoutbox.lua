---------------------------------------------------------------------------
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2009 Julien Danjou
-- @release v3.5.5
-- @ 2013-2014 Yauhen Kirylau
---------------------------------------------------------------------------

local setmetatable = setmetatable
local ipairs = ipairs
local button = require("awful.button")
local layout = require("awful.layout")
local tag = require("awful.tag")
local beautiful = require("beautiful")
local wibox = require("wibox")
local imagebox = require("wibox.widget.imagebox")
local textbox = require("wibox.widget.textbox")

local helpers = require("actionless.helpers")
local decorated = require("actionless.widgets.common").decorated

--- Layoutbox widget "class".


--- Create a layoutbox widget. It draws a picture with the current layout
-- symbol of the current tag.
-- @param screen The screen number that the layout will be represented for.
-- @return An imagebox widget configured as a layoutbox.
function worker(args)

    local layoutbox = { mt = {} }

    local args = args or {}
    local fg = args.fg or beautiful.panel_bg or beautiful.bg or "#000000"
    local bg = args.bg or beautiful.panel_fg or beautiful.fg or "#ffffff"
    layoutbox.screen = args.screen or 1

    layoutbox.n_master = wibox.widget.background()
    layoutbox.n_master:set_widget(textbox())
    layoutbox.layout = wibox.widget.background()
    layoutbox.layout:set_widget(imagebox())
    layoutbox.n_col = wibox.widget.background()
    layoutbox.n_col:set_widget(textbox())

    layoutbox.widget = decorated({
        widgets={
            layoutbox.n_master, layoutbox.layout, layoutbox.n_col
        },
        bg=bg, fg=fg,
    })

    function layoutbox:update_layout()
        local layout = layout.getname(layout.get(self.screen))
        self.layout.widget:set_image(layout and beautiful["layout_" .. layout])
    end
    function layoutbox:update_nmaster(t)
        self.n_master.widget:set_text(tag.getnmaster(t))
    end
    function layoutbox:update_ncol(t)
        self.n_col.widget:set_text(tag.getncol(t))
    end
    function layoutbox:update_all(t)
        self:update_layout()
        self:update_nmaster(t)
        self:update_ncol(t)
    end

    layoutbox:update_all(nil)
    tag.attached_connect_signal(
        layoutbox.screen, "property::selected",
        function(t) layoutbox:update_all(t) end)
    tag.attached_connect_signal(
        layoutbox.screen, "property::layout",
        function(t) layoutbox:update_layout() end)
    tag.attached_connect_signal(
        layoutbox.screen, "property::ncol",
        function(t) layoutbox:update_ncol(t) end)
    tag.attached_connect_signal(
        layoutbox.screen, "property::nmaster",
        function(t) layoutbox:update_nmaster(t) end)
    return setmetatable(layoutbox, { __index = layoutbox.widget })
end


return setmetatable({}, { __call = function(_, ...) return worker(...) end })

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
