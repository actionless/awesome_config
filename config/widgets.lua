local beautiful = require("beautiful")
local awful = require("awful")
local wibox = require("wibox")

local capi = {
  screen = screen,
  client = client,
}

local widgets = require("actionless.widgets")
local tasklist_addon = require("actionless.tasklist_addon")
local persistent = require("actionless.persistent")


local widget_loader = {}

function widget_loader.init(awesome_context)
  local w = awesome_context.widgets
  local conf = awesome_context.config
  local modkey = awesome_context.modkey

  local lcarslist_enabled = persistent.lcarslist.get()

  local leftwibox = {}
  local topwibox = {}

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
    fg = beautiful.widget_netctl_bg,
    bg = beautiful.widget_netctl_fg,
  })
  -- MUSIC
  w.music = widgets.music.widget({
      update_interval = 5,
      backends = conf.music_players,
      music_dir = conf.music_dir,
      fg = beautiful.widget_music_bg,
      bg = beautiful.panel_bg,
      force_no_bgimage=true,
      horizontal=true,
      left_separators = lcarslist_enabled and {} or { 'arrl' },
      mopidy_player_command = awesome_context.cmds.tmux_run .. "ncmpcpp",
      enable_notifications = false,
      --valign = "bottom",
  })
  -- volume
  if lcarslist_enabled then
    beautiful.apw_bg_color = beautiful.panel_bg
  end
  w.volume = require("third_party/apw/widget")

  -- systray_toggle
  w.systray_toggle = widgets.sneaky_toggle({
      widgets={
        --h_sep,
        --sep_media,

        --wibox.widget.textbox(' '),
        --w.netctl,
        --wibox.widget.textbox(' '),

        --sep_media,
        --h_sep,
      }, enable_sneaky_tray = true,
  })

  -- MEM
  w.mem = widgets.mem({
    update_interval = 2,
    list_length = 20,
    --bg = beautiful.color["6"],
    new_top = awesome_context.new_top,
    horizontal=true,
  })
  -- CPU
  w.cpu = widgets.cpu({
    update_interval = 2,
    list_length = 20,
    new_top = awesome_context.new_top,
    horizontal=true,
  })
  -- Sensor
  --w.temp = widgets.temp({
    --update_interval = 10,
    --sensor = awesome_context.sensor,
    --warning = 75,
    ----bg = beautiful.widget_temp_bg,
    ----fg = beautiful.widget_temp_fg,
  --})
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
  if lcarslist_enabled then
    w.lcars_textclock = widgets.common.decorated({
      widget = awful.widget.textclock("%H:%M"),
      valign = "bottom",
    })
    widgets.calendar:attach(w.lcars_textclock, {fg=beautiful.theme, position="top_left"})
  end
  local markup = require("utils.markup")
  local textclock = awful.widget.textclock(markup.fg(beautiful.xrdb.foreground, "%H:%M"))
  w.textclock = textclock
  widgets.calendar:attach(w.textclock, {fg=beautiful.theme, position="top_right"})


  w.screen = {}
  for s in capi.screen do
    local si = s.index
    w.screen[si] = {}
    local sw = w.screen[si]

    -- CLOSE button
    sw.manage_client = widgets.manage_client(
      {
        screen = s,
        bg = beautiful.widget_close_bg,
        fg = beautiful.widget_close_fg,
        left_separators = lcarslist_enabled and beautiful.widget_close_left_decorators or { ' ', 'arrl', 'sq' },
        right_separators = lcarslist_enabled and beautiful.widget_close_right_decorators or { 'sq', 'arrr' },
        awesome_context = awesome_context,
      }
    )

    -- taglist
    sw.taglist = {}
    sw.taglist.buttons = awful.util.table.join(
      awful.button({		}, 1, awful.tag.viewonly),
      awful.button({ modkey	}, 1, awful.client.movetotag),
      awful.button({		}, 3, awful.tag.viewtoggle),
      awful.button({ modkey	}, 3, awful.client.toggletag)--,
      --awful.button({ }, 4, function()
        --helpers.tag_view_noempty(-1)
      --end),
      --awful.button({ }, 5, function()
        --helpers.tag_view_noempty(1)
      --end)
    )
    sw.taglist = awful.widget.taglist(
        s,
        awful.widget.taglist.filter.noempty,
        sw.taglist.buttons
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
        if c.is_tag then
          return awful.tag.viewonly(c.tag)
        end
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
        --helpers.tag_view_noempty(1, awful.tag.getscreen(t))
      --end),
      --awful.button({		}, 4, function(t)
        --helpers.tag_view_noempty(-1, awful.tag.getscreen(t))
      --end)
    )

    sw.tasklist = awful.widget.tasklist(
      s,
      awful.widget.tasklist.filter.minimizedcurrenttags,
      tasklist_buttons,
      nil,
      tasklist_addon.sorted_update,
      wibox.layout.flex.horizontal()
    )

    if lcarslist_enabled then
      sw.lcarslist = widgets.lcarslist(
        s,
        awful.widget.tasklist.filter.alltags,
        tasklist_buttons,
        nil,
        tasklist_addon.list_update,
        wibox.layout.fixed.vertical()
      )
      -- layoutbox
      sw.layoutbox = widgets.layoutbox({
        screen = s,
        fg = beautiful.widget_layoutbox_fg,
        bg = beautiful.widget_layoutbox_bg,
        --valign = "bottom",
        --bg = theme.color.color8, -- 6
        horizontal = false,
      })
    else
      sw.layoutbox = widgets.layoutbox({
        screen = s,
        fg = beautiful.widget_layoutbox_bg,
        bg = beautiful.widget_layoutbox_fg,
        --valign = "bottom",
        --bg = theme.color.color8, -- 6
        horizontal = true,
      })
    end


    leftwibox[si] = awful.wibox({
      position = "left",
      screen = s,
      --height = beautiful.panel_height,
      width = beautiful.left_panel_width,
    })
    --leftwibox[si]:set_widget(left_panel_layout)
    leftwibox[si].opacity = beautiful.panel_opacity
    leftwibox[si]:set_bg(beautiful.panel_bg)
    leftwibox[si]:set_fg(beautiful.panel_fg)
    leftwibox[si].visible = false

    topwibox[si] = awful.wibox({
      position = "top",
      screen = s,
      height = beautiful.panel_height,
    })
    --topwibox[s]:set_widget(top_panel_layout)
    topwibox[si].opacity = beautiful.panel_opacity
    topwibox[si]:set_bg(beautiful.panel_bg)
    topwibox[si]:set_fg(beautiful.panel_fg)

  end

  awesome_context.topwibox = topwibox
  awesome_context.leftwibox = leftwibox

  return awesome_context
end

return widget_loader
