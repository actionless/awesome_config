local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")

local screen = screen
local client = client

local widgets = require("actionless.widgets")
local decorated = widgets.common.decorated
local custom_tasklist = require("actionless.tasklist")
local helpers = require("actionless.helpers")
--local rpic = widgets.random_pic


local toolbar = {}


function toolbar.init(status)
local modkey = status.modkey
local bpc = beautiful.panel_colors

-- CLOSE button
status.widgets.close_button = widgets.manage_client({color_n=bpc.close})

-- NetCtl
local netctlwidget = widgets.netctl({
  update_interval = 5,
  preset = status.config.net_preset,
  wlan_if = status.config.wlan_if,
  eth_if = status.config.eth_if,
  bg = beautiful.color[bpc.media],
  fg = beautiful.color.b,
})
-- MUSIC
status.widgets.music = widgets.music.widget({
  update_interval = 5,
  backend = status.config.music_player,
  music_dir = status.config.music_dir,
  bg = beautiful.color.b,
  fg = beautiful.color[bpc.media],
})
-- ALSA volume
status.widgets.volume = widgets.alsa({
  update_interval = 5,
  channel = 'Master',
  channels_toggle = {'Master', 'Speaker', 'Headphone'},
  color_n = bpc.media,
  left = { 'sq' },
  right = { 'r' }
})

-- systray_toggle
status.widgets.systray_toggle = widgets.systray_toggle({
  screen = 1
})

-- CPU
local cpuwidget = widgets.cpu({
  update_interval = 5,
  cores_number = status.config.cpu_cores_num,
  list_length = 20,
  bg = beautiful.color[bpc.info],
  fg = beautiful.color.b,
})
-- MEM
local memwidget = widgets.mem({
  update_interval = 10,
  list_length = 20,
  bg = beautiful.color[bpc.info],
  fg = beautiful.color.b,
})
-- Sensor
local tempwidget = widgets.temp({
  update_interval = 10,
  sensor = "Core 0",
  warning = 75,
  bg = beautiful.color[bpc.info],
  fg = beautiful.color.b,
})
-- Battery
local batwidget = widgets.bat({
  update_interval = 30,
  bg = beautiful.color[bpc.info],
  fg = beautiful.color.b,
})
-- Textclock
-- mytextclock = awful.widget.textclock("%a %d %b  %H:%M")
local mytextclock = awful.widget.textclock("%H:%M")
widgets.calendar:attach(mytextclock)

-- Separators
local i
local sep = wibox.widget.imagebox(beautiful.small_separator)
local separator = widgets.common.make_text_separator(' ')
local arr = { l={}, r={} }

local iseparator = widgets.common.make_text_separator(
  'sq', {color_n='f'})
local sep_info = widgets.common.make_text_separator(
  'sq', {color_n=bpc.info})
local sep_media = widgets.common.make_text_separator(
  'sq', {color_n=bpc.media})


for _, direction in ipairs({'l', 'r'}) do
  for i=0,15 do
    arr[direction][i] = widgets.common.make_arrow_separator(direction, i)
  end
  for _, i in ipairs({'b', 'f'}) do
    arr[direction][i] = widgets.common.make_arrow_separator(direction, i)
  end
  setmetatable(
    arr[direction],
    { __index = widgets.common.make_arrow_separator(direction) }
  )
end



-- Create a wibox for each screen and add it
local mytaglist = {}
mytaglist.buttons = awful.util.table.join(
  awful.button({		}, 1, awful.tag.viewonly),
  awful.button({ modkey		}, 1, awful.client.movetotag),
  awful.button({		}, 3, awful.tag.viewtoggle),
  awful.button({ modkey		}, 3, awful.client.toggletag),
  awful.button({		}, 5, function(t)
    awful.tag.viewnext(awful.tag.getscreen(t)) end),
  awful.button({		}, 4, function(t)
    awful.tag.viewprev(awful.tag.getscreen(t)) end)
)
local mycurrenttask = {}
local mytasklist = {}
mytasklist.buttons = awful.util.table.join(
  awful.button({ }, 1, function (c)
    if c == client.focus then
      c.minimized = true
    else
      -- Without this, the following
      -- :isvisible() makes no sense
      c.minimized = false
      if not c:isvisible() then
        awful.tag.viewonly(c:tags()[1])
      end
      -- This will also un-minimize
      -- the client, if needed
      client.focus = c
      c:raise()
    end
  end),
  awful.button({ }, 3, function ()
    if status.menu.instance then
      status.menu.instance:hide()
      status.menu.instance = nil
    else
      status.menu.instance = awful.menu.clients({
        theme = {width=screen[helpers.get_current_screen()].workarea.width},
        coords = {x=0, y=18}})
    end
  end),
  awful.button({ }, 4, function ()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
  end),
  awful.button({ }, 5, function ()
    awful.client.focus.byidx(1)
    if client.focus then client.focus:raise() end
  end))

status.widgets.promptbox = {}
local mylayoutbox = {}
local mywibox = {}
for s = 1, screen.count() do

  awful.screen.padding(
    screen[s],
    { top = beautiful.screen_margin,
      bottom = beautiful.screen_margin,
      left = beautiful.screen_margin,
      right = beautiful.screen_margin })

  -- layoutbox
  mylayoutbox[s] = widgets.layoutbox({
    screen = s,
    color_n = 7}
  )
  mylayoutbox[s]:buttons(awful.util.table.join(
    awful.button({ }, 1, function ()
      awful.layout.inc(awful.layout.layouts, 1) end),
    awful.button({ }, 3, function ()
      awful.layout.inc(awful.layout.layouts, -1) end),
    awful.button({ }, 5, function ()
      awful.layout.inc(awful.layout.layouts, 1) end),
    awful.button({ }, 4, function ()
      awful.layout.inc(awful.layout.layouts, -1) end)))

  -- taglist
  mytaglist[s] = decorated({
    widget = awful.widget.taglist(
      s, awful.widget.taglist.filter.all, mytaglist.buttons),
    color_n = bpc.taglist,
  })

  -- promptbox
  status.widgets.promptbox[s] = awful.widget.prompt()

  -- tasklist
  mytasklist[s] = custom_tasklist(
    s, custom_tasklist.filter.focused_and_minimized_current_tags, mytasklist.buttons)

  -- LEFT side
  local left_layout = wibox.layout.fixed.horizontal()
  left_layout:add(sep)
  left_layout:add(mytaglist[s])
  left_layout:add(separator)
  left_layout:add(status.widgets.close_button)
  left_layout:add(status.widgets.promptbox[s])
  left_layout:add(separator)
  left_layout:add(arr.l[bpc.tasklist])

  -- RIGHT side
  local right_layout = wibox.layout.fixed.horizontal()
  right_layout:add(arr.r[bpc.tasklist])
  right_layout:add(separator)

  right_layout:add(arr.l[bpc.media])
  right_layout:add(netctlwidget)
  right_layout:add(sep_media)
  right_layout:add(status.widgets.music)
  right_layout:add(status.widgets.volume)

  if s == 1 then right_layout:add(status.widgets.systray_toggle) end

  right_layout:add(arr.l[bpc.info])
  right_layout:add(memwidget)
  right_layout:add(sep_info)
  right_layout:add(cpuwidget)
  right_layout:add(sep_info)
  right_layout:add(tempwidget)
  right_layout:add(sep_info)
  right_layout:add(batwidget)
  --right_layout:add(sep_info)

  right_layout:add(arr.r[bpc.info])
  right_layout:add(separator)
  right_layout:add(mytextclock)
  right_layout:add(separator)
  right_layout:add(mylayoutbox[s])


  -- TOOLBAR
  local layout = wibox.layout.align.horizontal()
  layout:set_left(left_layout)
  layout:set_middle(mytasklist[s])
  layout:set_right(right_layout)


  -- enabled:
  if beautiful.panel_margin then
    local margined_layout = wibox.layout.align.vertical()
    margined_layout:set_middle(layout)
    margined_layout:set_bottom(
      wibox.widget.textbox(
        '<span font="DejaVu Sans Mono ' .. beautiful.panel_margin .. '"> </span>'
    ))
    layout = margined_layout
  end

  mywibox[s] = awful.wibox({
    position = "top",
    screen = s,
    height = beautiful.panel_height,
    -- disabled: 
    --border_width = beautiful.panel_margin,
  })
  mywibox[s]:set_widget(layout)
  mywibox[s].opacity = beautiful.panel_opacity
  mywibox[s]:set_bg(beautiful.panel_bg)
  mywibox[s]:set_fg(beautiful.panel_fg)

end


end
return toolbar
