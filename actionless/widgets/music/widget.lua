--[[
  Licensed under GNU General Public License v2
   * (c) 2014, Yauheni Kirylau
--]]

local awful		= require("awful")
local wibox	= require("wibox")
local naughty		= require("naughty")
local beautiful		= require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local g_string		= require("gears.string")
local gears_timer = require("gears.timer")

local common = require("actionless.widgets.common")
local decorated_widget	= common.decorated
local markup		= require("actionless.util.markup")
local db = require("actionless.util.db")
local get_icon = require("actionless.util.xdg").get_icon
local log = require("actionless.util.debug").log

local backend_modules	= require("actionless.widgets.music.backends")


local DEBUG_LOG = false
--local DEBUG_LOG = true
local function _log(...)
  if DEBUG_LOG then
    log({"::MUSIC-WIDGET:" ,...})
  end
end


-- player infos
local player = {
  notification_object=nil,
  cmd=nil,
  player_status = {
    state=nil,
    title=nil,
    artist=nil,
    album=nil,
    date=nil,
    file=nil
  },
  old_player_status = {},
  coverart_file_path="/tmp/awesome_cover",
  keys = {'state', 'artist', 'title', 'album', 'cover_art', 'file', 'date'},
}


function player.init(args)
  args = args or {}
  player.args = args
  args.spacing = 0
  local update_interval = args.update_interval or 10
  local timeout = args.popup_timeout or 5
  local default_art = args.default_art
  local enabled_backends = args.backends
                           or { 'mpd', 'cmus', 'spotify', 'clementine', }
  local cover_size = args.cover_size or 100
  player.enable_notifications = args.enable_notifications or false
  player.icon_widget = common.widget({margin={
    left=beautiful.show_widget_icon and dpi(4) or 0,
    right=beautiful.show_widget_icon and dpi(4) or 0
  }})
  player.artist_widget = wibox.widget.textbox()
  player.separator_widget = wibox.widget.textbox("loading...")
  player.title_widget = common.widget({margin={right=beautiful.show_widget_icon and dpi(4) or 0}})
  args.widgets = {
    --wibox.widget.textbox(' '),
    beautiful.show_widget_icon and player.icon_widget or wibox.widget.textbox(''),
    player.artist_widget,
    --common.constraint({
      --height = beautiful.panel_padding_bottom * 2,
      --width = beautiful.panel_padding_bottom * 2,
    --}),
    player.separator_widget,
    player.title_widget,
    --wibox.widget.textbox(' '),
  }
  player.widget = decorated_widget(args)


  local backend_id = db.get_or_set("widget_music_backend", 1)
  local cached_backends = {}

  dbus.add_match(
    "session",
    "path='/org/mpris/MediaPlayer2',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged'"
  )
  dbus.connect_signal(
    "org.freedesktop.DBus.Properties",
    function()
      player.update("dbus_properties")
    end
  )

  function player.use_next_backend(args_here)
  --[[ music player backends:

      backend should have methods:
      * .toggle ()
      * .next_song ()
      * .prev_song ()
      * .update (parse_status_callback)
      optional:
      * .init(args)
      * .get_coverart(coversize, default_art, show_notification_callback)
  --]]
    args_here = args_here or {}
    local index = args_here.relative_index or 1
    backend_id = args_here.backend_id or (backend_id + index)

    if backend_id > #enabled_backends then backend_id = 1 end
    if not cached_backends[backend_id] then
      cached_backends[backend_id] = backend_modules[enabled_backends[backend_id]]
      if cached_backends[backend_id].init then cached_backends[backend_id].init(player) end
    end
    if (
        not args_here.is_startup
        and player.backend
        and player.backend.name == cached_backends[backend_id].name
        and cached_backends[backend_id].next_instance
    ) then
      cached_backends[backend_id].next_instance()
    end
    player.backend = cached_backends[backend_id]
    player.cmd = args.player_cmd or player.backend.player_cmd
    player.parse_status(player.player_status, player.backend, true)
    player._update_timer = gears_timer({
      callback=function()
        player._update_timer:stop()
        player.update("timer")
        player._update_timer.timeout = player.backend.update_interval or update_interval
        player._update_timer:start()
      end,
      timeout=(player.backend.update_interval or update_interval),
      autostart=true,
      call_now=false,
    })
    player.update(args_here.is_startup and "init" or "backend_change")
    db.set('widget_music_backend', backend_id)
  end

-------------------------------------------------------------------------------
  function player.get_coverart_path()
    local ps = player.player_status
    if ps.cover_url then
      return player.coverart_file_path..'_'..enabled_backends[backend_id]..'_'..(ps.cover_url:gsub('/', '_') or ".png")
    end
  end
-------------------------------------------------------------------------------
  function player.run_player()
    awful.spawn.with_shell(player.cmd)
    player._update_timer.timeout = 1
    player._update_timer:again()
  end
-------------------------------------------------------------------------------
  function player.hide_notification()
    if player.notification_object ~= nil then
      naughty.destroy(player.notification_object)
      player.notification_object = nil
    end
  end
-------------------------------------------------------------------------------
  function player.show_notification()
    local text
    local ps = player.player_status
    player.hide_notification()
    if ps.album or ps.date then
      text = string.format(
        --"<i>from</i> %s%s\n<i>by</i> %s",
        "from <b>%s</b>%s\nby <b>%s</b>",
        ps.album,
        ps.date and " ("..ps.date..")" or "",
        ps.artist
      )
    elseif ps.artist then
      text = string.format(
        "by <b>%s</b>\nat %s",
        ps.artist,
        ps.file or enabled_backends[backend_id]
      )
    else
      text = enabled_backends[backend_id]
      if ps.state == nil then
        text = "waiting for " .. text .. "…"
      else
        text = "at " .. text
      end
    end
    local cover_url = ps.cover_url
    if not cover_url then
      cover_url = default_art
    else
      if g_string.startswith(cover_url, 'file://') then
        cover_url = string.sub(cover_url, 8)
      end
      if not g_string.startswith(cover_url, '/') then
        cover_url = player.get_coverart_path()
      end
    end

    if not player.notification_object then
      player.notification_object = naughty.notification({
        timeout = timeout,
        position = beautiful.widget_notification_position,
      })
    end
    player.notification_object.icon = cover_url
    player.notification_object.title = ps.title or ''
    player.notification_object.message = text
  end
-------------------------------------------------------------------------------
  function player.toggle()
    if player.player_status.state ~= 'pause'
      and player.player_status.state ~= 'play'
      and player.player_status.state ~= 'stop'
    then
      player.run_player()
      return
    end
    player.backend.toggle()
  end

  function player.next_song()
    player.backend.next_song()
  end

  function player.prev_song()
    player.backend.prev_song()
  end

  function player.seek()
    if player.backend.seek then
      player.backend.seek()
    else
      naughty.notification({
        title = 'music widget error',
        text = enabled_backends[backend_id] .. " not supports Seek",
        timeout = timeout,
        position = beautiful.widget_notification_position,
        urgency='critical',
      })
    end
  end

  function player.backend_menu()
    if player.menu and player.menu.wibox.visible then
      player.menu:hide()
    else
      local items = {}
      for each_backend_id, backend_name in ipairs(enabled_backends) do
        local display_name = backend_name
        local backend = backend_modules[backend_name]
        if backend.instances and (#(backend.instances) > 0) then
          for instance_idx, v in pairs(backend.instances) do
            local instance_display_name = display_name
            if (v.player_status ~= nil) and (v.player_status.title) then
              local instance_base_display_name
              if v.name:match(".instance") then
                instance_base_display_name = string.gsub(v.name, ".instance", "(") ..")"
              else
                instance_base_display_name = v.name
              end
              instance_display_name = instance_base_display_name ..": ".. v.player_status.title
            end
            local item = {instance_display_name, }
            item[2] = function()
              player.use_next_backend{backend_id=each_backend_id}
              player.backend.next_instance(instance_idx)
              player.menu:hide()
              --player.show_notification()
            end
            if (
                player.backend == backend_modules[backend_name]
            ) and (
                player.backend.current_instance_idx == instance_idx
            ) then
              item[3] = get_icon('actions', 'object-select-symbolic')
            end
            table.insert(items, item)
          end
        else
          if (backend.player_status ~= nil) and (backend.player_status.title) then
            display_name = display_name ..": ".. backend.player_status.title
          end
          local item = {display_name, }
          item[2] = function()
            player.use_next_backend{backend_id=each_backend_id}
            player.menu:hide()
            --player.show_notification()
          end
          if player.backend == backend_modules[backend_name] then
            item[3] = get_icon('actions', 'object-select-symbolic')
          end
          table.insert(items, item)
        end
      end
      player.menu = awful.menu{
        items=items,
        theme={
          width=dpi(420),
        },
      }
      player.menu:show()
    end
  end

  player.widget:connect_signal(
    "mouse::enter", function () player.show_notification() end)
  player.widget:connect_signal(
    "mouse::leave", function () player.hide_notification() end)

  player.widget:buttons(awful.util.table.join(
    awful.button({ }, 1, function()
      for _, w in ipairs(mouse.current_widgets) do
        if w == player.icon_widget then
          return
        end
      end
      player.toggle()
    end),
    awful.button({ }, 2, player.seek),
    awful.button({ }, 3, player.backend_menu),
    awful.button({ }, 5, player.next_song),
    awful.button({ }, 4, player.prev_song)
  ))
  player.icon_widget:buttons(awful.util.table.join(
    awful.button({ }, 1, player.backend_menu),
    awful.button({ }, 2, player.seek),
    awful.button({ }, 3, player.backend_menu),
    awful.button({ }, 5, player.next_song),
    awful.button({ }, 4, player.prev_song)
  ))

-------------------------------------------------------------------------------
  function player.update(from, callback)
    _log("update from "..from)
    player.backend.update(function(player_status)
        player.parse_status(player_status, player.backend)
        if callback then callback(player_status) end
    end)
  end
-------------------------------------------------------------------------------
  function player.parse_status(player_status, backend, force)
    _log(player.old_player_status)
    _log(player_status)
    if backend ~= player.backend then return end
    local status_updated = force or false
    for _, key in ipairs(player.keys) do
      if player.old_player_status[key] ~= player_status[key] then
        status_updated = true
        break
      end
    end
    if not status_updated then
      _log("state not changed")
      return
    end

    local artist = ""
    local title = ""
    local old_title = player.player_status.title

    player.player_status = player_status
    for _, key in ipairs(player.keys) do
      player.old_player_status[key] = player_status[key]
    end

    if (
        player_status.state == "play" or
        player_status.state == "pause" or
        player_status.state == "stop"
    ) then
      -- playing
      artist = player_status.artist or (player_status.title and '' or "playing")
      title = player_status.title or ""
      --if #artist + #title > 14*10 then
        --if #artist > 14*5 then
          --artist = h_string.max_length(artist, 14*5) .. "…"
        --end
        --if #player_status.title > 14*5 then
          --title = h_string.max_length(title, 14*5) .. "…"
        --end
      --end
      artist = g_string.xml_escape(artist)
      title = g_string.xml_escape(title)
      -- playing new song
      if player_status.title ~= old_title then
        player.get_coverart()
      end
      player.separator_widget:set_text(
        player_status.artist and player_status.title and
        " - " or ""
      )
    end
    _log(player_status.state)
    if player_status.state == "play" then
      player.widget:set_normal()
      --player.separator_widget:set_text("⏵")
      player.icon_widget:set_image(beautiful.widget_music_play)
    elseif player_status.state == "pause" then
      -- paused
      --player.widget:set_warning()
      --player.separator_widget:set_text("⏸")
      player.widget:set_color({
        bg=args.pause_bg or beautiful.panel_bg,
        fg=args.pause_fg or beautiful.panel_fg,
      })
      player.icon_widget:set_image(beautiful.widget_music_pause)
    elseif player_status.state == "stop" then
      -- stop
      --player.separator_widget:set_text("")
      artist = artist or enabled_backends[backend_id]
      title = title or "stopped"
      player.widget:set_disabled()
      player.icon_widget:set_image(beautiful.widget_music_stop)
    else
      if beautiful.show_widget_icon then
        player.separator_widget:set_text("")
      else
        player.separator_widget:set_text(" waiting for " .. enabled_backends[backend_id] .. "… ")
      end
      artist = ""
      title = ""
      player.widget:set_disabled()
      player.icon_widget:set_image(beautiful.widget_music_off)
    end

    --artist = h_string.multiline_limit_word(artist, 14)
    --title = h_string.multiline_limit_word(title, 14)
    player.artist_widget:set_markup(
        args.bold_artist
          and markup.bold(artist)
          or artist
    )
    player.title_widget:set_markup(title)

    if player.notification_object then
      player.show_notification()
    end
  end
-------------------------------------------------------------------------------
function player.get_coverart()
  local notification_callback
  local current_backend = player.backend
  if player.enable_notifications or (player.notification_object) then
    notification_callback = function()
      if player.enable_notifications or (
        player.notification_object
      ) and (
        current_backend == player.backend
      ) then
        player.show_notification()
      end
    end
  end
  -- backend supports it:
  if player.backend.get_coverart then
    return player.backend.get_coverart(
      player.player_status, cover_size, player.get_coverart_path(),
      notification_callback
    )
  end
  -- fallback:
  if notification_callback then
    notification_callback()
  end
end
-------------------------------------------------------------------------------
  player.use_next_backend{relative_index=0, is_startup=true}
  return setmetatable(player, { __index = player.widget })
end

return setmetatable(
  player,
  { __call = function(_, ...)
      return player.init(...)
    end
  }
)
