local beautiful = require("beautiful")
local awful = require("awful")
local wibox = require("wibox")

local capi = {
  screen = screen,
  client = client,
}

local helpers = require("actionless.helpers")
local widgets = require("actionless.widgets")
local common = widgets.common
local tasklist_addon = require("actionless.tasklist_addon")

local dpi = require("actionless.xresources").compute_fontsize


local widget_loader = {}

function widget_loader.init(awesome_context)
  local w = awesome_context.widgets
  local conf = awesome_context.config
  local modkey = awesome_context.modkey

  -- Keyboard layout widget
  w.kbd = widgets.kbd({
    bg = beautiful.warning,
    left_separators = {'sq'},
    right_separators = {'sq'},
  })

  -- NetCtl
  w.netctl = widgets.netctl({
    update_interval = 5,
    preset = conf.net_preset,
    wlan_if = conf.wlan_if,
    eth_if = conf.eth_if,
    bg = beautiful.widget_netctl_bg,
    fg = beautiful.widget_netctl_fg,
  })
  -- MUSIC
  w.music = widgets.music.widget({
      update_interval = 5,
      backends = conf.music_players,
      music_dir = conf.music_dir,
      bg = beautiful.widget_music_bg,
      fg = beautiful.widget_music_fg,
      force_no_bgimage=true,
      --valign = "bottom",
  })
  -- ALSA volume
  if awesome_context.volume_widget == "apw" then
    local apw_widget = require("third_party/apw/widget")
    w.volume = setmetatable(
      common.constraint({
        widget=apw_widget,
        height=dpi(80)
      }),
      { __index = apw_widget }
    )
  else
    w.volume = widgets.alsa({
      update_interval = 5,
      step=2,
      channel = 'Master',
      channels_toggle = {'Master', 'Speaker', 'Headphone'},
      bg = beautiful.widget_alsa_bg,
      fg = beautiful.widget_alsa_fg,
      left_separators = { 'arrl' },
      right_separators = { 'sq' }
    })
  end

  -- systray_toggle
  --w.systray_toggle = widgets.systray_toggle({
    --screen = 1
  --})
  --w.systray_toggle = widgets.sneaky_tray({})
  --w.systray = wibox.widget.systray()

  -- MEM
  w.mem = widgets.mem({
    update_interval = 2,
    list_length = 20,
    --bg = beautiful.color["6"],
    new_top = true,
  })
  -- CPU
  w.cpu = widgets.cpu({
    update_interval = 2,
    list_length = 20,
    new_top = true,
  })
  -- Sensor
  w.temp = widgets.temp({
    update_interval = 10,
    sensor = "Core 0",
    warning = 75,
    bg = beautiful.widget_temp_bg,
    fg = beautiful.widget_temp_fg,
  })
  -- Battery
  if awesome_context.have_battery then
    w.bat = widgets.bat({
      update_interval = 30,
      bg = beautiful.widget_bat_bg,
      fg = beautiful.widget_bat_fg,
      show_when_charged=false,
    })
  end

  -- Textclock
  w.textclock = widgets.common.decorated({
    widget = awful.widget.textclock("%H:%M"),
    valign = "bottom",
  })
  widgets.calendar:attach(w.textclock, {fg=beautiful.theme, position="top_left"})


  w.screen = {}
  for s = 1, capi.screen.count() do
    w.screen[s] = {}
    local sw = w.screen[s]

    -- CLOSE button
    sw.close_button = widgets.manage_client(
      {
        screen = s,
        bg = beautiful.widget_close_bg,
        fg = beautiful.widget_close_fg,
        left_separators = beautiful.widget_close_left_decorators,
        right_separators = beautiful.widget_close_right_decorators,
        clientbuttons = awesome_context.clientbuttons,
        clientbuttons_manage = awesome_context.clientbuttons_manage,
      }
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
    --sw.taglist = widgets.common.decorated_horizontal({
      --widget = awful.widget.taglist(
        --s, awful.widget.taglist.filter.all, sw.taglist.buttons
      --),
      --bg = beautiful.widget_taglist_bg,
      --fg = beautiful.widget_taglist_fg,
    --})
    sw.taglist = awful.widget.taglist(
        s, awful.widget.taglist.filter.all, sw.taglist.buttons
    )

    -- promptbox
    local promptbox = awful.widget.prompt({ })
    function promptbox:set_font(...)
      self.widget:set_font(...)
    end
    function promptbox:set_markup(...)
      self.widget:set_markup(...)
    end
    sw.promptbox = widgets.common.decorated_horizontal({
      widget = promptbox,
      left_separators = {},
      right_separators = {},
      bg = beautiful.panel_widget_bg_warning,
      fg = beautiful.panel_widget_fg_warning,
    })
    function sw.promptbox:run(...)
      self.widget.widget:run(...)
    end

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
    sw.layoutbox = widgets.layoutbox({
      screen = s,
      bg = beautiful.widget_layoutbox_bg,
      fg = beautiful.widget_layoutbox_fg,
      --valign = "bottom",
    })

  end

  return awesome_context
end

return widget_loader
