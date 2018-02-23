local beautiful = require("beautiful")
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi

local capi = {
  screen = screen,
  client = client,
}

local widgets = require("actionless.widgets")
local common = require("actionless.widgets").common
local tasklist_addon = require("actionless.tasklist_addon")
local persistent = require("actionless.persistent")


local widget_loader = {}

function widget_loader.init(awesome_context)
  local w = awesome_context.widgets
  local conf = awesome_context.config
  local modkey = awesome_context.modkey

  local lcarslist_enabled = persistent.lcarslist.get()

  local topwibox = {}

  -- Keyboard layout widget
  w.kbd = widgets.kbd({
    bg = beautiful.warning,
  })

  -- NetCtl
  w.netctl = widgets.netctl({
    update_interval = 5,
    preset = conf.net_preset,
    wlan_if = conf.wlan_if,
    eth_if = conf.eth_if,
  })
  -- MUSIC
  w.music = widgets.music.widget({
      update_interval = 5,
      backends = conf.music_players,
      fg = beautiful.widget_music_bg,
      bg = beautiful.panel_bg,
      force_no_bgimage=true,
      mopidy_player_command = awesome_context.cmds.tmux_run .. "ncmpcpp",
      enable_notifications = false,
      --valign = "bottom",
  })
  -- volume
  if lcarslist_enabled then
    beautiful.apw_bg_color = beautiful.panel_bg
  end
  w.volume = require("third_party/apw/widget")

  local separator  = common.constraint({ width=beautiful.panel_widget_spacing, })
  -- systray_toggle
  w.systray_toggle = widgets.sneaky_toggle({
      widgets={
        --h_sep,
        --sep_media,

        separator,
        w.netctl,
        separator,

        --sep_media,
        --h_sep,
      }, enable_sneaky_tray = true,
  })

  -- MEM
  w.mem = widgets.mem({
    update_interval = 2,
    list_length = 20,
  })
  -- CPU
  w.cpu = widgets.cpu({
    update_interval = 2,
    list_length = 20,
  })
  -- Sensor
  w.temp = widgets.temp({
    update_interval = 10,
    sensor = awesome_context.sensor,
    warning = 75,
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
  local markup = require("actionless.util.markup")
  local textclock = wibox.widget.textclock(markup.fg(beautiful.clock_fg or beautiful.panel_fg, "%H:%M"))
  w.textclock = textclock
  beautiful.calendar_month_padding = 40
  beautiful.calendar_month_border_color = beautiful.notification_border_color
  beautiful.calendar_month_border_width = beautiful.notification_border_width
  w.calendar_popup = awful.widget.calendar_popup.month({
    spacing=dpi(3),
    margin=beautiful.useless_gap*6,
    opacity=beautiful.notification_opacity,
  })
  w.calendar_popup:attach(w.textclock, nil, {on_hover=true})


  w.screen = {}
  awful.screen.connect_for_each_screen(function(s)
    local si = s.index
    w.screen[si] = {}
    local sw = w.screen[si]

    -- CLOSE button
    sw.manage_client = widgets.manage_client(
      {
        screen = s,
        bg = beautiful.widget_close_bg,
        fg = beautiful.widget_close_fg,
        error_color_on_hover = beautiful.widget_close_error_color_on_hover,
      }
    )

    -- taglist
    sw.taglist = {}
    sw.taglist.buttons = awful.util.table.join(
      awful.button({		}, 1, function(t) t:view_only() end),
      awful.button({ modkey     }, 1, function(t)
                                        if capi.client.focus then
                                            capi.client.focus:move_to_tag(t)
                                        end
                                      end),
      awful.button({		}, 3, awful.tag.viewtoggle),
      awful.button({ modkey     }, 3, function(t)
                                          if capi.client.focus then
                                              capi.client.focus:toggle_tag(t)
                                          end
                                      end)--,
      --awful.button({ }, 4, function()
        --helpers.tag_view_noempty(-1)
      --end),
      --awful.button({ }, 5, function()
        --helpers.tag_view_noempty(1)
      --end)
    )

    --sw.taglist = awful.widget.taglist{
        --screen = s,
        --filter = awful.widget.taglist.filter.noempty,
        --buttons = sw.taglist.buttons
    --}
    sw.taglist = awful.widget.taglist(
        s,
        awful.widget.taglist.filter.noempty,
        sw.taglist.buttons
    )

    -- promptbox
    sw.promptbox = awful.widget.prompt()
    sw.promptbox.widget = widgets.common.widget({
      margin = { left = dpi(8), right = dpi(8), },
      show_icon = false,
    })
    sw.promptbox.widget:set_text(nil)
    sw.promptbox.fg = beautiful.panel_widget_fg_warning
    sw.promptbox.bg = beautiful.panel_widget_bg_warning
    sw.promptbox.shape_border_width = beautiful.panel_widget_border_width or 0
    sw.promptbox.shape_clip = true
    sw.promptbox.shape = function(_c, _w, _h)
      return gears.shape.rounded_rect(
        _c, _w, _h, beautiful.panel_widget_border_radius
      )
    end

    -- tasklist
    local tasklist_buttons = awful.util.table.join(
      awful.button({ }, 1, function (c)
        if c.is_tag then
          return c.tag:view_only()
        end
        if c == capi.client.focus then
          c.minimized = true
        else
          c.minimized = false
          if not c:isvisible() then
            c:tags()[1]:view_only()
          end
          -- This will also un-minimize
          -- the client, if needed
          capi.client.focus = c
          c:raise()
        end
      end),
      awful.button({ }, 2, function(c)
        client.focus = c
        c:raise()
        c.maximized = not c.maximized
      end),
      awful.button({ }, 3, function (c)
        if c.is_tag then
          return awful.tag.viewtoggle(c.tag)
        end
        if awesome_context.menu.instance and awesome_context.menu.instance.wibox.visible then
          awesome_context.menu.instance:hide()
          awesome_context.menu.instance = nil
        else
          if awesome_context.menu.instance then
            awesome_context.menu.instance:hide()
          end
          awesome_context.menu.instance = awful.menu.clients({
            theme = {
              width=capi.screen[awful.screen.focused()].workarea.width
            },
            coords = { x=0, y=18 }
          })
        end
      end)--,
      --awful.button({ }, 4, function ()
        --awful.client.focus.byidx(-1)
        --if capi.client.focus then capi.client.focus:raise() end
      --end),
      --awful.button({ }, 5, function ()
        --awful.client.focus.byidx(1)
        --if capi.client.focus then capi.client.focus:raise() end
      --end)
      --
      --awful.button({		}, 5, function(t)
        --helpers.tag_view_noempty(1, t.screen)
      --end),
      --awful.button({		}, 4, function(t)
        --helpers.tag_view_noempty(-1, t.screen)
      --end)
    )

    --sw.tasklist = awful.widget.tasklist{
      --screen = s,
      --filter = awful.widget.tasklist.filter.minimizedcurrenttags,
      --buttons = tasklist_buttons,
      --update_function = tasklist_addon.sorted_update,
    --}
    sw.tasklist = awful.widget.tasklist(
      s,
      awful.widget.tasklist.filter.minimizedcurrenttags,
      tasklist_buttons,
      nil,
      tasklist_addon.sorted_update
    )


    if lcarslist_enabled then
      sw.lcarslist = widgets.lcarslist(
        s,
        awful.widget.taglist.filter.noempty,
        tasklist_buttons,
        tasklist_addon.list_update
      )
    end
    sw.layoutbox = widgets.layoutbox({
      screen = s,
      fg = beautiful.widget_layoutbox_bg,
      bg = beautiful.widget_layoutbox_fg,
      --valign = "bottom",
      --bg = theme.color.color8, -- 6
      horizontal = true,
    })



    topwibox[si] = awful.wibar({
      position = "top",
      screen = s,
      height = beautiful.panel_height,
      opacity = beautiful.panel_opacity,
      bg=beautiful.panel_bg,
      fg=beautiful.panel_fg,
    })
    --topwibox[s]:set_widget(top_panel_layout)

  end)

  awesome_context.topwibox = topwibox

  return awesome_context
end

return widget_loader
