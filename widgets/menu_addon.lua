--------------------------------------------------------------------------------
-- @author Damien Yauheni Kirylau &lt;actionless.loveless@gmail.com&gt;
-- @copyright 2013, 2014 Yauheni Kirylau
--------------------------------------------------------------------------------

local menu = require("awful.menu")
local tags = require("awful.tag")
local capi = {
    timer = timer,
    screen = screen,
    mouse = mouse,
    client = client }
local util = require("awful.util")


local menu_addon = { mt={} }


local table_merge = function (t, set)
    for _, v in ipairs(set) do
        table.insert(t, v)
    end
end


function menu_addon.clients_on_tag(args, item_args)
    local cls = capi.client.get()
    local cls_t = {}
    local all_tags = tags.gettags(1)
    for k, t in ipairs(all_tags) do
        if t.selected then
            clients = t.clients(t)
            for k2, c in ipairs(clients) do
                cls_t[#cls_t + 1] = {
                    util.escape(c.name) or "",
                    function ()
                        if not c:isvisible() then
                            tags.viewmore(c:tags(), c.screen)
                        end
                        capi.client.focus = c
                        c:raise()
                    end,
                    c.icon }
                if item_args then
                    if type(item_args) == "function" then
                        table_merge(cls_t[#cls_t], item_args(c))
                    else
                        table_merge(cls_t[#cls_t], item_args)
                    end
                end
            end
        end
    end
    args = args or {}
    args.items = args.items or {}
    table_merge(args.items, cls_t)

    local m = menu.new(args)
    m:show(args)
    return m
end

function menu_addon.mt:__call(...)
    return menu.new(...)
end

return setmetatable(menu_addon, menu_addon.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=4:softtabstop=4:textwidth=80
