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
local tasklist_addon = require("actionless.tasklist_addon")
local menu_addon = require("actionless.menu_addon")
local persistent = require("actionless.persistent")
local markup = require("actionless.util.markup")
local h_color = require("actionless.util.color")


local TRANSPARENT = "#00000000"

local widget_loader = {}

function widget_loader.init(awesome_context)
  local w = awesome_context.widgets
  local conf = awesome_context.config
  local modkey = awesome_context.modkey

  local lcarslist_enabled = persistent.lcarslist.get()

  local topwibox = {}

  -- Keyboard layout widget
  w.kbd = widgets.kbd({
      bg=beautiful.panel_widget_bg_warning,
      fg=beautiful.panel_widget_fg_warning
  })

  -- NetCtl
  if conf.net_preset then
    w.netctl = widgets.netctl({
      update_interval = 5,
      preset = conf.net_preset,
      wlan_if = conf.wlan_if,
      eth_if = conf.eth_if,
    })
  end
  -- MUSIC
  w.music = widgets.music.widget({
      update_interval = 20,
      backends = conf.music_players,
      fg = beautiful.widget_music_bg,
      bg = TRANSPARENT,
      force_no_bgimage=true,
      mopidy_player_command = awesome_context.cmds.tmux_run .. "ncmpcpp",
      enable_notifications = false,
      bold_artist = true,
      --valign = "bottom",
  })
  -- volume
  if lcarslist_enabled then
    beautiful.apw_bg_color = beautiful.panel_bg
  end

  w.volume = require("third_party/apw")({
    backend='pactl',
  })
  w.volume.pulseBar.step = 0.02
  w.volume.backend.OrigToggleMute = w.volume.backend.ToggleMute
  w.volume.backend.ToggleMute = function(...)
      w.volume.backend.OrigToggleMute(...)
      if w.volume.backend.Mute then
        awful.spawn.spawn('xset -led named "Scroll Lock"')
      else
        awful.spawn.spawn('xset led named "Scroll Lock"')
      end
  end

  w.pipewire_helper = widgets.pipewire_helper({})
  w.screen_layouts = widgets.screen_layouts({})

  -- MEM
  w.mem = widgets.mem({
    update_interval = 5,
    list_length = 20,
    high_swap_ratio = awesome_context.config.high_swap_ratio,
    critical_swap_ratio = awesome_context.config.critical_swap_ratio,
  })
  -- CPU
  w.cpu = widgets.cpu({
    update_interval = 5,
    list_length = 20,
  })
  for _, widget in ipairs({w.mem, w.cpu}) do
    local buttons = widget:buttons()
    buttons = awful.util.table.join(buttons,
      awful.button({		}, 1,
      function()
        awful.spawn(awesome_context.cmds.system_monitor)
      end)
    )
    widget:buttons(buttons)
  end
  -- Sensor
  w.temp = widgets.temp({
    update_interval = 20,
    sensors = awesome_context.sensors,
  })
  w.disk = widgets.disk({
    --update_interval = 200,
    update_interval = 20,
    rules = awesome_context.config.disk_warnings,
  })
  -- Battery
  if awesome_context.have_battery then
    w.bat = widgets.bat({
      update_interval = 30,
      --update_interval = 100,
      bg = beautiful.widget_bat_bg,
      fg = beautiful.widget_bat_fg,
      show_when_charged=awesome_context.config.bat_show_when_charged or false,
    })
  end
  -- Arch updates
  w.updates = widgets.arch_updates({
    update_interval = 1200, -- 20 minutes
    bg = beautiful.panel_widget_updates_bg or (
        h_color.is_dark(beautiful.panel_bg or beautiful.bg_normal) ==
        h_color.is_dark(beautiful.xrdb and beautiful.xrdb.background or beautiful.bg_normal)
      ) and
      TRANSPARENT or
      beautiful.panel_widget_fg_warning,
    fg = beautiful.panel_widget_updates_fg or beautiful.panel_widget_bg_warning,
  })

  -- NAUGHTY SIDEBAR --
  --local systray = awful.widget.only_on_screen(wibox.widget.systray(), screen.primary)
  local systray = wibox.widget.systray()
  systray:set_screen(screen.primary)
  if conf.have_backlight then
    w.backlight = widgets.backlight{
      markup = 'Backlight: ',
      presets = {64, 75, 100},
    }
    w.backlight.progressbar.update_interval = 60
  end
  local gsc = beautiful.gtk.get_theme_variables()
  w.naughty_sidebar = widgets.naughty_sidebar{
    hide_without_notifications = false,
    custom_widgets = {
      {
        widget=systray,
        width=32, height=32,
        --width=24, height=24,
        --width=48, height=48,
        bg=gsc.base_color,
      },
      w.screen_layouts and {
        widget=w.screen_layouts,
      },
      {
        widget=w.netctl
      },
      w.backlight and {
        widget=w.backlight,
      },
    },
    callback_on_open = function()
      if w.backlight then w.backlight.Update() end
    end,
  }

  -------------------
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

    local shaped_widget_side_padding =  math.floor(
      (beautiful.panel_widget_spacing or 0)/2 + math.min(
        beautiful.panel_widget_border_radius or 0, (beautiful.basic_panel_height or dpi(18))/3.5
      )
    )
    local function update_taglist_padding(self, t, index, objects) --luacheck: no unused args
      local margin = self:get_children_by_id('margin_role')[1]
      margin.left  = math.floor((beautiful.panel_widget_spacing or 0)/2)
      margin.right = math.floor((beautiful.panel_widget_spacing or 0)/2)
      if beautiful.panel_widget_border_radius and beautiful.panel_widget_border_radius > 0 then
        if index == 1 then
          margin.left = shaped_widget_side_padding
        end
        if index == #objects then
          margin.right = shaped_widget_side_padding
        end
      end
    end
    sw.taglist = awful.widget.taglist{
      screen=s,
      filter=awful.widget.taglist.filter.noempty,
      buttons=sw.taglist.buttons,
      widget_template = {
          {
              {
                  {
                      id     = 'text_role',
                      widget = wibox.widget.textbox,
                  },
                  layout = wibox.layout.fixed.horizontal,
              },
              id     = 'margin_role',
              widget = wibox.container.margin
          },
          id     = 'background_role',
          widget = wibox.container.background,
          create_callback = update_taglist_padding,
          update_callback = update_taglist_padding,
      },
    }

    -- promptbox
    sw.promptbox = awful.widget.prompt()
    sw.promptbox.widget = widgets.common.widget({
      margin = { left = shaped_widget_side_padding, right = shaped_widget_side_padding, },
      show_icon = false,
    })
    sw.promptbox.widget:set_text(nil)
    sw.promptbox.fg = beautiful.panel_widget_fg_warning
    sw.promptbox.bg = beautiful.panel_widget_bg_warning
    sw.promptbox.shape_border_width = beautiful.panel_widget_border_width or 0
    sw.promptbox.shape_clip = true
    sw.promptbox.shape = function(c2, w2, h2)
      return gears.shape.rounded_rect(
        c2, w2, h2, beautiful.panel_widget_border_radius
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
          --awesome_context.menu.instance = awful.menu.clients({
          awesome_context.menu.instance = menu_addon.clients_on_tag({
            theme = {
              width=capi.screen[awful.screen.focused()].workarea.width
            },
            coords = { x=0, y=beautiful.basic_panel_height or dpi(18) }
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

    sw.tasklist = awful.widget.tasklist{
      screen = s,
      filter = tasklist_addon.current_and_minimizedcurrenttags,
      buttons = tasklist_buttons,
      update_function = tasklist_addon.sorted_update,
    }

    if lcarslist_enabled then
      sw.lcarslist = widgets.lcarslist(
        s,
        awful.widget.taglist.filter.noempty,
        tasklist_buttons,
        tasklist_addon.list_update
      )
    end

    -- Textclock
    sw.textclock = wibox.widget.textclock(
      markup.font(
        beautiful.clock_font or beautiful.bold_font or beautiful.font,
        markup.fg(
          beautiful.clock_fg or beautiful.panel_fg or beautiful.fg_normal,
          "%H:%M"
        )
      )
    )
    -- Calendar
    beautiful.calendar_month_padding = dpi(10)
    beautiful.calendar_month_border_color = beautiful.notification_border_color
    beautiful.calendar_month_border_width = beautiful.notification_border_width
    sw.calendar_popup = awful.widget.calendar_popup.month({
      screen=s,
      spacing=dpi(2),
      margin=beautiful.useless_gap*2,
      style_month={
        bg_color = TRANSPARENT,
        border_color = TRANSPARENT,
      },
      style_header={
        bg_color = TRANSPARENT,
        fg_color = beautiful.notification_fg,
      },
      style_weekday={
        bg_color = TRANSPARENT,
        fg_color = beautiful.notification_border_color,
      },
      style_focus={
        shape=function(c2, w2, h2)
          return gears.shape.rounded_rect(
            c2, w2, h2, beautiful.border_radius
          )
        end,
      },
      style_normal={
        bg_color = TRANSPARENT,
        fg_color = beautiful.notification_fg,
      },
    })
    sw.calendar_popup.bg = beautiful.notification_bg
    sw.calendar_popup.border_width = beautiful.notification_border_width
    sw.calendar_popup.border_color = beautiful.notification_border_color or beautiful.border_color_normal
    if beautiful.notification_border_radius then
      sw.calendar_popup.shape = function(c2, w2, h2)
        return gears.shape.rounded_rect(
          c2, w2, h2, beautiful.notification_border_radius+1
        )
      end
      sw.calendar_popup.shape_clip = true
    end
    sw.calendar_popup:attach(sw.textclock, nil, {on_hover=true})

    -- Layoutbox
    sw.layoutbox = widgets.layoutbox({
      screen = s,
      fg = beautiful.widget_layoutbox_bg,
      bg = beautiful.widget_layoutbox_fg,
      --valign = "bottom",
      --bg = theme.color.color8, -- 6
      horizontal = true,
    })


    -- TOOLBAR itself --

    topwibox[si] = awful.wibar({
      position = "top",
      screen = s,
      height = beautiful.panel_height,
      bg=beautiful.panel_bg,
      fg=beautiful.panel_fg,
    })
    --topwibox[s]:set_widget(top_panel_layout)

  end)

  awesome_context.topwibox = topwibox

  return awesome_context
end

return widget_loader
