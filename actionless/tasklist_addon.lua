---------------------------------------------------------------------------
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008-2009 Julien Danjou
-- 2013-2014 Yauhen Kirylau
---------------------------------------------------------------------------

-- Grab environment we need
local capi = { button = button,
               client = client }
local util = require("awful.util")
local tag = require("awful.tag")
local wibox = require("wibox")
local imagebox = require("wibox.widget.imagebox")
local textbox = require("wibox.widget.textbox")

--- Additions for awful tasklist widget
local tasklist_addon = {}

function tasklist_addon.create_buttons(buttons, object)
    if buttons then
        local btns = {}
        for kb, b in ipairs(buttons) do
            -- Create a proxy button object: it will receive the real
            -- press and release events, and will propagate them the the
            -- button object the user provided, but with the object as
            -- argument.
            local btn = capi.button { modifiers = b.modifiers, button = b.button }
            btn:connect_signal("press", function () b:emit_signal("press", object) end)
            btn:connect_signal("release", function () b:emit_signal("release", object) end)
            btns[#btns + 1] = btn
        end

        return btns
    end
end

function tasklist_addon.list_update(w, buttons, label, data, objects, right_margin)
    -- update the widgets, creating them if needed
    right_margin = right_margin or 3
    w:reset()
    for i, o in ipairs(objects) do
        local cache = data[o]
        local ib, tb, bgb, m, l
        if cache then
            ib = cache.ib
            tb = cache.tb
            bgb = cache.bgb
            m   = cache.m
        else
            ib = wibox.widget.imagebox()
            tb = wibox.widget.textbox()
            bgb = wibox.widget.background()
            m = wibox.layout.margin(tb, 4, 4)
            l = wibox.layout.fixed.horizontal()

            -- All of this is added in a fixed widget
            l:fill_space(true)
            l:add(ib)
            l:add(m)

            -- And all of this gets a background
            bgb:set_widget(l)

            bgb:buttons(tasklist_addon.create_buttons(buttons, o))

            data[o] = {
                ib = ib,
                tb = tb,
                bgb = bgb,
                m   = m
            }
        end

        local text, bg, bg_image, icon = label(o)
        -- The text might be invalid, so use pcall
        if not pcall(tb.set_markup, tb, text) then
            tb:set_markup("<i>&lt;Invalid text&gt;</i>")
        end
        bgb:set_bg(bg)
        if type(bg_image) == "function" then
            bg_image = bg_image(tb,o,m,objects,i)
        end
        bgb:set_bgimage(bg_image)
        ib:set_image(icon)
        if right_margin and i~=1 then
            local delimiter = wibox.layout.margin(bgb, right_margin, 0)
            w:add(delimiter)
        else
            w:add(bgb)
        end
   end
end

function tasklist_addon.focused_and_minimized_current_tag_filter(c, screen)
    -- Print client on the same screen as this widget
    if c.screen == screen and capi.client.focus == c then
        return true
    end
    -- Only print client on the same screen as this widget
    if c.screen ~= screen then return false end
    -- Check client is minimized
    if not c.minimized then return false end
    -- Include sticky client
    if c.sticky then return true end
    local tags = tag.gettags(screen)
    for k, t in ipairs(tags) do
        -- Select only minimized clients
        if t.selected then
            local ctags = c:tags()
            for _, v in ipairs(ctags) do
                if v == t then
                    return true
                end
            end
        end
    end
    return false
end

return tasklist_addon

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
