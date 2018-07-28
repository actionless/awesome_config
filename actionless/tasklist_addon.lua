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
    if focused_client and focused_client.skip_taskbar then
        focused_client = nil
    end
    local sorted_clients = focused_client and {focused_client, } or {}
    for _, c in ipairs(clients) do
        table.insert(sorted_clients, c)
    end
    return awful.widget.common.list_update(w, buttons, label, data, sorted_clients)
end

return tasklist_addon

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
