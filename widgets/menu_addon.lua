--------------------------------------------------------------------------------
-- @author Yauheni Kirylau &lt;actionless.loveless@gmail.com&gt;
-- @copyright 2013-2014 Yauheni Kirylau
--------------------------------------------------------------------------------

local menu = require("awful.menu")
local tags = require("awful.tag")
local capi = {
    client = client }
local escape_f = require("awful.util").escape

local table_merge = require("widgets.helpers").imerge


local menu_addon = { mt={} }


function menu_addon.clients_on_tag(args, item_args)
    local cls = capi.client.focus
    local cls_t = {}

    local all_tags = tags.gettags(cls.screen)
    for _, t in ipairs(all_tags) do
        if t.selected then
            clients = t.clients(t)
            for _, c in ipairs(clients) do
                cls_t[#cls_t + 1] = {
                    escape_f(c.name) or "",
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
