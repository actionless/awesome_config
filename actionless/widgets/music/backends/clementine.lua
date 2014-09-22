--[[
  Licensed under GNU General Public License v2
   * (c) 2014, Yauheni Kirylau
--]]

local awful = require("awful")

local async = require("actionless.async")
local h_table = require("actionless.table")
local parse = require("actionless.parse")


local dbus_cmd = "qdbus org.mpris.MediaPlayer2.clementine "

local clementine = {
  player_status = {},
  player_cmd = 'clementine'
}

-------------------------------------------------------------------------------
function clementine.toggle()
  awful.util.spawn_with_shell(dbus_cmd .. "/org/mpris/MediaPlayer2 PlayPause")
end

function clementine.next_song()
  awful.util.spawn_with_shell(dbus_cmd .. "/org/mpris/MediaPlayer2 Next")
end

function clementine.prev_song()
  awful.util.spawn_with_shell(dbus_cmd .. "/org/mpris/MediaPlayer2 Previous")
end
-------------------------------------------------------------------------------
function clementine.update(parse_status_callback)
  async.execute(
    dbus_cmd .. " /org/mpris/MediaPlayer2 PlaybackStatus",
    function(str) clementine.post_update(str, parse_status_callback) end
  )
end
-------------------------------------------------------------------------------
function clementine.post_update(result_string, parse_status_callback)
  clementine.player_status = {}
  local state = nil
  if result_string:match("Playing") then
    state  = 'play'
  elseif result_string:match("Paused") then
    state = 'pause'
  end
  clementine.player_status.state = state
  if state == 'play' or state == 'pause' then
    async.execute(
      dbus_cmd .. "/Player GetMetadata",
      function(str) clementine.parse_metadata(str, parse_status_callback) end
    )
  else
    parse_status_callback(clementine.player_status)
  end
end
-------------------------------------------------------------------------------
function clementine.parse_metadata(result_string, parse_status_callback)
  local player_status = parse.find_values_in_string(
    result_string,
    "([%w]+): (.*)$",
    { file='location',
      artist='artist',
      title='title',
      album='album',
      date='year',
      cover='arturl'
    }
  )
  h_table.merge(clementine.player_status, player_status)
  parse_status_callback(clementine.player_status)
end

return clementine
