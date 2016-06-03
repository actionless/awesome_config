---------------------------------------------------------------------------
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008-2009 Julien Danjou
-- 2013-2014 Yauhen Kirylau
---------------------------------------------------------------------------

-- Grab environment we need
local capi = { button = button,
               client = client }
local wibox = require("wibox")

--- Additions for awful tasklist widget
local tasklist_addon = {}

function tasklist_addon.create_buttons(buttons, object)
    if buttons then
        local btns = {}
        for _, b in ipairs(buttons) do
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

function tasklist_addon.list_update(w, buttons, label, data, objects, spacing_length)
    -- update the widgets, creating them if needed
    spacing_length = spacing_length or 3
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
            bgb = wibox.container.background()
            m = wibox.container.margin(tb, 4, 4)
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
                m   = m,
            }
        end

        local text, bg, bg_image, icon = label(o, tb)
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
        if spacing_length then
            bgb = wibox.container.margin(bgb, spacing_length, 0)
        end
        w:add(bgb)
   end
end


function tasklist_addon.sorted_update(w, buttons, label, data, clients)
    local focused_client = client.focus
    if focused_client and focused_client.skip_taskbar then
        focused_client = nil
    end
    local sorted_clients = focused_client and {focused_client, } or {}
    for _, c in ipairs(clients) do
        table.insert(sorted_clients, c)
    end
    return tasklist_addon.list_update(w, buttons, label, data, sorted_clients)
end

return tasklist_addon

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
