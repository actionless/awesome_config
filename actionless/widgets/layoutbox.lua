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

local common = require("actionless.widgets.common")

--- Layoutbox widget "class".


--- Create a layoutbox widget. It draws a picture with the current layout
-- symbol of the current tag.
-- @param screen The screen number that the layout will be represented for.
-- @return An imagebox widget configured as a layoutbox.
local function worker(args)

    local layoutbox = {
        menu = nil,
        mt = {}
    }

    local args = args or {}
    local fg = args.fg or beautiful.panel_widget_fg or beautiful.bg or "#000000"
    local bg = args.bg or beautiful.panel_widget_bg or beautiful.fg or "#ffffff"
    local text_mode = args.text_mode or true
    layoutbox.screen = args.screen or 1

    layoutbox.n_master = wibox.widget.background()
    layoutbox.n_master:set_widget(textbox())
    layoutbox.layout = wibox.widget.background()

    layoutbox.imagebox = imagebox()
    layoutbox.imagebox:set_resize(beautiful.hidpi or false)
    layoutbox.textbox = textbox()
    if text_mode then
        layoutbox.layout:set_widget(layoutbox.textbox)
    else
        layoutbox.layout:set_widget(layoutbox.imagebox)
    end

    layoutbox.n_col = wibox.widget.background()
    layoutbox.n_col:set_widget(textbox())

    args.widgets={
            layoutbox.n_master,
            wibox.widget.textbox(' '),
            layoutbox.n_col
        }
    args.left_separators = args.left_separators or {}
    args.right_separators = args.right_separators or {}

    layoutbox.numbers_layout = common.decorated_horizontal(args)

    args.widgets={
        layoutbox.layout,
        layoutbox.numbers_layout,
    }
    layoutbox.widget = common.decorated(args)

    local layouts_menu_items = {}
    for _, layout in ipairs(awful.layout.layouts) do
      table.insert(layouts_menu_items, {
        layout.name,
        function() awful.layout.set(layout) end,
        beautiful["layout_"..layout.name]
      })
    end
    local layouts_menu = awful.menu({
        items = layouts_menu_items,
    })

    layoutbox.widget:buttons(awful.util.table.join(
      awful.button({ }, 1, function ()
        layoutbox.menu = layouts_menu:toggle()
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
    end
    function layoutbox:update_nmaster(t)
        self.n_master.widget:set_text(tag.getnmaster(t))
    end
    function layoutbox:update_ncol(t)
        self.n_col.widget:set_text(tag.getncol(t))
    end
    function layoutbox:update_all(t)
        self:update_layout()
        self:update_nmaster(t)
        self:update_ncol(t)
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
    return setmetatable(layoutbox, { __index = layoutbox.widget })
end


return setmetatable({}, { __call = function(_, ...) return worker(...) end })

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
