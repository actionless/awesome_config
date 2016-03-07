--[[
     Licensed under GNU General Public License v2
      * (c) 2014  Yauheni Kirylau
--]]

local awful = require("awful")
local client = client
local wibox = require("wibox")
local beautiful = require("beautiful")


local titlebar = {}

function titlebar.remove_titlebar(c)
  if titlebar.is_enabled(c) then
    awful.titlebar.hide(c, beautiful.titlebar_position)
    c.skip_taskbar = false
  end
end

function titlebar.remove_border(c)
  titlebar.remove_titlebar(c)
  c.border_width = 0
  --c.border_color = beautiful.border_normal
end

function titlebar.make_titlebar(c)
  if titlebar.is_enabled(c) then
    return
  end
  c.border_color = beautiful.titlebar_focus_border
  -- buttons for the titlebar
  local buttons = awful.util.table.join(
    awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
    end),
    awful.button({ }, 2, function()
            client.focus = c
            c:raise()
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
    end),
    awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
    end)
    )

  awful.titlebar(
    c,
    { size=beautiful.titlebar_height or 16,
      position = beautiful.titlebar_position,
      opacity = beautiful.titlebar_opacity }
  ):setup{
    {
      awful.titlebar.widget.ontopbutton(c),
      awful.titlebar.widget.stickybutton(c),
      layout = wibox.layout.fixed.horizontal,
    },
    {
      {
        widget = awful.titlebar.widget.titlewidget(c),
        align = "center",
        font = beautiful.titlebar_font,
      },
      layout = wibox.layout.flex.horizontal,
      buttons = buttons,
    },
    {
      awful.titlebar.widget.closebutton(c),
      awful.titlebar.widget.minimizebutton(c),
      --awful.titlebar.widget.maximizedbutton(c)),
      layout = wibox.layout.fixed.horizontal,
    },
    layout = wibox.layout.align.horizontal,
  }

  c.skip_taskbar = true
end


function titlebar.is_enabled(c)
  if (
    c["titlebar_" .. beautiful.titlebar_position or 'top'
    ](c):geometry()['height'] > 0
  ) then
    return true
  else
    return false
  end
end

function titlebar.titlebar_toggle(c)
  if titlebar.is_enabled(c) then
    titlebar.remove_titlebar(c)
  else
    titlebar.remove_titlebar(c)
    titlebar.make_titlebar(c)
  end
end


return titlebar
