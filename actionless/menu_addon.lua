--------------------------------------------------------------------------------
-- @author Yauheni Kirylau &lt;actionless.loveless@gmail.com&gt;
-- @copyright 2013-2014 Yauheni Kirylau
--------------------------------------------------------------------------------

local menu = require("awful.menu")
local escape_f = require("gears.string").xml_escape
local awful_screen = require("awful.screen")

local table_add = require("actionless.util.table").add


local menu_addon = { mt={} }


function menu_addon.clients_on_tag(args, item_args)
  local cls_t = {}

  local selected_tags = awful_screen.focused().selected_tags
  for _, t in ipairs(selected_tags) do
    local clients_on_tag = t.clients(t)
    for _, c in ipairs(clients_on_tag) do
      table.insert(cls_t, {
        escape_f(c.name) or "",
        function ()
          client.focus = c
          c:raise()
        end,
        c.icon
      })
      if item_args then
        if type(item_args) == "function" then
          table_add(cls_t[#cls_t], item_args(c))
        else
          table_add(cls_t[#cls_t], item_args)
        end
      end
    end
  end
  args = args or {}
  args.items = args.items or {}
  table_add(args.items, cls_t)

  local m = menu.new(args)
  m:show(args)
  return m
end

--------------------------------------------------------------------------------

local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi
local gstring = require("gears.string")
local surface = require("gears.surface")
local cairo = require("lgi").cairo

local table_update = function (t, set)
    for k, v in pairs(set) do
        t[k] = v
    end
    return t
end

--- Default awful.menu.entry constructor.
-- @param parent The parent menu (TODO: This is apparently unused)
-- @param args the item params
-- @return table with 'widget', 'cmd', 'akey' and all the properties the user wants to change
-- @constructorfct awful.menu.entry
function menu_addon.menu_entry(parent, args) -- luacheck: no unused args
    local icon_padding = dpi(3)
    args = args or {}
    args.text = args[1] or args.text or ""
    args.cmd = args[2] or args.cmd
    args.icon = args[3] or args.icon
    local ret = {}
    -- Create the item label widget
    local label = wibox.widget.textbox()
    local key = ''
    label:set_font(args.theme.font)
    label:set_markup(string.gsub(
        gstring.xml_escape(args.text), "&amp;(%w)",
        function (l)
            key = string.lower(l)
            return "<u>" .. l .. "</u>"
        end, 1))
    -- Set icon if needed
    local icon, iconbox
    local margin = wibox.container.margin()
    margin:set_widget(label)
    if args.icon then
        icon = surface.load(args.icon)
    end
    if icon then
        local iw = icon:get_width() + icon_padding
        local ih = icon:get_height() + icon_padding
        if iw > args.theme.width or ih > args.theme.height then
            local w, h
            if ((args.theme.height / ih) * iw) > args.theme.width then
                w, h = args.theme.height, (args.theme.height / iw) * ih
            else
                w, h = (args.theme.height / ih) * iw, args.theme.height
            end
            -- We need to scale the image to size w x h
            local img = cairo.ImageSurface(cairo.Format.ARGB32, w, h)
            local cr = cairo.Context(img)
            cr:scale(w / iw, h / ih)
            cr:set_source_surface(icon, 0, 0)
            cr:paint()
            icon = img
        end
        iconbox = wibox.widget.imagebox()
        if iconbox:set_image(icon) then
            margin:set_left(not icon_padding and dpi(2) or 0)
        else
            iconbox = nil
        end
    end
    if not iconbox then
        margin:set_left(args.theme.height + (not icon_padding and dpi(2) or 0))
    end
    -- Create the submenu icon widget
    local submenu
    if type(args.cmd) == "table" then
        if args.theme.submenu_icon then
            submenu = wibox.widget.imagebox()
            submenu:set_image(args.theme.submenu_icon)
        else
            submenu = wibox.widget.textbox()
            submenu:set_font(args.theme.font)
            submenu:set_text(args.theme.submenu)
        end
    end
    -- Add widgets to the wibox
    local left = wibox.layout.fixed.horizontal()
    if iconbox then
        local icon_margin = iconbox
        if icon_padding then
            icon_margin = wibox.container.margin()
            icon_margin:set_widget(iconbox)
            --icon_margin.margins = icon_padding
            icon_margin:set_top(icon_padding + dpi(1))
            icon_margin:set_bottom(icon_padding - dpi(1))
            icon_margin:set_left(icon_padding + dpi(1))
            icon_margin:set_right(icon_padding - dpi(1))
        end
        left:add(icon_margin)
    end
    -- This contains the label
    left:add(margin)

    local layout = wibox.layout.align.horizontal()
    layout:set_left(left)
    if submenu then
        layout:set_right(submenu)
    end

    return table_update(ret, {
        label = label,
        sep = submenu,
        icon = iconbox,
        widget = layout,
        cmd = args.cmd,
        akey = key,
    })
end
--------------------------------------------------------------------------------


function menu_addon.mt:__call(...)
  return self.new(...)
end

return setmetatable(menu_addon, menu)
