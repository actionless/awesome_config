---------------------------------------------------------------------------
--- Tasklist widget module for awful
--
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008-2009 Julien Danjou
-- @release v3.5.2-750-g62847c6
-- @classmod awful.widget.tasklist
---------------------------------------------------------------------------

-- Grab environment we need
local capi = { screen = screen,
               client = client }
local ipairs = ipairs
local setmetatable = setmetatable
local table = table
local common = require("awful.widget.common")
local beautiful = require("beautiful")
local client = require("awful.client")
local util = require("awful.util")
local tag = require("awful.tag")
local wibox = require("wibox")
local flex = require("wibox.layout.flex")
local timer = require("gears.timer")
local awful = require("awful")

local dpi = beautiful.xresources.apply_dpi


local a_common = require("actionless.widgets.common")


local lcarslist = { mt = {} }

local function taglist_label(t, w, args)
    if not args then args = {} end
    local theme = beautiful.get()
    local fg_focus = args.fg_focus or theme.taglist_fg_focus or theme.fg_focus
    local bg_focus = args.bg_focus or theme.taglist_bg_focus or theme.bg_focus
    local fg_urgent = args.fg_urgent or theme.taglist_fg_urgent or theme.fg_urgent
    local bg_urgent = args.bg_urgent or theme.taglist_bg_urgent or theme.bg_urgent
    local bg_occupied = args.bg_occupied or theme.taglist_bg_occupied
    local fg_occupied = args.fg_occupied or theme.taglist_fg_occupied
    local bg_empty = args.bg_empty or theme.taglist_bg_empty
    local fg_empty = args.fg_empty or theme.taglist_fg_empty
    local taglist_squares_sel_empty = args.squares_sel_empty or theme.taglist_squares_sel_empty
    local bg_color = nil
    local fg_color = nil
    local is_selected = false
    local cls = t:clients()
    if not (#cls == 0 and t.selected and taglist_squares_sel_empty) and not is_selected then
        if #cls > 0 then
            if bg_occupied then bg_color = bg_occupied end
            if fg_occupied then fg_color = fg_occupied end
        else
            if bg_empty then bg_color = bg_empty end
            if fg_empty then fg_color = fg_empty end
        end
        if tag.getproperty(t, "urgent") then
            if bg_urgent then bg_color = bg_urgent end
            if fg_urgent then fg_color = fg_urgent end
        end
    end
    if t.selected then
        bg_color = bg_focus
        fg_color = fg_focus
    end

    w:set_bg(bg_color)
    w:set_fg(fg_color)
    return w
end

local function tasklist_label(c, args)
    if not args then args = {} end
    local theme = beautiful.get()

    local fg_normal = util.ensure_pango_color(args.fg_normal or theme.panel_widget_bg or theme.fg_normal, "white")
    local bg_normal = args.bg_normal or theme.panel_widget_fg or theme.bg_normal or "#000000"

    --local fg_focus = util.ensure_pango_color(args.fg_focus or theme.color.color3 or theme.tasklist_fg_focus or theme.fg_focus, fg_normal)
    local fg_focus = fg_normal
    local bg_focus = args.bg_focus or theme.taglist_bg_focus or theme.bg_focus or "#000000"

    local fg_urgent = util.ensure_pango_color(args.fg_urgent or theme.tasklist_fg_urgent or theme.fg_urgent, fg_normal)
    local bg_urgent = args.bg_urgent or theme.tasklist_bg_urgent or theme.bg_urgent or bg_normal
    local fg_minimize = util.ensure_pango_color(args.fg_minimize or theme.tasklist_fg_minimize or theme.fg_minimize, fg_normal)
    local bg_minimize = args.bg_minimize or theme.panel_widget_bg_disabled or theme.tasklist_bg_minimize or theme.bg_minimize or bg_normal
    local bg_image_focus = args.bg_image_focus or theme.bg_image_focus
    local bg_image_urgent = args.bg_image_urgent or theme.bg_image_urgent
    local bg_image_minimize = args.bg_image_minimize or theme.bg_image_minimize
    local tasklist_disable_icon = args.tasklist_disable_icon or theme.tasklist_disable_icon or false
    local font = args.font or theme.panel_widget_font or theme.panel_font or theme.font -- theme.tasklist_font or theme.font or ""
    local bg = nil
    local text = "<span font_desc='"..font.."'>"
    local name = ""
    local bg_image = nil

    local lenth_chars = 13
    local lenth_chars = 12

    if c.is_tag then
        name = c.tag.name
        name = string.format("%"..lenth_chars.."."..lenth_chars.."s", name)
        local tag_fg_color = c.tag.selected and (
            theme.taglist_fg_focus or theme.fg_focus
        ) or bg_minimize
        name = "<span color='"..tag_fg_color.."'>"..name.."</span>"
        return name
    end

    -- symbol to use to indicate certain client properties
    local sticky = args.sticky or theme.tasklist_sticky or "▪"
    local ontop = args.ontop or theme.tasklist_ontop or '⌃'
    local above = args.above or theme.tasklist_above or '▴'
    local below = args.below or theme.tasklist_below or '▾'
    local floating = args.floating or theme.tasklist_floating or '✈'
    local maximized = args.maximized or theme.tasklist_maximized or '<b>+</b>'
    local maximized_horizontal = args.maximized_horizontal or theme.tasklist_maximized_horizontal or '⬌'
    local maximized_vertical = args.maximized_vertical or theme.tasklist_maximized_vertical or '⬍'

    if not theme.tasklist_plain_task_name then
        if c.sticky then name = name .. sticky end

        if c.ontop then name = name .. ontop
        elseif c.above then name = name .. above
        elseif c.below then name = name .. below end

        if c.maximized then
            name = name .. maximized
        else
            if c.maximized_horizontal then name = name .. maximized_horizontal end
            if c.maximized_vertical then name = name .. maximized_vertical end
            if c.floating then name = name .. floating end
        end
    end

    if c.minimized then
        name = name .. (util.escape(c.icon_name) or util.escape(c.name) or util.escape("<untitled>"))
    else
        name = name .. (util.escape(c.name) or util.escape("<untitled>"))
    end

    name = string.format("%"..lenth_chars.."."..lenth_chars.."s", name)
    name = util.escape(name)

    local focused = capi.client.focus == c
    -- Handle transient_for: the first parent that does not skip the taskbar
    -- is considered to be focused, if the real client has skip_taskbar.
    if not focused and capi.client.focus and capi.client.focus.skip_taskbar
        and client.get_transient_for_matching(capi.client.focus,
                                              function(c)
                                                  return not c.skip_taskbar
                                              end) == c then
        focused = true
    end
    if focused then
        bg = bg_focus
        --text = text .. "<span color='"..fg_focus.."'>"..name.."</span>"
        text = text .. "<span font_desc='"..(beautiful.taglist_font or beautiful.font).."'>"..name.."</span>"
        bg_image = bg_image_focus
    elseif c.urgent then
        bg = bg_urgent
        text = text .. "<span color='"..fg_urgent.."'>"..name.."</span>"
        bg_image = bg_image_urgent
    elseif c.minimized then
        bg = bg_minimize
        text = text .. "<span color='"..fg_minimize.."'>"..name.."</span>"
        bg_image = bg_image_minimize
    else
        --bg = bg_normal
        --text = text .. "<span color='"..fg_normal.."'>"..name.."</span>"
        --bg_image = bg_image_normal
        text = text .. name
    end
    text = text .. "</span>"
    return text, bg, bg_image, not tasklist_disable_icon and c.icon or nil
end


local function tag_group(t, buttons, data, update_function)
    local clients = {}
    table.insert(clients, {tag=t, is_tag=true})
    for _, c in ipairs(t:clients()) do
        table.insert(clients, c)
    end

    local clients_on_tag = flex.vertical()
    local function label(c) return tasklist_label(c) end
    update_function(clients_on_tag, buttons, label, data, clients)

    local widget = a_common.decorated({
        widget = clients_on_tag,
        min_height = dpi(100),
        orientation = "vertical",
    })
    taglist_label(t, widget)
    return widget
end


local v_sep_constraint = a_common.constraint({
    height=beautiful.panel_padding_bottom
})
local v_sep = wibox.container.background(
    v_sep_constraint,
    beautiful.panel_bg
)

local function tasklist_update(s, w, buttons, tag_filter, data, update_function)
    tag_filter = tag_filter or function() return true end
    w:reset()
    for _, t in ipairs(s.tags) do
        -- @TODO: cache tag_group widgets for the tags
        if not tag.getproperty(t, "hide") and tag_filter(t) then
            w:add(tag_group(t, buttons, data, update_function))
            w:add(v_sep)
        end
    end
end

--- Create a new tasklist widget. The last two arguments (update_function
-- and base_widget) serve to customize the layout of the tasklist (eg. to
-- make it vertical). For that, you will need to copy the
-- awful.widget.common.list_update function, make your changes to it
-- and pass it as update_function here. Also change the base_widget if the
-- default is not what you want.
-- @param screen The screen to draw tasklist for.
-- @param filter Filter function to define what clients will be listed.
-- @param buttons A table with buttons binding to set.
-- @param[opt] update_function Function to create a tag widget on each
--   update. See `awful.widget.common.list_update`.
-- @param base_widget.bg_normal The background color for unfocused client.
-- @param base_widget.bg_normal The background color for unfocused client.
-- @param base_widget.fg_normal The foreground color for unfocused client.
-- @param base_widget.bg_focus The background color for focused client.
-- @param base_widget.fg_focus The foreground color for focused client.
-- @param base_widget.bg_urgent The background color for urgent clients.
-- @param base_widget.fg_urgent The foreground color for urgent clients.
-- @param base_widget.bg_minimize The background color for minimized clients.
-- @param base_widget.fg_minimize The foreground color for minimized clients.
-- @param base_widget.floating Symbol to use for floating clients.
-- @param base_widget.ontop Symbol to use for ontop clients.
-- @param base_widget.above Symbol to use for clients kept above others.
-- @param base_widget.below Symbol to use for clients kept below others.
-- @param base_widget.maximized Symbol to use for clients that have been maximized (vertically and horizontally).
-- @param base_widget.maximized_horizontal Symbol to use for clients that have been horizontally maximized.
-- @param base_widget.maximized_vertical Symbol to use for clients that have been vertically maximized.
-- @param base_widget.font The font.
function lcarslist.new(screen, tag_filter, buttons, tasklist_update_function)
    local base_widget = wibox.layout.fixed.vertical()
    tasklist_update_function = tasklist_update_function or common.list_update

    local data = setmetatable({}, { __mode = 'k' })

    local queued_update = false
    local u = function ()
        -- Add a delayed callback for the first update.
        if not queued_update then
            queued_update = true
            timer.delayed_call(function()
                tasklist_update(screen, base_widget, buttons, tag_filter, data, tasklist_update_function)
                queued_update = false
            end)
        end
    end
    tag.attached_connect_signal(screen, "property::selected", u)
    tag.attached_connect_signal(screen, "property::activated", u)
    capi.client.connect_signal("property::urgent", u)
    capi.client.connect_signal("property::sticky", u)
    capi.client.connect_signal("property::ontop", u)
    capi.client.connect_signal("property::above", u)
    capi.client.connect_signal("property::below", u)
    capi.client.connect_signal("property::floating", u)
    capi.client.connect_signal("property::maximized_horizontal", u)
    capi.client.connect_signal("property::maximized_vertical", u)
    capi.client.connect_signal("property::minimized", u)
    capi.client.connect_signal("property::name", u)
    capi.client.connect_signal("property::icon_name", u)
    capi.client.connect_signal("property::icon", u)
    capi.client.connect_signal("property::skip_taskbar", u)
    capi.client.connect_signal("property::screen", function(c, old_screen)
        if screen == c.screen or screen == old_screen then
            u()
        end
    end)
    capi.client.connect_signal("property::hidden", u)
    capi.client.connect_signal("tagged", u)
    capi.client.connect_signal("untagged", u)
    capi.client.connect_signal("unmanage", u)
    capi.client.connect_signal("list", u)
    capi.client.connect_signal("focus", u)
    capi.client.connect_signal("unfocus", u)
    u()
    return base_widget
end

function lcarslist.mt:__call(...)
    return lcarslist.new(...)
end

return setmetatable(lcarslist, lcarslist.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
