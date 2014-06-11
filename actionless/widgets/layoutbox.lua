---------------------------------------------------------------------------
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2009 Julien Danjou
-- @release v3.5.5
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

--- Layoutbox widget "class".
local layoutbox = { mt = {} }
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


--- Create a layoutbox widget. It draws a picture with the current layout
-- symbol of the current tag.
-- @param screen The screen number that the layout will be represented for.
-- @return An imagebox widget configured as a layoutbox.
function worker(args)
    local args = args or {}
    local fg = args.fg or beautiful.fg
    local bg = args.bg or beautiful.bg
    local object = helpers.deepcopy(layoutbox)
    object.screen = args.screen or 1

    object.n_master = wibox.widget.background()
    object.n_master:set_fg(fg)
    object.n_master:set_bg(bg)
    object.n_master:set_widget(textbox())
    object.layout = wibox.widget.background()
    object.layout:set_fg(fg)
    object.layout:set_bg(bg)
    object.layout:set_widget(imagebox())
    object.n_col = wibox.widget.background()
    object.n_col:set_fg(fg)
    object.n_col:set_bg(bg)
    object.n_col:set_widget(textbox())

    local widget = wibox.layout.fixed.horizontal()
    widget:add(object.n_master)
    widget:add(object.layout)
    widget:add(object.n_col)

    object:update_all(nil)
    tag.attached_connect_signal(
        object.screen, "property::selected",
        function(t) object:update_all(t) end)
    tag.attached_connect_signal(
        object.screen, "property::layout",
        function(t) object:update_layout() end)
    tag.attached_connect_signal(
        object.screen, "property::ncol",
        function(t) object:update_ncol(t) end)
    tag.attached_connect_signal(
        object.screen, "property::nmaster",
        function(t) object:update_nmaster(t) end)
    return widget
end


return setmetatable(layoutbox, { __call = function(_, ...) return worker(...) end })

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
