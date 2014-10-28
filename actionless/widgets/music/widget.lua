--[[
  Licensed under GNU General Public License v2
   * (c) 2014, Yauheni Kirylau
--]]

local awful		= require("awful")
local naughty		= require("naughty")
local beautiful		= require("beautiful")
local os		= { getenv	= os.getenv }
local string		= { format	= string.format }
local setmetatable	= setmetatable

local helpers		= require("actionless.helpers")
local h_string		= require("actionless.string")
local common_widget	= require("actionless.widgets.common").widget
local markup		= require("actionless.markup")
local async		= require("actionless.async")

local backend_modules	= require("actionless.widgets.music.backends")
local tag_parser	= require("actionless.widgets.music.tag_parser")


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
  local args = args or {}
  local update_interval = args.update_interval or 2
  local timeout = args.timeout or 5
  local default_art = args.default_art or ""
  local enabled_backends = args.backends
                           or { 'mpd', 'cmus', 'spotify', 'clementine', }
  local cover_size = args.cover_size or 100
  local font = args.font or beautiful.tasklist_font or beautiful.font
  local bg = args.bg or beautiful.panel_bg or beautiful.bg
  local fg = args.fg or beautiful.panel_fg or beautiful.fg
  local artist_color      = beautiful.player_artist or fg or beautiful.fg_normal
  local title_color      = beautiful.player_title or fg or beautiful.fg_normal
  player.widget = common_widget(args)


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
      if cached_backends[backend_id].init then cached_backends[backend_id].init() end
    end
    player.backend = cached_backends[backend_id]
    player.cmd = args.player_cmd or player.backend.player_cmd
  end

  player.use_next_backend()
  helpers.set_map("current player track", nil)

-------------------------------------------------------------------------------
  function player.run_player()
    awful.util.spawn_with_shell(player.cmd)
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
      timeout = timeout
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
    player.update()
  end

  function player.next_song()
    player.backend.next_song()
    player.update()
  end

  function player.prev_song()
    player.backend.prev_song()
    player.update()
  end

  player.widget:connect_signal(
    "mouse::enter", function () player.show_notification() end)
  player.widget:connect_signal(
    "mouse::leave", function () player.hide_notification() end)
  player.widget:buttons(awful.util.table.join(
    awful.button({ }, 1, player.toggle),
    awful.button({ }, 3, function()
      player.use_next_backend()
      player.update({dont_switch_backend=true})
    end),
    awful.button({ }, 5, player.next_song),
    awful.button({ }, 4, player.prev_song)
  ))
-------------------------------------------------------------------------------
  function player.update(args)
    player.backend.update(function(player_status)
        player.parse_status(player_status, args)
    end)
  end
-------------------------------------------------------------------------------
  function player.parse_status(player_status, args)
    args = args or {}
    local dont_switch_backend = args.dont_switch_backend or false
    player_status = tag_parser.predict_missing_tags(player_status)
    player.player_status = player_status

    local artist = ""
    local title = ""

    if player_status.state == "play" then
      -- playing
      artist = player_status.artist or "playing"
      title = player_status.title or " "
      player.widget:set_icon('music_play')
      if #artist + #title > 60 then
        if #artist > 25 then
          artist = h_string.max_length(artist, 15) .. "…"
        end
        if #player_status.title > 35 then
          title = h_string.max_length(title, 25) .. "…"
        end
      end
      artist = h_string.escape(artist)
      title = h_string.escape(title)
      -- playing new song
      if player_status.title ~= helpers.get_map("current player track") then
        helpers.set_map("current player track", player_status.title)
        player.resize_cover()
      end
    elseif player_status.state == "pause" then
      -- paused
      artist = enabled_backends[backend_id]
      title  = "paused"
      --@TODO: can it be safely deleted? :
      --helpers.set_map("current player track", nil)
      player.widget:set_icon('music_pause')
    else
      -- stop
      helpers.set_map("current player track", nil)
      if not dont_switch_backend then player.use_next_backend() end
    end

    if player_status.state == "play" or player_status.state == "pause" then
      artist = markup.fg.color(artist_color, artist)
      --player.widget:set_bg(bg)
      --player.widget:set_fg(fg)
      player.widget:set_markup(
        markup.font(font,
           " " ..
          (beautiful.panel_enbolden_details
            and markup.bold(artist)
            or artist)
          .. " " ..
          markup.fg.color(title_color,
            title)
          .. " ")
      )
    else
      if beautiful.show_widget_icon then
        player.widget:set_icon('music_stop')
        player.widget:set_text('')
      else
        player.widget:set_text('(m)')
      end
      --player.widget:set_bg(fg)
      --player.widget:set_fg(bg)
    end
  end
-------------------------------------------------------------------------------
function player.resize_cover()
  -- backend supports it:
  if player.backend.resize_cover then
    return player.backend.resize_cover(
      player.player_status, cover_size, player.cover,
      function()
        player.show_notification()
      end
    )
  end
  -- fallback:
  local resize = string.format('%sx%s', cover_size, cover_size)
  if not player.player_status.cover then
    player.player_status.cover = default_art
  end
  async.execute(
    string.format(
      [[convert %q -thumbnail %q -gravity center -background "none" -extent %q %q]],
      player.player_status.cover,
      resize,
      resize,
      player.cover
    ),
    function(f) player.show_notification() end
  )
end
-------------------------------------------------------------------------------
  helpers.newtimer("player", update_interval, player.update)
  return setmetatable(player, { __index = player.widget })
end

return setmetatable(
  player,
  { __call = function(_, ...)
      return worker(...)
    end
  }
)
