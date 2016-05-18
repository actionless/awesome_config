---------------------------------------------------------------------------
--- Menubar module, which aims to provide a freedesktop menu alternative
--
-- List of menubar keybindings:
-- ---
--
--  *  "Left"  | "C-j" select an item on the left
--  *  "Right" | "C-k" select an item on the right
--  *  "Backspace"     exit the current category if we are in any
--  *  "Escape"        exit the current directory or exit menubar
--  *  "Home"          select the first item
--  *  "End"           select the last
--  *  "Return"        execute the entry
--  *  "C-Return"      execute the command with awful.util.spawn
--  *  "C-M-Return"    execute the command in a terminal
--
-- @author Alexander Yakushev &lt;yakushev.alex@gmail.com&gt;
-- @copyright 2011-2012 Alexander Yakushev
-- @release v3.5.2-602-g4996334
-- @module menubar
---------------------------------------------------------------------------

-- Grab environment we need
local capi = {
    client = client,
    mouse = mouse,
    screen = screen
}
local awful = require("awful")
local common = require("awful.widget.common")
local theme = require("beautiful")
local wibox = require("wibox")

-- menubar
local menubar_module = { mt = {} }
menubar_module.menu_gen = require("actionless.menubar.menu_gen")
menubar_module.utils = require("actionless.menubar.utils")
menubar_module.dmenugen = require("actionless.menubar.dmenugen")
local compute_text_width = menubar_module.utils.compute_text_width


-- Options section

--- When true the .desktop files will be reparsed only when the
-- extension is initialized. Use this if menubar takes much time to
-- open.
menubar_module.cache_entries = true

--- When true the categories will be shown alongside application
-- entries.
menubar_module.show_categories = true

--- Specifies the geometry of the menubar. This is a table with the keys
-- x, y, width and height. Missing values are replaced via the screen's
-- geometry. However, missing height is replaced by the font size.
menubar_module.geometry = { width = nil,
                     height = nil,
                     x = nil,
                     y = nil }

menubar_module.position = "bottom"

--- Width of blank space left in the right side.
menubar_module.right_margin = 50

--- Label used for "Next page", default "▶▶".
menubar_module.right_label = "▶▶"

--- Label used for "Previous page", default "◀◀".
menubar_module.left_label = "◀◀"

--- Allows user to specify custom parameters for prompt.run function
-- (like colors).
menubar_module.prompt_args = {}


--- Create new menubar instance
function menubar_module.create(...)
    local args = ... or {}
    local mm = menubar_module

    --local menubar = {mt = {}, menu_entries = {}}
    local menubar = {}
    menubar.menu_entries = {}
    menubar.menu_gen = menubar_module.menu_gen
    menubar.cache_entries = args.cache_entries or menubar_module.cache_entries
    menubar.show_categories = args.show_categories or menubar_module.show_categories
    menubar.geometry = args.geometry or menubar_module.geometry
    menubar.position = args.position or menubar_module.position
    menubar.right_margin = args.right_margin or menubar_module.right_margin
    menubar.right_label = args.right_label or menubar_module.right_label
    menubar.left_label = args.left_label or menubar_module.left_label

    menubar.term_prefix = args.term_prefix or menubar_module.utils.terminal .. " -e "


menubar.menu_cache_path = awful.util.getdir("cache") .. "/history_menu"

-- Private section
local current_item = 1
local previous_item = nil
local current_category = nil
local shownitems = nil
menubar.instance = { prompt = nil,
                   widget = nil,
                   wibox = nil }

local common_args = { w = wibox.layout.fixed.horizontal(),
                      data = setmetatable({}, { __mode = 'kv' }) }

--- Wrap the text with the color span tag.
-- @param s The text.
-- @param c The desired text color.
-- @return the text wrapped in a span tag.
local function colortext(s, c)
    return "<span color='" .. awful.util.ensure_pango_color(c) .. "'>" .. s .. "</span>"
end

--- Get how the menu item should be displayed.
-- @param o The menu item.
-- @return item name, item background color, background image, item icon.
local function label(o)
    if o.focused then
        return colortext(o.name, theme.fg_focus), theme.bg_focus, nil, o.icon
    else
        return o.name, theme.bg_normal, nil, o.icon
    end
end

--- Perform an action for the given menu item.
-- @param o The menu item.
-- @return if the function processed the callback, new awful.prompt command, new awful.prompt prompt text.
local function perform_action(o)
    if not o then return end
    if o.key then
        current_category = o.key
        local new_prompt = shownitems[current_item].name .. ": "
        previous_item = current_item
        current_item = 1
        return true, "", new_prompt
    elseif shownitems[current_item].cmdline then
        -- @TODO: remove it:
        if menubar.menu_gen == menubar_module.dmenugen then
            menubar_module.dmenugen.add_history_record(shownitems[current_item].cmdline)
            menubar_module.dmenugen.history_save()
        end
        ----------
        local command = shownitems[current_item].cmdline
        command = command:gsub("^TERM:", menubar.term_prefix)
        awful.spawn.spawn(command)
        -- Let awful.prompt execute dummy exec_callback and
        -- done_callback to stop the keygrabber properly.
        return false
    end
end

--- Cut item list to return only current page.
-- @tparam table all_items All items list.
-- @tparam str query Search query.
-- @return table List of items for current page.
function menubar:get_current_page(all_items, query, scr)
    if not self.instance.prompt.width then
        self.instance.prompt.width = compute_text_width(self.instance.prompt.prompt, scr)
    end
    if not self.left_label_width then
        self.left_label_width = compute_text_width(self.left_label, scr)
    end
    if not self.right_label_width then
        self.right_label_width = compute_text_width(self.right_label, scr)
    end
    local available_space = self.instance.geometry.width - self.right_margin -
        self.right_label_width - self.left_label_width -
        compute_text_width(query, scr) - self.instance.prompt.width

    local width_sum = 0
    local current_page = {}
    for i, item in ipairs(all_items) do
        item.width = item.width or
            compute_text_width(" " .. item.name, scr) +
            (item.icon and self.instance.geometry.height or 0)
        if width_sum + item.width > available_space then
            if current_item < i then
                table.insert(current_page, { name = self.right_label, icon = nil })
                break
            end
            current_page = { { name = self.left_label, icon = nil }, item, }
            width_sum = item.width
        else
            table.insert(current_page, item)
            width_sum = width_sum + item.width
        end
    end
    return current_page
end

--- Update the menubar according to the command entered by user.
-- @tparam str query Search query.
function menubar:menulist_update(query, scr)
    query = query or ""
    shownitems = {}
    local pattern = awful.util.query_to_pattern(query)
    local match_inside = {}

    -- First we add entries which names match the command from the
    -- beginning to the table shownitems, and the ones that contain
    -- command in the middle to the table match_inside.

    -- Add the categories
    if self.show_categories then
        for _, v in pairs(self.menu_gen.all_categories) do
            v.focused = false
            if not current_category and v.use then
                if string.match(v.name, pattern) then
                    if string.match(v.name, "^" .. pattern) then
                        table.insert(shownitems, v)
                    else
                        table.insert(match_inside, v)
                    end
                end
            end
        end
    end

    -- Add the applications according to their name and cmdline
    for i, v in ipairs(self.menu_entries) do
        v.focused = false
        if not current_category or v.category == current_category then
            if string.match(v.name, pattern)
                or string.match(v.cmdline, pattern) then
                if string.match(v.name, "^" .. pattern)
                    or string.match(v.cmdline, "^" .. pattern) then
                    table.insert(shownitems, v)
                else
                    table.insert(match_inside, v)
                end
            end
        end
    end

    -- Now add items from match_inside to shownitems
    for i, v in ipairs(match_inside) do
        table.insert(shownitems, v)
    end

    --if #shownitems > 0 then
        -- Insert a run item value as the last choice
        table.insert(shownitems, { name = "Exec: " .. query, cmdline = query, icon = nil })

        if current_item > #shownitems then
            current_item = #shownitems
        end
        shownitems[current_item].focused = true
    --else
        --table.insert(shownitems, { name = "", cmdline = query, icon = nil })
    --end

    common.list_update(common_args.w, nil, label,
                       common_args.data,
                       self:get_current_page(shownitems, query, scr))
end

--- Create the menubar wibox and widgets.
function menubar:initialize()
    self.instance.wibox = wibox({
        ontop = true
    })
    self.instance.widget = menubar:get()
    self.instance.prompt = awful.widget.prompt()
    local layout = wibox.layout.fixed.horizontal()
    layout:add(self.instance.prompt)
    layout:add(self.instance.widget)
    self.instance.wibox:set_widget(layout)
end

--- Refresh menubar's cache by reloading .desktop files.
function menubar:refresh()
    self.menu_entries = self.menu_gen.generate()
end

--- Awful.prompt keypressed callback to be used when the user presses a key.
-- @param mod Table of key combination modifiers (Control, Shift).
-- @param key The key that was pressed.
-- @param comm The current command in the prompt.
-- @return if the function processed the callback, new awful.prompt command, new awful.prompt prompt text.
local function prompt_keypressed_callback(mod, key, comm)
    if key == "Left" or (mod.Control and key == "j") then
        current_item = math.max(current_item - 1, 1)
        return true
    elseif key == "Right" or (mod.Control and key == "k") then
        current_item = current_item + 1
        return true
    elseif key == "BackSpace" then
        if comm == "" and current_category then
            current_category = nil
            current_item = previous_item
            return true, nil, "Run: "
        end
    elseif key == "Escape" then
        if current_category then
            current_category = nil
            current_item = previous_item
            return true, nil, "Run: "
        end
    elseif key == "Home" then
        current_item = 1
        return true
    elseif key == "End" then
        current_item = #shownitems
        return true
    elseif key == "Delete" then
        menubar_module.dmenugen.remove_history_record(
            shownitems[current_item].cmdline
        )
        menubar_module.dmenugen.history_save()
        menubar_module.dmenugen.history_check_load()
        menubar:refresh()
        return true
    elseif key == "space" and mod.Control then
        -- add to the cmdline
        nlog(current_item)
        local focused_item_number = current_item
        current_item = #shownitems
        return true, shownitems[focused_item_number].name
    elseif key == "Return" or key == "KP_Enter" then
        if mod.Mod1 then
            -- run command with terminal
            shownitems[current_item].cmdline = "TERM:"
                    .. shownitems[current_item].cmdline
        end
        return perform_action(shownitems[current_item])
    end
    return false
end

--- Show the menubar on the given screen.
-- @param scr Screen number.
function menubar:show(scr)
    scr = scr or awful.screen.focused() or 1

    if not self.instance.wibox then
        self:initialize(scr)
    elseif self.instance.wibox.visible then -- Menu already shown, exit
        return
    elseif not self.cache_entries then
        self:refresh()
    end

    -- Set position and size
    local scrgeom = capi.screen[scr].workarea
    local geometry = self.geometry
    self.instance.geometry = {x = scrgeom.x,
                             y = scrgeom.y,
                             height = math.floor(theme.get_font_height() * 1.5),
                             width = scrgeom.width}
    self.instance.wibox:geometry(self.instance.geometry)
    awful.placement[self.position](self.instance.wibox)

    current_item = 1
    current_category = nil
    self:menulist_update(nil, scr)

    local prompt_args = self.prompt_args or {}
    prompt_args.prompt = "Run: "
    awful.prompt.run(prompt_args, self.instance.prompt.widget,
                function(s) end,            -- exe_callback function set to do nothing
                awful.completion.shell,     -- completion_callback
                menubar.menu_cache_path,
                nil,
                function() return self:hide() end,
                function(query) return self:menulist_update(query, scr) end,
                prompt_keypressed_callback
                )
    self.instance.wibox.visible = true
end

--- Hide the menubar.
function menubar:hide()
    self.instance.wibox.visible = false
end

--- Get a menubar wibox.
-- @return menubar wibox.
function menubar:get()
    menubar:refresh()
    -- Add to each category the name of its key in all_categories
    for k, v in pairs(self.menu_gen.all_categories) do
        v.key = k
    end
    return common_args.w
end

menubar.__index = menubar

return menubar
end -- 
------------------------------------------------------------------------------
-- menubar.create end
------------------------------------------------------------------------------


--- Compatibility layer with the previous API:
local fallback_menubar_instance
local function mb()
    if not fallback_menubar_instance then
        fallback_menubar_instance = menubar_module.create()
    end
    return fallback_menubar_instance
end
menubar_module.refresh = function(...) mb():refresh(...) end
menubar_module.show = function(...) mb():show(...) end
menubar_module.hide = function(...) mb():hide(...) end
menubar_module.get = function(...) mb():get(...) end
function menubar_module.mt:__call(...) return mb().get(...) end

return setmetatable(menubar_module, menubar_module.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
