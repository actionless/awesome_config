--[[
  Licensed under GNU General Public License v2
   * (c) 2014, Yauheni Kirylau
--]]

local dbus = dbus
local awful = require("awful")

local h_table = require("utils.table")
local h_string = require("utils.string")
local parse = require("utils.parse")


-- @TODO: change to native dbus implementation instead of calling qdbus
local dbus_cmd = "qdbus org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player."

local spotify = {
  player_status = {},
  player_cmd = 'spotify'
}

function spotify.init(widget)
  dbus.add_match("session", "path='/org/mpris/MediaPlayer2',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged'")
  dbus.connect_signal(
    "org.freedesktop.DBus.Properties",
    function()
      widget.update()
    end)
end

-------------------------------------------------------------------------------
function spotify.toggle()
  awful.spawn.with_shell(dbus_cmd .. "PlayPause")
end

function spotify.next_song()
  awful.spawn.with_shell(dbus_cmd .. "Next")
end

function spotify.prev_song()
  awful.spawn.with_shell(dbus_cmd .. "Previous")
end
-------------------------------------------------------------------------------
function spotify.update(parse_status_callback)
  awful.spawn.easy_async(
    dbus_cmd .. "PlaybackStatus",
    function(str) spotify.post_update(str, parse_status_callback) end
  )
end
-------------------------------------------------------------------------------
function spotify.post_update(result_string, parse_status_callback)
  spotify.player_status = {}
  local state = nil
  if result_string:match("Playing") then
    state = 'play'
  elseif result_string:match("Paused") then
    state = 'pause'
  end
  spotify.player_status.state = state
  if state == 'play' or state == 'pause' then
    awful.spawn.easy_async(
      dbus_cmd .. "Metadata",
      function(str) spotify.parse_metadata(str, parse_status_callback) end
    )
  else
    parse_status_callback(spotify.player_status)
  end
end

function spotify.parse_metadata(result_string, parse_status_callback)
  h_table.merge(spotify.player_status, parse.find_values_in_string(
    result_string,
    "([%w]+): (.*)$",
    { artist='artist',
      title='title',
      album='album',
      date='contentCreated',
      cover_url='artUrl'
    }
  ))
  spotify.player_status.date = h_string.max_length(spotify.player_status.date, 4)
  spotify.player_status.file = 'spotify stream'
  parse_status_callback(spotify.player_status)
end
-------------------------------------------------------------------------------
function spotify.resize_cover(
  player_status, _, output_coverart_path, notification_callback
)
  awful.spawn.with_line_callback(
    string.format(
      "wget %s -O %s",
      player_status.cover_url,
      output_coverart_path
    ),{
    exit=notification_callback
  })
end

return spotify
