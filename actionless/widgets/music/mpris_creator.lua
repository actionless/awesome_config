--[[
  Licensed under GNU General Public License v2
   * (c) 2020, Yauheni Kirylau
--]]

local dbus = dbus -- luacheck: ignore
local awful = require("awful")

local h_table = require("actionless.util.table")
local parse = require("actionless.util.parse")


local function create(name, args)
  args = args or {}
  local cmd = args.cmd or name

  local dbus_cmd = "qdbus org.mpris.MediaPlayer2."..name.." "

  local backend = {
    player_status = {},
    player_cmd = cmd,
    dbus_prefix = dbus_cmd,
  }

  --function backend.init(_widget)
  --end
  -------------------------------------------------------------------------------
  function backend.toggle()
    awful.spawn.with_shell(dbus_cmd .. "/org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause")
  end

  function backend.next_song()
    awful.spawn.with_shell(dbus_cmd .. "/org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next")
  end

  function backend.prev_song()
    awful.spawn.with_shell(dbus_cmd .. "/org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous")
  end
  -------------------------------------------------------------------------------
  function backend.update(parse_status_callback)
    awful.spawn.easy_async(
      dbus_cmd .. " /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlaybackStatus",
      function(str) backend._post_update(str, parse_status_callback) end
    )
  end
  -------------------------------------------------------------------------------
  function backend._post_update(result_string, parse_status_callback)
    backend.player_status = {}
    local state = nil
    if result_string:match("Playing") then
      state  = 'play'
    elseif result_string:match("Paused") then
      state = 'pause'
    end
    backend.player_status.state = state
    if state == 'play' or state == 'pause' then
      awful.spawn.easy_async(
        dbus_cmd .. " /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Metadata",
        function(str) backend.parse_metadata(str, parse_status_callback) end
      )
    else
      parse_status_callback(backend.player_status)
    end
  end
  -------------------------------------------------------------------------------
  function backend.parse_metadata(result_string, parse_status_callback)
    local player_status = parse.find_values_in_string(
      result_string,
      "([%w]+): (.*)$",
      { file='location',
        artist='artist',
        title='title',
        album='album',
        date='year',
        cover_url='artUrl'
      }
    )
    h_table.merge(backend.player_status, player_status)
    parse_status_callback(backend.player_status)
  end
  -------------------------------------------------------------------------------
  function backend.resize_cover(
    player_status, _, output_coverart_path, notification_callback
  )
    awful.spawn.with_line_callback(
      string.format(
        "curl -L -s %s -o %s",
        player_status.cover_url,
        output_coverart_path
      ),{
      exit=notification_callback
    })
  end

  return backend
end

return create
