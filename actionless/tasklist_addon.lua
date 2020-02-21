---------------------------------------------------------------------------
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008-2009 Julien Danjou
-- 2013-2014 Yauhen Kirylau
---------------------------------------------------------------------------

local awful = require("awful")

--- Additions for awful tasklist widget
local tasklist_addon = {}

function tasklist_addon.sorted_update(w, buttons, label, data, clients)

    local focused_client = client.focus
    local screen_focused_client = nil

    for idx, c in ipairs(clients) do
        if c == focused_client then
            screen_focused_client = table.remove(clients, idx)
            break
        end
    end

    local sorted_clients = screen_focused_client and {
        screen_focused_client,
    } or {}
    for _, c in ipairs(clients) do
        table.insert(sorted_clients, c)
    end

    return awful.widget.common.list_update(
        w, buttons, label, data, sorted_clients
    )
end

function tasklist_addon.current_and_minimizedcurrenttags(c, s)
    return (
        c.screen==s and c == client.focus and not c.skip_taskbar
    ) or awful.widget.tasklist.filter.minimizedcurrenttags(c, s)
end

return tasklist_addon

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
