--[[
  Licensed under GNU General Public License v2
   * (c) 2014, Yauheni Kirylau
--]]

local dbus = dbus
local awful = require("awful")

local h_table = require("utils.table")
local h_string = require("utils.string")
local parse = require("utils.parse")

local lgi = require 'lgi'
local Gio = lgi.require 'Gio'
--local inspect = require("inspect")

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
    function(...)
      widget.update()
    end)
end

-------------------------------------------------------------------------------
function spotify.toggle()
  awful.util.spawn_with_shell(dbus_cmd .. "PlayPause")
end

function spotify.next_song()
  awful.util.spawn_with_shell(dbus_cmd .. "Next")
end

function spotify.prev_song()
  awful.util.spawn_with_shell(dbus_cmd .. "Previous")
end
-------------------------------------------------------------------------------
--{{  @TODO: temporary workaround:
local gears = require("gears")
local timer_added = false
--}}
function spotify.update(parse_status_callback)
  local callback = function(str) spotify.post_update(str, parse_status_callback) end
  --awful.util.spawn_with_line_callback(
    --dbus_cmd .. "PlaybackStatus",
    --callback, callback
  --)

  --{{  @TODO: temporary workaround:
  if not timer_added then
    gears.timer.start_new(2, function() callback("Playing") return true end)
    timer_added = true
  end
  return callback("Playing")
  --}}
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
    awful.util.spawn_with_line_callback(
      dbus_cmd .. "Metadata",
      function(str) spotify.parse_metadata_line(str) end,
      function(str) spotify.post_update("Unknown", parse_status_callback) end,
      function() spotify.parse_metadata_done(parse_status_callback) end
    )
  else
    parse_status_callback(spotify.player_status)
  end
end

function spotify.parse_metadata_line(result_line)
  local player_status = parse.find_values_in_string(
    result_line,
    "([%w]+): (.*)$",
    { artist='artist',
      title='title',
      album='album',
      date='contentCreated',
      cover_url='artUrl'
    }
  )
  h_table.merge(spotify.player_status, player_status)
end

function spotify.parse_metadata_done(parse_status_callback)
  spotify.player_status.date = h_string.max_length(spotify.player_status.date, 4)
  spotify.player_status.file = 'spotify stream'
  parse_status_callback(spotify.player_status)
end
-------------------------------------------------------------------------------
function spotify.resize_cover(
  player_status, _, output_coverart_path, notification_callback
)
  awful.util.spawn_with_line_callback(
    string.format(
      "wget %s -O %s",
      player_status.cover_url,
      output_coverart_path
    ),
    nil,
    nil,
    function() notification_callback() end
  )
end

return spotify
