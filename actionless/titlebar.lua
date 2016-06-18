--[[
Licensed under GNU General Public License v2
* (c) 2014-2016  Yauheni Kirylau
--]]

local awful = require("awful")
local client = client
local wibox = require("wibox")
local beautiful = require("beautiful")



local titlebar = { }

local function get_buttons(c)
  return awful.util.table.join(
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
end

function titlebar.remove_titlebar(c)
  if not titlebar.is_enabled(c) then
    return
  end
  local tb = awful.titlebar(c,{size= beautiful.base_border_width or 5, position="top"})
  tb:setup {
    buttons = get_buttons(c),
    id     = "main_layout",
    layout = wibox.container.background,
  }
end

function titlebar.remove_border(c)
  if not (titlebar.border_is_enabled(c) or titlebar.is_enabled(c)) then
    return
  end
  for _, position in ipairs({"top", "bottom", "top", "left"}) do
    awful.titlebar.hide(c, position)
  end
end

function titlebar.make_border(c)
  if titlebar.is_enabled(c) then
    return titlebar.remove_titlebar(c)
  end

  if titlebar.border_is_enabled(c) then
    return
  end
  --c.border_width = 0
  --c.border_color = beautiful.border_normal

  --               Top titlebar                --
  local tbt = awful.titlebar(c,{size= beautiful.base_border_width or 5, position="top"})
  tbt:setup {
    buttons = get_buttons(c),
    id     = "main_layout",
    layout = wibox.container.background,
  }

  --               Bottom titlebar                --
  local tbb = awful.titlebar(c,{size= beautiful.titlebar_bottom_height or 5,position="bottom"})
  tbb:setup {
    buttons = get_buttons(c),
    id     = "main_layout",
    layout = wibox.container.background,
  }

  --               Left titlebar                --
  local tbl = awful.titlebar(c,{size= beautiful.titlebar_left_width or 5,position="left"})
  tbl:setup {
    buttons = get_buttons(c),
    wibox.widget.textbox(" "),
    --bg        = beautiful.titlebar_bg_left or beautiful.titlebar_bg_sides or beautiful.fg_normal,
    bgimage   = beautiful.titlebar_bgimage_left,
    widget    = wibox.container.background
  }

  --               Right titlebar                --
  local tbr = awful.titlebar(c,{size= beautiful.titlebar_right_width or 5,position="right"})
  tbr:setup {
    buttons = get_buttons(c),
    wibox.widget.textbox(" "),
    --bg        = beautiful.titlebar_bg_left or beautiful.titlebar_bg_sides or beautiful.fg_normal,
    bgimage   = beautiful.titlebar_bgimage_right,
    widget    = wibox.container.background
  }
end

function titlebar.make_titlebar(c)
  if titlebar.is_enabled(c) then
    return
  end

  if not titlebar.border_is_enabled(c) then
    titlebar.make_border(c)
  end

  --c.border_color = beautiful.titlebar_focus_border
  -- buttons for the titlebar
  --------------------------------------------------
  --               Top titlebar                   --
  --------------------------------------------------
  local tbt =  awful.titlebar(
    c,
    { size=beautiful.titlebar_height or 16,
      position = beautiful.titlebar_position,
      opacity = beautiful.titlebar_opacity }
  )
  tbt:setup{
    {
      {
        awful.titlebar.widget.closebutton(c),
        awful.titlebar.widget.minimizebutton(c),
        --awful.titlebar.widget.maximizedbutton(c)),
        layout = wibox.layout.fixed.horizontal,
      },
      {
        {
          widget = awful.titlebar.widget.titlewidget(c),
          align = "center",
          font = beautiful.titlebar_font,
        },
        layout = wibox.layout.flex.horizontal,
        buttons = get_buttons(c),
      },
      {
        awful.titlebar.widget.ontopbutton(c),
        awful.titlebar.widget.stickybutton(c),
        layout = wibox.layout.fixed.horizontal,
      },
      layout = wibox.layout.align.horizontal,
    },
    left   = beautiful.base_border_width,
    right   = beautiful.base_border_width,
    top   = beautiful.base_border_width,
    --bottom   = beautiful.base_border_width,
    layout = wibox.container.margin,
  }



  --c.skip_taskbar = true
end


function titlebar.is_enabled(c)
  if (
    c["titlebar_" .. (beautiful.titlebar_position or 'top')
      ](c):geometry()['height'] > beautiful.base_border_width
    ) then
    return true
  else
    return false
  end
end

function titlebar.border_is_enabled(c)
  if (
    c["titlebar_" .. beautiful.titlebar_position or 'top'
      ](c):geometry()['height'] == beautiful.base_border_width
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
