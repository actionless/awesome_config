local beautiful = require("beautiful")
local awful = require("awful")
local wibox = require("wibox")

local capi = {
  screen = screen,
  client = client,
}

local helpers = require("actionless.helpers")
local widgets = require("actionless.widgets")
local tasklist_addon = require("actionless.tasklist_addon")


local widget_loader = {}

function widget_loader.init(awesome_context)
  local w = awesome_context.widgets
  local conf = awesome_context.config
  local bpc = beautiful.panel_colors
  local modkey = awesome_context.modkey
  local term16 = beautiful.color

  -- Keyboard layout widget
  w.kbd = widgets.kbd({
    bg = beautiful.warning
  })

  -- NetCtl
  w.netctl = widgets.netctl({
    update_interval = 5,
    preset = conf.net_preset,
    wlan_if = conf.wlan_if,
    eth_if = conf.eth_if,
    bg = term16[bpc.media],
    fg = beautiful.panel_widget_fg,
  })
  -- MUSIC
  w.music = widgets.music.widget({
    update_interval = 5,
    backends = conf.music_players,
    music_dir = conf.music_dir,
    bg = beautiful.panel_bg,
    fg = term16[bpc.media],
    force_no_bgimage=true,
  })
  -- ALSA volume
  w.volume = widgets.alsa({
    update_interval = 5,
    channel = 'Master',
    channels_toggle = {'Master', 'Speaker', 'Headphone'},
    bg = term16[bpc.media],
    fg = beautiful.panel_widget_fg,
    left_separators = { 'arrl' },
    right_separators = { 'sq' }
  })

  -- systray_toggle
  --w.systray_toggle = widgets.systray_toggle({
    --screen = 1
  --})
  --w.systray_toggle = widgets.sneaky_tray({})
  --w.systray = wibox.widget.systray()

  -- MEM
  w.mem = widgets.mem({
    update_interval = 10,
    list_length = 20,
    bg = term16[bpc.info],
    fg = beautiful.panel_widget_fg,
  })
  -- CPU
  w.cpu = widgets.cpu({
    update_interval = 5,
    cores_number = conf.cpu_cores_num,
    list_length = 20,
    bg = term16[bpc.info],
    fg = beautiful.panel_widget_fg,
  })
  -- Sensor
  w.temp = widgets.temp({
    update_interval = 10,
    sensor = "Core 0",
    warning = 75,
    bg = term16[bpc.info],
    fg = beautiful.panel_widget_fg,
  })
  -- Battery
  w.bat = widgets.bat({
    update_interval = 30,
    bg = term16[bpc.info],
    fg = beautiful.panel_widget_fg,
    show_when_charged=false,
  })

  -- Textclock
  w.textclock = awful.widget.textclock("%H:%M")
  widgets.calendar:attach(w.textclock)


  w.screen = {}
  for s = 1, capi.screen.count() do
    w.screen[s] = {}
    local sw = w.screen[s]

    -- CLOSE button
    sw.close_button = widgets.manage_client(
      s, { bg=term16[bpc.close] }
    )

    -- taglist
    sw.taglist = {}
    sw.taglist.buttons = awful.util.table.join(
      awful.button({		}, 1, awful.tag.viewonly),
      awful.button({ modkey	}, 1, awful.client.movetotag),
      awful.button({		}, 3, awful.tag.viewtoggle),
      awful.button({ modkey	}, 3, awful.client.toggletag),
      awful.button({		}, 5, function(t)
        awful.tag.viewnext(awful.tag.getscreen(t)) end),
      awful.button({		}, 4, function(t)
        awful.tag.viewprev(awful.tag.getscreen(t)) end)
    )
    sw.taglist = widgets.common.decorated({
      widget = awful.widget.taglist(
        s, awful.widget.taglist.filter.all, sw.taglist.buttons
      ),
      bg = term16[bpc.taglist],
      fg = beautiful.panel_widget_fg,
    })

    -- promptbox
    sw.promptbox = awful.widget.prompt()

    -- tasklist
    local tasklist_buttons = awful.util.table.join(
      awful.button({ }, 1, function (c)
        if c == capi.client.focus then
          c.minimized = true
        else
          c.minimized = false
          if not c:isvisible() then
            awful.tag.viewonly(c:tags()[1])
          end
          -- This will also un-minimize
          -- the client, if needed
          capi.client.focus = c
          c:raise()
        end
      end),
      awful.button({ }, 3, function ()
        if awesome_context.menu.instance and awesome_context.menu.instance.wibox.visible then
          awesome_context.menu.instance:hide()
          awesome_context.menu.instance = nil
        else
          if awesome_context.menu.instance then
            awesome_context.menu.instance:hide()
          end
          awesome_context.menu.instance = awful.menu.clients({
            theme = {
              width=capi.screen[helpers.get_current_screen()].workarea.width
            },
            coords = { x=0, y=18 }
          })
        end
      end),
      awful.button({ }, 4, function ()
        awful.client.focus.byidx(-1)
        if capi.client.focus then capi.client.focus:raise() end
      end),
      awful.button({ }, 5, function ()
        awful.client.focus.byidx(1)
        if capi.client.focus then capi.client.focus:raise() end
      end)
    )
    local active_client_widget = awful.widget.tasklist(
      s,
      awful.widget.tasklist.filter.focused,
      tasklist_buttons
    )
    local minimized_clients_widget = awful.widget.tasklist(
      s,
      awful.widget.tasklist.filter.minimizedcurrenttags,
      tasklist_buttons,
      nil,
      tasklist_addon.list_update
    )
    sw.tasklist = wibox.layout.align.horizontal()
    sw.tasklist:set_second(active_client_widget)
    sw.tasklist:set_third(minimized_clients_widget)

    -- layoutbox
    -- @TODO: remove it
    local layoutbox_color = bpc.layoutbox or 7
    sw.layoutbox = widgets.layoutbox({
      screen = s,
      bg = term16[layoutbox_color]
    })
    sw.layoutbox:buttons(awful.util.table.join(
      awful.button({ }, 1, function ()
        awful.layout.inc(awful.layout.layouts, 1) end),
      awful.button({ }, 3, function ()
        awful.layout.inc(awful.layout.layouts, -1) end),
      awful.button({ }, 5, function ()
        awful.layout.inc(awful.layout.layouts, 1) end),
      awful.button({ }, 4, function ()
        awful.layout.inc(awful.layout.layouts, -1) end)
    ))

  end

  return awesome_context
end

return widget_loader
