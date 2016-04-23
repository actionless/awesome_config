--[[
  Licensed under GNU General Public License v2
   * (c) 2014, Yauheni Kirylau
--]]

local awful		= require("awful")
local wibox	= require("wibox")
local naughty		= require("naughty")
local beautiful		= require("beautiful")
local string		= { format	= string.format }
local setmetatable	= setmetatable

local h_string		= require("utils.string")
local common = require("actionless.widgets.common")
local decorated_widget	= common.decorated
local markup		= require("utils.markup")

local backend_modules	= require("actionless.widgets.music.backends")


-- player infos
local player = {
  id=nil,
  cmd=nil,
  player_status = {
    state=nil,
    title=nil,
    artist=nil,
    album=nil,
    date=nil,
    file=nil
  },
  cover="/tmp/awesome_cover.png"
}


local function worker(args)
  args = args or {}
  player.args = args
  local timeout = args.timeout or 5
  local default_art = args.default_art or ""
  local enabled_backends = args.backends
                           or { 'mpd', 'cmus', 'spotify', 'clementine', }
  local cover_size = args.cover_size or 100
  player.enable_notifications = args.enable_notifications or false
  --player.artist_widget = common_widget(args)
  --player.title_widget = common_widget(args)
  player.artist_widget = wibox.widget.textbox()
  player.title_widget = wibox.widget.textbox()
  player.separator_widget = wibox.widget.textbox("waiting for " .. enabled_backends[1] .. "...")
  args.widgets = {
    --wibox.widget.textbox(' '),
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


  local backend_id = 0
  local cached_backends = {}

  function player.use_next_backend()
  --[[ music player backends:

      backend should have methods:
      * .toggle ()
      * .next_song ()
      * .prev_song ()
      * .update (parse_status_callback)
      optional:
      * .init(args)
      * .resize_cover(coversize, default_art, show_notification_callback)
  --]]
    backend_id = backend_id + 1
    if backend_id > #enabled_backends then backend_id = 1 end
    if backend_id > #cached_backends then
      cached_backends[backend_id] = backend_modules[enabled_backends[backend_id]]
      if cached_backends[backend_id].init then cached_backends[backend_id].init(player) end
    end
    player.backend = cached_backends[backend_id]
    player.cmd = args.player_cmd or player.backend.player_cmd
    player.update()
  end

-------------------------------------------------------------------------------
  function player.run_player()
    awful.spawn.with_shell(player.cmd)
  end
-------------------------------------------------------------------------------
  function player.hide_notification()
    if player.id ~= nil then
      naughty.destroy(player.id)
      player.id = nil
    end
  end
-------------------------------------------------------------------------------
  function player.show_notification()
    local text
    local ps = player.player_status
    player.hide_notification()
    if ps.album or ps.date then
      text = string.format(
        "%s (%s)\n%s",
        ps.album,
        ps.date,
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
    end
    player.id = naughty.notify({
      icon = player.cover,
      title = ps.title,
      text = text,
      timeout = timeout,
      position = beautiful.widget_notification_position,
    })
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

  player.widget:connect_signal(
    "mouse::enter", function () player.show_notification() end)
  player.widget:connect_signal(
    "mouse::leave", function () player.hide_notification() end)
  player.widget:buttons(awful.util.table.join(
    awful.button({ }, 1, player.toggle),
    awful.button({ }, 3, function()
      player.use_next_backend()
      player.show_notification()
    end),
    awful.button({ }, 5, player.next_song),
    awful.button({ }, 4, player.prev_song)
  ))
-------------------------------------------------------------------------------
  function player.update()
    player.backend.update(function(player_status)
        player.parse_status(player_status)
    end)
  end
-------------------------------------------------------------------------------
  function player.parse_status(player_status)
    local artist = ""
    local title = ""
    local old_title = player.player_status.title
    player.player_status = player_status

    if player_status.state == "play" or player_status.state == "pause" then
      -- playing
      artist = player_status.artist or "playing"
      title = player_status.title or " "
      --player.widget:set_icon('music_play')
      --if #artist + #title > 14*10 then
        --if #artist > 14*5 then
          --artist = h_string.max_length(artist, 14*5) .. "…"
        --end
        --if #player_status.title > 14*5 then
          --title = h_string.max_length(title, 14*5) .. "…"
        --end
      --end
      artist = h_string.escape(artist)
      title = h_string.escape(title)
      -- playing new song
      if player_status.title ~= old_title then
        player.resize_cover()
      end
    end
    if player_status.state == "play" then
      player.widget:set_normal()
      --player.separator_widget:set_text("⏵")
      player.separator_widget:set_text("-")
    elseif player_status.state == "pause" then
      -- paused
      --player.widget:set_icon('music_pause')
      --player.widget:set_warning()
      --player.separator_widget:set_text("⏸")
      player.separator_widget:set_text("-")
      player.widget:set_fg(beautiful.panel_fg)
      player.widget:set_bg(beautiful.panel_bg)
    elseif player_status.state == "stop" then
      -- stop
      player.separator_widget:set_text("")
      artist = enabled_backends[backend_id]
      title = "stopped"
      player.widget:set_disabled()
    else
      player.separator_widget:set_text("waiting for " .. enabled_backends[backend_id] .. "...")
      artist = ""
      title = ""
      player.widget:set_disabled()
    end

    --artist = h_string.multiline_limit_word(artist, 14)
    --title = h_string.multiline_limit_word(title, 14)
    player.artist_widget:set_markup(
        beautiful.panel_enbolden_details
          and markup.bold(artist)
          or artist
    )
    player.title_widget:set_markup(title)
  end
-------------------------------------------------------------------------------
function player.resize_cover()
  local notification_callback
  if player.enable_notifications then
    notification_callback = player.show_notification
  else
    notification_callback = function() end
  end
  -- backend supports it:
  if player.backend.resize_cover then
    return player.backend.resize_cover(
      player.player_status, cover_size, player.cover,
      notification_callback
    )
  end
  -- fallback:
  local resize = string.format('%sx%s', cover_size, cover_size)
  if not player.player_status.cover then
    player.player_status.cover = default_art
  end
  awful.spawn.with_line_callback(
    string.format(
      [[convert %q -thumbnail %q -gravity center -background "none" -extent %q %q]],
      player.player_status.cover,
      resize,
      resize,
      player.cover
    ), {
    output_done=notification_callback
  })
end
-------------------------------------------------------------------------------
  player.use_next_backend()
  return setmetatable(player, { __index = player.widget })
end

return setmetatable(
  player,
  { __call = function(_, ...)
      return worker(...)
    end
  }
)
