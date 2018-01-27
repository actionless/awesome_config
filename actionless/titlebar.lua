--[[
Licensed under GNU General Public License v2
* (c) 2014-2016  Yauheni Kirylau
--]]

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears_timer = require("gears.timer")

local color_utils = require("actionless.util.color")

--
local TRANSPARENT = "#00000000"


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
      c.maximized = not c.maximized
    end),
    awful.button({ }, 3, function()
      client.focus = c
      c:raise()
      awful.mouse.client.resize(c)
    end)
  )
end


local function mouse_is_on_borders(c)
  if c ~= mouse.current_client then
    return
  end
  local client_geometry = mouse.object_under_pointer():geometry()
  local border = beautiful.base_border_width
  local mouse_coords = mouse.coords()

  local mx = mouse_coords.x
  local left_border_min = client_geometry.x
  local left_border_max = client_geometry.x + border
  local right_border_min = client_geometry.x + client_geometry.width - border
  local right_border_max = client_geometry.x + client_geometry.width

  local my = mouse_coords.y
  local top_border_min = client_geometry.y
  local top_border_max = client_geometry.y + border
  local bottom_border_min = client_geometry.y + client_geometry.height - border
  local bottom_border_max = client_geometry.y + client_geometry.height

  if not (
    (
      ((mx >= left_border_min) and (mx <= left_border_max)) or
      ((mx >= right_border_min) and (mx <= right_border_max))
    ) or (
      ((my >= top_border_min) and (my <= top_border_max)) or
      ((my >= bottom_border_min) and (my <= bottom_border_max))
    )
  ) then
    return
  end
  return true
end


local function set_client_border_color(c)
  if c == client.focus then
    c.border_color = beautiful.border_focus
  else
    c.border_color = beautiful.border_normal
  end
end


local function set_client_hover_border_color(c)
  if c == client.focus then
    if color_utils.is_dark(beautiful.border_focus) then
      c.border_color = color_utils.darker(beautiful.border_focus, -45)
    else
      c.border_color = color_utils.darker(beautiful.border_focus, 45)
    end
  else
    if color_utils.is_dark(beautiful.border_normal) then
      c.border_color = color_utils.darker(beautiful.border_normal, -40)
    else
      c.border_color = color_utils.darker(beautiful.border_normal, 40)
    end
  end
end


local function attach_highlight_on_hover(titlebar_widget, c)
  titlebar_widget:connect_signal("mouse::enter", function(_)
    local timer
    timer = gears_timer({
      timeout = 0.15,
      autostart = true,
      callback = function()
        timer:stop()
        if not mouse_is_on_borders(c) then
          return
        end
        set_client_hover_border_color(c)
        local unfocus_timer
        unfocus_timer = gears_timer({
          timeout = 0.1,
          autostart = true,
          callback = function()
            unfocus_timer:stop()
            if not mouse_is_on_borders(c) then
              set_client_border_color(c)
            end
          end
        })
      end,
    })
  end)
  titlebar_widget:connect_signal("mouse::leave", function(_)
    set_client_border_color(c)
  end)
end

function titlebar.remove_titlebar(c)
  if not titlebar.is_enabled(c) then
    return
  end
  local geom = c:geometry()
  local tb = awful.titlebar(c, {
    size = beautiful.base_border_width or 5,
    position="top"
  })
  tb:setup {
    buttons = get_buttons(c),
    id     = "main_layout",
    layout = wibox.container.background,
  }
  c:geometry(geom)
end

function titlebar.remove_border(c)
  if not (titlebar.border_is_enabled(c) or titlebar.is_enabled(c)) then
    return
  end
  local geom = c:geometry()
  for _, position in ipairs({"top", "bottom", "right", "left"}) do
    awful.titlebar.hide(c, position)
  end
  c:geometry(geom)
end

local function make_border_with_shadow(c, color, shadow, is_titlebar)
  local SHADOW = shadow

  --               Top border                --
  local tbt
  if not is_titlebar then
    tbt = awful.titlebar(c, {
      size = beautiful.base_border_width or 5,
      position="top"
    })
    tbt:setup {
        {
          nil,
          {
            {
              top   = beautiful.border_shadow_width,
              layout = wibox.container.margin,
            },
            bg=color,
            widget = wibox.container.background,
          },
          {
            {
              left   = beautiful.border_shadow_width,
              layout = wibox.container.margin,
            },
            bg=TRANSPARENT,
            widget = wibox.container.background,
          },
          layout = wibox.layout.align.horizontal,
        },
      buttons = get_buttons(c),
      id     = "main_layout",
      layout = wibox.container.background,
    }
  end

  --               Left border                --
  local tbl = awful.titlebar(c, {
    size = beautiful.base_border_width or 5,
    position = "left"
  })
  tbl:setup {
          {
            left   = beautiful.base_border_width,
            layout = wibox.container.margin,
          },
    buttons = get_buttons(c),
    bg=color,
    widget    = wibox.container.background
  }

  --               Right border                --
  local tbr = awful.titlebar(c, {
    size = (beautiful.base_border_width or 5)+(beautiful.border_shadow_width or 0),
    position = "right"
  })
  tbr:setup{
    buttons = get_buttons(c),
    id="main_layout",
    {
      {
        {
          left   = beautiful.base_border_width,
          layout = wibox.container.margin,
        },
        bg=color,
        widget = wibox.container.background,
      },
      layout = wibox.container.margin,
    },
    {
      not is_titlebar and {
        {
          {
            top   = beautiful.border_shadow_width,
            layout = wibox.container.margin,
          },
          bg=TRANSPARENT,
          widget = wibox.container.background,
        },
        height   = beautiful.base_border_width + beautiful.border_shadow_width,
        width   = beautiful.border_shadow_width,
        layout = wibox.container.constraint,
      },
      {
        {
          { text   = ' ', widget = wibox.widget.textbox, },
          bg=SHADOW,
          widget = wibox.container.background,
        },
        width   = beautiful.border_shadow_width,
        layout = wibox.container.constraint,
      },
      layout = wibox.layout.align.vertical,
    },
    layout = wibox.layout.align.horizontal,
  }

  --               Bottom border                --
  local tbb = awful.titlebar(c, {
    size = (beautiful.base_border_width or 5) + (beautiful.border_shadow_width or 0),
    position = "bottom"
  })
  tbb:setup{
    buttons = get_buttons(c),
    id="main_layout",
    {
      nil,
      {
        {
          top   = beautiful.base_border_width,
          layout = wibox.container.margin,
        },
        bg=color,
        widget = wibox.container.background,
      },
      {
        {
          {
            left   = beautiful.border_shadow_width,
            top   = beautiful.base_border_width,
            layout = wibox.container.margin,
          },
          bg=SHADOW,
          widget = wibox.container.background,
        },
        height   = beautiful.base_border_width,
        layout = wibox.container.constraint,
      },
      layout = wibox.layout.align.horizontal,
    },
    {
      {
        {
          { text   = ' ', widget = wibox.widget.textbox, },
          bg=TRANSPARENT,
          widget = wibox.container.background,
        },
        width   = beautiful.base_border_width + beautiful.border_shadow_width,
        height   = beautiful.border_shadow_width,
        layout = wibox.container.constraint,
      },
      {
        {
          { text   = ' ', widget = wibox.widget.textbox, },
          bg=SHADOW,
          widget = wibox.container.background,
        },
        height   = beautiful.border_shadow_width,
        layout = wibox.container.constraint,
      },
      layout = wibox.layout.align.horizontal,
    },
    layout = wibox.layout.align.vertical,
  }
  return {
    top = tbt,
    left = tbl,
    right = tbr,
    bottom = tbb,
  }
end


local function make_border_normal(c, color, is_titlebar)
  local tbt
  if not is_titlebar then
    tbt = awful.titlebar(c,{size= beautiful.base_border_width or 5, position="top"})
    tbt:setup {
      buttons = get_buttons(c),
      id     = "main_layout",
      layout = wibox.container.background,
    }
  end
  local tbl = awful.titlebar(c,{size= beautiful.base_border_width or 5,position="left"})
  tbl:setup {
    buttons = get_buttons(c),
    bg=color,
    id     = "main_layout",
    widget    = wibox.container.background
  }
  local tbr = awful.titlebar(c,{size= beautiful.base_border_width or 5,position="right"})
  tbr:setup {
    buttons = get_buttons(c),
    id     = "main_layout",
    widget    = wibox.container.background
  }
  local tbb = awful.titlebar(c,{size= beautiful.base_border_width or 5,position="bottom"})
  tbb:setup {
    buttons = get_buttons(c),
    id     = "main_layout",
    layout = wibox.container.background,
  }
  return {
    top = tbt,
    left = tbl,
    right = tbr,
    bottom = tbb,
  }
end


function titlebar.make_border(c, color, shadow, is_titlebar)
  --if not is_titlebar and titlebar.is_enabled(c) then
    --nlog(1)
    --titlebar.remove_titlebar(c)
  --end
  if not shadow and titlebar.border_is_enabled(c) then
    return
  end
  --c.border_width = 0
  --c.border_color = beautiful.border_normal

  local borders
  if shadow then
    make_border_with_shadow(c, color, shadow, is_titlebar)
  else
    borders = make_border_normal(c, color, is_titlebar)
    for _, position in ipairs({"top", "bottom", "left", "right"}) do
      if borders[position] then
        attach_highlight_on_hover(borders[position], c)
      end
    end
  end
end

function titlebar.make_titlebar(c, color, shadow)
  if titlebar.is_enabled(c) and not shadow then
    return
  end

  if not titlebar.border_is_enabled(c) or shadow then
    titlebar.make_border(c, color, shadow, true)
  end

  local tbt = awful.titlebar(c, {
      size=beautiful.titlebar_height or 16,
      position = beautiful.titlebar_position,
      opacity = beautiful.titlebar_opacity,
    }
  )
  local titlebar_setup = {
      {
        {
          {
            awful.titlebar.widget.closebutton(c),
            awful.titlebar.widget.minimizebutton(c),
            --awful.titlebar.widget.maximizedbutton(c)),
            layout = wibox.layout.fixed.horizontal,
          },
          top   = beautiful.base_border_width,
          layout = wibox.container.margin,
        }, {
          {
            {
              widget = awful.titlebar.widget.titlewidget(c),
              align = "center",
              font = beautiful.titlebar_font,
            },
            layout = wibox.layout.flex.horizontal,
          },
          buttons = get_buttons(c),
          top   = beautiful.base_border_width,
          layout = wibox.container.margin,
        }, {
          {
            awful.titlebar.widget.ontopbutton(c),
            awful.titlebar.widget.stickybutton(c),
            layout = wibox.layout.fixed.horizontal,
          },
          top   = beautiful.base_border_width,
          layout = wibox.container.margin,
        },
        layout = wibox.layout.align.horizontal,
      },
      left   = beautiful.base_border_width,
      right   = beautiful.base_border_width,
      layout = wibox.container.margin,
    }
  if shadow then
      tbt:setup {
        {
          nil,
          {
            titlebar_setup,
            bg=color,
            widget = wibox.container.background,
          },
          {
            {
              {
                top   = beautiful.border_shadow_width + beautiful.base_border_width,
                left   = beautiful.border_shadow_width,
                layout = wibox.container.margin,
              },
              bg=TRANSPARENT,
              widget = wibox.container.background,
            },
            {
              {
                left   = beautiful.border_shadow_width,
                layout = wibox.container.margin,
              },
              bg=shadow,
              widget = wibox.container.background,
            },
            layout = wibox.layout.align.vertical,
          },
          layout = wibox.layout.align.horizontal,
        },
        id     = "main_layout",
        layout = wibox.container.background,
      }
  else
    tbt:setup(titlebar_setup)
    attach_highlight_on_hover(tbt, c)
  end

  --c.skip_taskbar = true
end

function titlebar.is_enabled(c)
  if (
    c["titlebar_top"](c):geometry()['height'] > beautiful.base_border_width
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
