---------------------------------------------------------------------------
-- @ 2013-2019 Yauhen Kirylau
---------------------------------------------------------------------------


local awful = require("awful")
local tag = require("awful.tag")
local beautiful = require("beautiful")
local wibox = require("wibox")
local imagebox = require("wibox.widget.imagebox")
local textbox = require("wibox.widget.textbox")
local delayed_call = require("gears.timer").delayed_call
local g_string = require('gears.string')

local tag_helpers = require("actionless.util.tag")
local common = require("actionless.widgets.common")

--- Layoutbox widget "class".


--- Create a layoutbox widget. It draws a picture with the current layout
-- symbol of the current tag.
-- @param screen The screen object that the layout will be represented for.
-- @return An imagebox widget configured as a layoutbox.
local function create_widget(args)

    local layoutbox = {
        menu = nil,
        menu_id = nil,
        mt = {}
    }

    args = args or {}
    layoutbox.screen = args.screen or awful.screen.focused()

    layoutbox.layout_icon = wibox.container.background()
    layoutbox.imagebox = imagebox()
    layoutbox.imagebox:set_resize(true)
    layoutbox.mfpol_icon = imagebox()
    layoutbox.mfpol_icon:set_resize(true)
    layoutbox.mfpol_icon.forced_height = beautiful.basic_panel_height
    layoutbox.mfpol_icon.forced_width = beautiful.basic_panel_height
    layoutbox.textbox = textbox()
    if args.horizontal then
        layoutbox.layout_icon:set_widget(layoutbox.imagebox)
    else
        layoutbox.layout_icon:set_widget(layoutbox.textbox)
    end
    --layoutbox.mfpol_names = args.mfpol_names or {
    --    expand='←→',
    --    master_width_factor='→←',
    --    empty='  ',
    --}

    layoutbox.n_master = wibox.container.background()
    layoutbox.n_master:set_widget(textbox())

    layoutbox.n_col = wibox.container.background()
    layoutbox.n_col:set_widget(textbox())

    layoutbox.widget = wibox.layout.fixed.horizontal(
        layoutbox.layout_icon,
        common.constraint({width=math.ceil(beautiful.panel_widget_spacing)}),
        layoutbox.n_master,
        common.constraint({width=math.ceil(beautiful.panel_widget_spacing)}),
        layoutbox.n_col,
        layoutbox.mfpol_icon
    )
    --layoutbox.widget.spacing = math.ceil(beautiful.panel_widget_spacing/2)

    local layouts_menu_items = {}
    for _, layout in ipairs(awful.layout.layouts) do
      table.insert(layouts_menu_items, {
        layout.name,
        function()
            awful.layout.set(layout, layoutbox.screen.selected_tag)
        end,
        beautiful["layout_"..layout.name]
      })
    end
    layoutbox.menu = awful.menu({
        items = layouts_menu_items,
    })

    layoutbox.widget:buttons(awful.util.table.join(
      awful.button({ }, 1, function ()
        layoutbox.menu_id = layoutbox.menu:toggle()
      end),
      awful.button({ }, 3, function ()
        awful.layout.inc(1) end),
      awful.button({ }, 5, function ()
        awful.layout.inc(1) end),
      awful.button({ }, 4, function ()
        awful.layout.inc(-1) end)
    ))


    function layoutbox:update_layout()
        local layout = awful.layout.getname(awful.layout.get(self.screen))
        self.imagebox:set_image(layout and beautiful["layout_" .. layout])
        self.textbox:set_text(layout)
        self.layout_name = layout
    end
    function layoutbox:update_nmaster(t)
        delayed_call(function()
            t = t or awful.screen.focused().selected_tag
            if self.layout_name == awful.layout.suit.floating.name then
                self.n_master.widget:set_text(" ")
            else
                self.n_master.widget:set_text(t.master_count)
            end
        end)
    end
    function layoutbox:update_ncol(t)
        delayed_call(function()
            t = t or awful.screen.focused().selected_tag
            local num_tiled = #tag_helpers.get_tiled(t)
            if self.layout_name == awful.layout.suit.floating.name then
                self.n_col.widget:set_text('')
                self.n_col.widget.forced_width = beautiful.basic_panel_height
                self.mfpol_icon.forced_width = 0
                --self.n_col.widget:set_text(
                --    self.mfpol_names.empty
                --)
            else
                if num_tiled <= t.master_count then return end
                self.n_col.widget:set_text(
                    string.format("%2.d", t.column_count)
                )
                self.n_col.widget.forced_width = beautiful.basic_panel_height
                self.mfpol_icon.forced_width = 0
            end
        end)
    end
    function layoutbox:update_mfpol(t)
        delayed_call(function()
            t = t or awful.screen.focused().selected_tag
            local num_tiled = #tag_helpers.get_tiled(t)
            if num_tiled > 1 then return end
            if g_string.startswith(self.layout_name, 'tile') or
                g_string.startswith(self.layout_name, 'corner')
            then
                self.mfpol_icon:set_image(beautiful.get()['icon_layout_'..t.master_fill_policy])
                self.n_col.widget.forced_width = 0
                self.mfpol_icon.forced_width = beautiful.basic_panel_height
                self.n_col.widget:set_text('')
                --self.n_col.widget:set_markup(
                --    self.mfpol_names[t.master_fill_policy]
                --)
            end
        end)
    end
    function layoutbox:update_all(t)
        self:update_layout()
        self:update_nmaster(t)
        self:update_ncol(t)
        self:update_mfpol(t)
    end

    -- init:
    layoutbox:update_all(nil)

    tag.attached_connect_signal(
        layoutbox.screen, "property::selected",
        function(t) layoutbox:update_all(t) end)
    tag.attached_connect_signal(
        layoutbox.screen, "property::layout",
        function(_) layoutbox:update_layout() end)
    tag.attached_connect_signal(
        layoutbox.screen, "property::ncol",
        function(t) layoutbox:update_ncol(t) end)
    tag.attached_connect_signal(
        layoutbox.screen, "property::nmaster",
        function(t) layoutbox:update_nmaster(t) end)
    tag.attached_connect_signal(
        layoutbox.screen, "property::master_fill_policy",
        function(t) layoutbox:update_mfpol(t) end)
    tag.attached_connect_signal(
        layoutbox.screen, "tagged",
        function(t)
            if t ~= awful.screen.focused().selected_tag then return end
            layoutbox:update_ncol(t)
            layoutbox:update_mfpol(t)
        end)
    tag.attached_connect_signal(
        layoutbox.screen, "untagged",
        function(t)
            if t ~= awful.screen.focused().selected_tag then return end
            layoutbox:update_ncol(t)
            layoutbox:update_mfpol(t)
        end)

    return setmetatable(layoutbox, { __index = layoutbox.widget })
end


return setmetatable({}, { __call = function(_, ...) return create_widget(...) end })

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
