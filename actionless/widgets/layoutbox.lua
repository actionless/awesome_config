---------------------------------------------------------------------------
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2009 Julien Danjou
-- @release v3.5.5
-- @ 2013-2014 Yauhen Kirylau
---------------------------------------------------------------------------


local awful = require("awful")
local tag = require("awful.tag")
local beautiful = require("beautiful")
local wibox = require("wibox")
local imagebox = require("wibox.widget.imagebox")
local textbox = require("wibox.widget.textbox")

local h_string = require("utils.string")
local common = require("actionless.widgets.common")
local db = require("utils.db")

--- Layoutbox widget "class".


--- Create a layoutbox widget. It draws a picture with the current layout
-- symbol of the current tag.
-- @param screen The screen number that the layout will be represented for.
-- @return An imagebox widget configured as a layoutbox.
local function worker(args)

    local layoutbox = {
        menu = nil,
        menu_id = nil,
        mt = {}
    }

    local args = args or {}
    local fg = args.fg or beautiful.panel_widget_fg or beautiful.bg or "#000000"
    local bg = args.bg or beautiful.panel_widget_bg or beautiful.fg or "#ffffff"
    local text_mode = args.text_mode or true
    layoutbox.screen = args.screen or 1

    layoutbox.layout_icon = wibox.widget.background()
    layoutbox.imagebox = imagebox()
    layoutbox.imagebox:set_resize(true)
    layoutbox.textbox = textbox()
    if args.horizontal then
        layoutbox.layout_icon:set_widget(layoutbox.imagebox)
        layoutbox.mfpol_template = "%1.1s"
    else
        layoutbox.layout_icon:set_widget(layoutbox.textbox)
        layoutbox.mfpol_template = "%s"
    end

    layoutbox.n_master = wibox.widget.background()
    layoutbox.n_master:set_widget(textbox())

    layoutbox.n_col = wibox.widget.background()
    layoutbox.n_col:set_widget(textbox())

    layoutbox.mfpol = wibox.widget.background()
    layoutbox.mfpol:set_widget(textbox())

    args.widgets={
            layoutbox.n_master,
            layoutbox.n_col,
        }
    args.left_separators = args.left_separators or {}
    args.right_separators = args.right_separators or {}

    layoutbox.numbers_layout = common.decorated_horizontal(args)

    args.widgets={
        layoutbox.layout_icon,
        layoutbox.numbers_layout,
        layoutbox.mfpol,
    }
    layoutbox.widget = common.decorated(args)

    local layouts_menu_items = {}
    for layout_id, layout in ipairs(awful.layout.layouts) do
      table.insert(layouts_menu_items, {
        layout.name,
        function()
            awful.layout.set(layout)
            local db_id = "tag_layout_ids_"..layoutbox.screen
            local layout_ids = db.get(db_id)
            local tag_id = awful.tag.getidx(awful.tag.selected(s))
            layout_ids[tag_id] = layout_id
            db.set(db_id, layout_ids)
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
        self.n_master.widget:set_text(tag.getnmaster(t))
    end
    function layoutbox:update_ncol(t)
        self.n_col.widget:set_text(tag.getncol(t))
    end
    function layoutbox:update_mfpol(t)
        if h_string.starts(self.layout_name, 'tile') or
            h_string.starts(self.layout_name, 'corner')
        then
            self.mfpol.widget:set_text(
                string.format(self.mfpol_template, tag.getmfpol(t))
            )
        else
            self.mfpol.widget:set_text(" ")
        end
    end
    function layoutbox:update_all(t)
        self:update_layout()
        self:update_nmaster(t)
        self:update_ncol(t)
        self:update_mfpol(t)
    end

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
    return setmetatable(layoutbox, { __index = layoutbox.widget })
end


return setmetatable({}, { __call = function(_, ...) return worker(...) end })

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
