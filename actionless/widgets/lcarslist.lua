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


local tasklist = { mt = {} }

-- Public structures
tasklist.filter = {}


function tasklist.taglist_label(t, w, args)
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
    local taglist_squares_sel = args.squares_sel or theme.taglist_squares_sel
    local taglist_squares_unsel = args.squares_unsel or theme.taglist_squares_unsel
    local taglist_squares_sel_empty = args.squares_sel_empty or theme.taglist_squares_sel_empty
    local taglist_squares_unsel_empty = args.squares_unsel_empty or theme.taglist_squares_unsel_empty
    local taglist_squares_resize = theme.taglist_squares_resize or args.squares_resize or "true"
    local taglist_disable_icon = args.taglist_disable_icon or theme.taglist_disable_icon or false
    local font = args.font or theme.taglist_font or theme.font or ""
    local text = nil
    local sel = capi.client.focus
    local bg_color = nil
    local fg_color = nil
    local bg_image
    local icon
    local bg_resize = false
    local is_selected = false
    local cls = t:clients()
    if sel then
        if taglist_squares_sel then
            -- Check that the selected clients is tagged with 't'.
            local seltags = sel:tags()
            for _, v in ipairs(seltags) do
                if v == t then
                    bg_image = taglist_squares_sel
                    bg_resize = taglist_squares_resize == "true"
                    is_selected = true
                    break
                end
            end
        end
    end
    if #cls == 0 and t.selected and taglist_squares_sel_empty then
        bg_image = taglist_squares_sel_empty
        bg_resize = taglist_squares_resize == "true"
    elseif not is_selected then
        if #cls > 0 then
            if taglist_squares_unsel then
                bg_image = taglist_squares_unsel
                bg_resize = taglist_squares_resize == "true"
            end
            if bg_occupied then bg_color = bg_occupied end
            if fg_occupied then fg_color = fg_occupied end
        else
            if taglist_squares_unsel_empty then
                bg_image = taglist_squares_unsel_empty
                bg_resize = taglist_squares_resize == "true"
            end
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

    local t_name = t.name

    if args.is_separator then
        t_name=" "
    else
        local lenth_chars = 12
        t_name = string.format("%"..lenth_chars.."."..lenth_chars.."s", t_name)
    end

    if not tag.getproperty(t, "icon_only") then
        text = "<span font_desc='"..font.."'>"
        if fg_color then
            text = text .. "<span color='" .. util.ensure_pango_color(fg_color) ..
                "'>" .. (util.escape(t_name) or "") .. "</span>"
        else
            text = text .. (util.escape(t_name) or "")
        end
        text = text .. "</span>"
    end
    if not taglist_disable_icon then
        if t.icon and type(t.icon) == "image" then
            icon = t.icon
        elseif t.icon then
            icon = surface.load(t.icon)
        end
    end

    --return text, bg_color, bg_image, not taglist_disable_icon and icon or nil
    w:set_bg(bg_color)
    w:set_fg(fg_color)
    return w
end

local function tasklist_label(c, args)
    if not args then args = {} end
    local theme = beautiful.get()

    local fg_normal = util.ensure_pango_color(args.fg_normal or theme.panel_widget_bg or theme.fg_normal, "white")
    local bg_normal = args.bg_normal or theme.panel_widget_fg or theme.bg_normal or "#000000"

    local fg_focus = util.ensure_pango_color(args.fg_focus or theme.color.color3 or theme.tasklist_fg_focus or theme.fg_focus, fg_normal)
    local bg_focus = args.bg_focus or theme.taglist_bg_focus or theme.bg_focus or "#000000"

    local fg_urgent = util.ensure_pango_color(args.fg_urgent or theme.tasklist_fg_urgent or theme.fg_urgent, fg_normal)
    local bg_urgent = args.bg_urgent or theme.tasklist_bg_urgent or theme.bg_urgent or bg_normal
    local fg_minimize = util.ensure_pango_color(args.fg_minimize or theme.tasklist_fg_minimize or theme.fg_minimize, fg_normal)
    local bg_minimize = args.bg_minimize or theme.panel_widget_bg_disabled or theme.tasklist_bg_minimize or theme.bg_minimize or bg_normal
    local bg_image_normal = args.bg_image_normal or theme.bg_image_normal
    local bg_image_focus = args.bg_image_focus or theme.bg_image_focus
    local bg_image_urgent = args.bg_image_urgent or theme.bg_image_urgent
    local bg_image_minimize = args.bg_image_minimize or theme.bg_image_minimize
    local tasklist_disable_icon = args.tasklist_disable_icon or theme.tasklist_disable_icon or false
    local font = args.font or theme.font -- theme.tasklist_font or theme.font or ""
    local bg = nil
    local text = "<span font_desc='"..font.."'>"
    local name = ""
    local bg_image = nil

    local lenth_chars = 13
    local lenth_chars = 12

    if c.is_tag then
        --if c.is_separator then
            --args.is_separator = true
        --end
        --return tasklist.taglist_label(c.tag, args)
        name = c.tag.name
        name = string.format("%"..lenth_chars.."."..lenth_chars.."s", name)
        name = "<span color='"..bg_minimize.."'>"..name.."</span>"
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
        text = text .. "<span color='"..fg_focus.."'>"..name.."</span>"
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


local function tag_group(t, buttons, filter, data, update_function)
    local clients = {}
    table.insert(clients, {tag=t, is_tag=true})
    for _, c in ipairs(t:clients()) do
        --if not (c.skip_taskbar or c.hidden or c.type == "splash" or c.type == "dock" or c.type == "desktop") and filter(c, s) then
            table.insert(clients, c)
        --end
    end

    local clients_on_tag = flex.vertical()
    local function label(c) return tasklist_label(c, style) end
    update_function(clients_on_tag, buttons, label, data, clients)

    local widget = a_common.decorated({
        widget=clients_on_tag,
        min_height = dpi(100)
    })
    tasklist.taglist_label(t, widget)
    return widget
end


local v_sep_constraint = a_common.constraint({
    height=beautiful.panel_padding_bottom
})
local v_sep = wibox.container.background(
    v_sep_constraint,
    beautiful.panel_bg
)

local function tasklist_update(s, w, buttons, filter, data, style, update_function, tag_filter)
    tag_filter = tag_filter or function() return true end
    w:reset()
    for _, t in ipairs(s.tags) do
        -- @TODO: cache tag_group widgets for the tags
        if not tag.getproperty(t, "hide") and tag_filter(t) then
            w:add(tag_group(t, buttons, filter, data, update_function))
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
-- @param style The style overrides default theme.
-- @param[opt] update_function Function to create a tag widget on each
--   update. See `awful.widget.common.list_update`.
-- @tparam[opt] table base_widget Container widget for tag widgets. Default
--   is `wibox.layout.flex.horizontal`.
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
function tasklist.new(screen, filter, buttons, style, update_function, base_widget)
    local uf = update_function or common.list_update
    local w = base_widget or flex.horizontal()

    local data = setmetatable({}, { __mode = 'k' })

    local queued_update = false
    local u = function ()
        -- Add a delayed callback for the first update.
        if not queued_update then
            timer.delayed_call(function()
                queued_update = false
                tasklist_update(screen, w, buttons, filter, data, style, uf, awful.widget.taglist.filter.noempty)
            end)
            queued_update = true
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
    return w
end

--- Filtering function to include all clients.
-- @param c The client.
-- @param screen The screen we are drawing on.
-- @return true
function tasklist.filter.allscreen(c, screen)
    return true
end

--- Filtering function to include the clients from all tags on the screen.
-- @param c The client.
-- @param screen The screen we are drawing on.
-- @return true if c is on screen, false otherwise
function tasklist.filter.alltags(c, screen)
    -- Only print client on the same screen as this widget
    return c.screen == screen
end

--- Filtering function to include only the clients from currently selected tags.
-- @param c The client.
-- @param screen The screen we are drawing on.
-- @return true if c is in a selected tag on screen, false otherwise
function tasklist.filter.currenttags(c, screen)
    -- Only print client on the same screen as this widget
    if c.screen ~= screen then return false end
    -- Include sticky client too
    if c.sticky then return true end
    local tags = screen.tags
    for k, t in ipairs(tags) do
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

--- Filtering function to include only the minimized clients from currently selected tags.
-- @param c The client.
-- @param screen The screen we are drawing on.
-- @return true if c is in a selected tag on screen and is minimized, false otherwise
function tasklist.filter.minimizedcurrenttags(c, screen)
    -- Only print client on the same screen as this widget
    if c.screen ~= screen then return false end
    -- Check client is minimized
    if not c.minimized then return false end
    -- Include sticky client
    if c.sticky then return true end
    for k, t in ipairs(screen.tags) do
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

--- Filtering function to include only the currently focused client.
-- @param c The client.
-- @param screen The screen we are drawing on.
-- @return true if c is focused on screen, false otherwise
function tasklist.filter.focused(c, screen)
    -- Only print client on the same screen as this widget
    return c.screen == screen and capi.client.focus == c
end

function tasklist.mt:__call(...)
    return tasklist.new(...)
end

return setmetatable(tasklist, tasklist.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
