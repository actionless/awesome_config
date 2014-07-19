local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")

local screen = screen
local client = client

local make_separator = require("actionless.widgets.common").make_separator
local current_font = require("actionless.helpers").font


local toolbar = {}


function toolbar.init(status)
  local modkey = status.modkey
  local bpc = beautiful.panel_colors
  local loaded_widgets = status.widgets

  -- Separators
  local sep = wibox.widget.imagebox(beautiful.small_separator)
  local separator  = make_separator(' ')
  local iseparator = make_separator('sq', {color_n='f'})
  local sep_info   = make_separator('sq', {color_n=bpc.info})
  local sep_media  = make_separator('sq', {color_n=bpc.media})


  local arr = { l={}, r={} }
  for _, direction in ipairs({'l', 'r'}) do
    for i=0,15 do
      arr[direction][i] = make_separator(
        'arr' .. direction, { fg=beautiful.color[i] })
    end
    for _, i in ipairs({'b', 'f'}) do
      arr[direction][i] = make_separator(
        'arr' .. direction, { fg=beautiful.color[i] })
    end
    setmetatable(
      arr[direction],
      { __index = make_separator('arr' .. direction) }
    )
  end




  -- Create a wibox for each screen and add it
  local mywibox = {}
  for s = 1, screen.count() do

    -- LEFT side
    local left_layout = wibox.layout.fixed.horizontal()

    left_layout:add(sep)
    left_layout:add(loaded_widgets.uniq[s].taglist)

    left_layout:add(separator)
    left_layout:add(loaded_widgets.close_button)
    left_layout:add(separator)
    left_layout:add(loaded_widgets.uniq[s].promptbox)
    left_layout:add(arr.l[bpc.tasklist])
    -- RIGHT side
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(arr.r[bpc.tasklist])

    right_layout:add(separator)

    right_layout:add(arr.l[bpc.media])
    right_layout:add(loaded_widgets.netctl)
    right_layout:add(sep_media)
    right_layout:add(loaded_widgets.music)
    right_layout:add(loaded_widgets.volume)

    if s == 1 then right_layout:add(loaded_widgets.systray_toggle) end

    right_layout:add(arr.l[bpc.info])
    right_layout:add(loaded_widgets.mem)
    right_layout:add(sep_info)
    right_layout:add(loaded_widgets.cpu)
    right_layout:add(sep_info)
    right_layout:add(loaded_widgets.temp)
    right_layout:add(sep_info)
    right_layout:add(loaded_widgets.bat)
    right_layout:add(arr.r[bpc.info])

    right_layout:add(separator)

    right_layout:add(loaded_widgets.textclock)

    right_layout:add(separator)

    right_layout:add(loaded_widgets.uniq[s].layoutbox)


    -- TOOLBAR
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(loaded_widgets.uniq[s].tasklist)
    layout:set_right(right_layout)


    -- only bottom panel MARGIN:
    if beautiful.panel_margin then
      local margined_layout = wibox.layout.align.vertical()
      margined_layout:set_middle(layout)
      margined_layout:set_bottom(
        wibox.widget.textbox(
          string.format(
            '<span font="%s %s"> </span>',
            current_font,
            beautiful.panel_margin
          )
      ))
      layout = margined_layout
    end

    mywibox[s] = awful.wibox({
      position = "top",
      screen = s,
      height = beautiful.panel_height,
      -- PANEL MARGIN on 4 sides:
      --border_width = beautiful.panel_margin,
    })
    mywibox[s]:set_widget(layout)
    mywibox[s].opacity = beautiful.panel_opacity
    mywibox[s]:set_bg(beautiful.panel_bg)
    mywibox[s]:set_fg(beautiful.panel_fg)

    -- padding for clients' area
    awful.screen.padding(
      screen[s], {
        top = beautiful.screen_margin,
        bottom = beautiful.screen_margin,
        left = beautiful.screen_margin,
        right = beautiful.screen_margin
      }
    )

  end

end
return toolbar
