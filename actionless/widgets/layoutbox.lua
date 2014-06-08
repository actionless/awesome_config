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

--- Layoutbox widget.
-- awful.widget.layoutbox
local layoutbox = { mt = {} }

--- Create a layoutbox widget. It draws a picture with the current layout
-- symbol of the current tag.
-- @param screen The screen number that the layout will be represented for.
-- @return An imagebox widget configured as a layoutbox.
function layoutbox.new(screen)
    local screen = screen or 1
    layoutbox.n_master = textbox()
    layoutbox.layout = imagebox()
    layoutbox.n_col = textbox()
    layoutbox.w = wibox.layout.fixed.horizontal()
    layoutbox.w:add(layoutbox.n_master)
    layoutbox.w:add(layoutbox.layout)
    layoutbox.w:add(layoutbox.n_col)

    local function update_layout(t)
        local layout = layout.getname(layout.get(screen))
        layoutbox.layout:set_image(layout and beautiful["layout_" .. layout])
    end
    local function update_nmaster(t)
        layoutbox.n_master:set_text(tag.getnmaster(t))
    end
    local function update_ncol(t)
        layoutbox.n_col:set_text(tag.getncol(t))
    end
    local function update_all(t)
        update_layout(t, layoutbox)
        update_nmaster(t, layoutbox)
        update_ncol(t, layoutbox)
    end

    update_all(nil)
    tag.attached_connect_signal(screen, "property::selected", update_all)
    tag.attached_connect_signal(screen, "property::layout", update_layout)
    tag.attached_connect_signal(screen, "property::ncol", update_ncol)
    tag.attached_connect_signal(screen, "property::nmaster", update_nmaster)

    return layoutbox.w
end

function layoutbox.mt:__call(...)
    return layoutbox.new(...)
end

return setmetatable(layoutbox, layoutbox.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
