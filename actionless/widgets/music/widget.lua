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
local h_file = require("actionless.util.file")

local backend_modules	= require("actionless.widgets.music.backends")


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
  local timeout = args.timeout or 5
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
      player.update()
    end
  )

  function player.use_next_backend(index)
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
    index = index or 1
    backend_id = backend_id + index
    if backend_id > #enabled_backends then backend_id = 1 end
    if not cached_backends[backend_id] then
      cached_backends[backend_id] = backend_modules[enabled_backends[backend_id]]
      if cached_backends[backend_id].init then cached_backends[backend_id].init(player) end
    end
    player.backend = cached_backends[backend_id]
    player.cmd = args.player_cmd or player.backend.player_cmd
    player.parse_status(player.player_status, player.backend, true)
    gears_timer({
      callback=player.update,
      timeout=20,
      autostart=true,
      call_now=true,
    })
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
        "%s%s\n%s",
        ps.album,
        ps.date and " ("..ps.date..")" or "",
        ps.artist
      )
    elseif ps.artist then
      text = string.format(
        "%s\n%s",
        ps.artist,
        ps.file or enabled_backends[backend_id]
      )
    else
      text = enabled_backends[backend_id]
      if ps.state == nil then
        text = "waiting for " .. text .. "…"
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
        if not h_file.exists(cover_url) then
          cover_url = nil
        end
      end
    end

    if not player.notification_object then
      player.notification_object = naughty.notification({
        timeout = timeout,
        position = beautiful.widget_notification_position,
      })
    end
    player.notification_object.icon = cover_url
    player.notification_object.title = '<b>'..(ps.title or '')..'</b>'
    player.notification_object.text = text
  end
-------------------------------------------------------------------------------
  function player.toggle()
    if player.player_status.state ~= 'pause'
      and player.player_status.state ~= 'play'
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

  player.widget:connect_signal(
    "mouse::enter", function () player.show_notification() end)
  player.widget:connect_signal(
    "mouse::leave", function () player.hide_notification() end)
  player.widget:buttons(awful.util.table.join(
    awful.button({ }, 1, player.toggle),
    awful.button({ }, 2, player.seek),
    awful.button({ }, 3, function()
      player.use_next_backend()
      player.show_notification()
    end),
    awful.button({ }, 5, player.next_song),
    awful.button({ }, 4, player.prev_song)
  ))
-------------------------------------------------------------------------------
  function player.update()
    for _, key in ipairs(player.keys) do
      player.old_player_status[key] = player.player_status[key]
    end
    player.backend.update(function(player_status)
        player.parse_status(player_status, player.backend)
    end)
  end
-------------------------------------------------------------------------------
  function player.parse_status(player_status, backend, force)
    if backend ~= player.backend then return end
    local status_updated = force or false
    for _, key in ipairs(player.keys) do
      if player.old_player_status[key] ~= player_status[key] then
        status_updated = true
        break
      end
    end
    if not status_updated then return end

    local artist = ""
    local title = ""
    local old_title = player.player_status.title
    player.player_status = player_status

    if player_status.state == "play" or player_status.state == "pause" then
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
      player.separator_widget:set_text(player_status.artist and " - " or "")
    end
    if player_status.state == "play" then
      player.widget:set_normal()
      --player.separator_widget:set_text("⏵")
      player.icon_widget:set_image(beautiful.widget_music_play)
    elseif player_status.state == "pause" then
      -- paused
      --player.widget:set_icon('music_pause')
      --player.widget:set_warning()
      --player.separator_widget:set_text("⏸")
      player.widget:set_color({
        bg=args.pause_bg or beautiful.panel_bg,
        fg=args.pause_fg or beautiful.panel_fg,
      })
      player.icon_widget:set_image(beautiful.widget_music_pause)
    elseif player_status.state == "stop" then
      -- stop
      player.separator_widget:set_text("")
      artist = enabled_backends[backend_id]
      title = "stopped"
      player.widget:set_disabled()
      player.icon_widget:set_image(beautiful.widget_music_stop)
    else
      if beautiful.show_widget_icon then
        player.separator_widget:set_text("")
      else
        player.separator_widget:set_text("waiting for " .. enabled_backends[backend_id] .. "… ")
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
  player.use_next_backend(0)
  return setmetatable(player, { __index = player.widget })
end

return setmetatable(
  player,
  { __call = function(_, ...)
      return player.init(...)
    end
  }
)
