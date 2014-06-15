--[[
  Licensed under GNU General Public License v2
   * (c) 2014, Yauheni Kirylau
--]]

local awful = require("awful")

local async = require("actionless.async")
local helpers = require("actionless.helpers")
local parse = require("actionless.parse")


local clementine = {}
clementine.player_status = {}
clementine.cover_path = "/tmp/playercover.png"

function clementine.init(parse_status_callback)
  clementine.parse_status_callback = parse_status_callback
end
-------------------------------------------------------------------------------
function clementine.toggle()
  awful.util.spawn_with_shell(
    "qdbus org.mpris.MediaPlayer2.clementine /org/mpris/MediaPlayer2 PlayPause")
end

function clementine.next_song()
  awful.util.spawn_with_shell(
    "qdbus org.mpris.MediaPlayer2.clementine /org/mpris/MediaPlayer2 Next")
end

function clementine.prev_song()
  awful.util.spawn_with_shell(
    "qdbus org.mpris.MediaPlayer2.clementine /org/mpris/MediaPlayer2 Previous")
end
-------------------------------------------------------------------------------
function clementine.update()
  async.execute(
    "qdbus org.mpris.MediaPlayer2.clementine /org/mpris/MediaPlayer2 PlaybackStatus",
    function(str) clementine.post_update(str) end)
end
-------------------------------------------------------------------------------
function clementine.post_update(str)
  clementine.player_status = {}
  local state = nil
  if str:match("Playing") then
    state  = 'play'
  elseif str:match("Paused") then
    state = 'pause'
  end
  clementine.player_status.state = state
  if state == 'play' or state == 'pause'
  then
    async.execute(
      "qdbus org.mpris.MediaPlayer2.clementine /Player GetMetadata",
      function(str) clementine.parse_metadata(str) end)
  else
    clementine.parse_status_callback(clementine.player_status)
  end
end
-------------------------------------------------------------------------------
function clementine.parse_metadata(str)
  local player_status = parse.find_values_in_string(
    str, "([%w]+): (.*)$", {
      file='location',
      artist='artist',
      title='title',
      album='album',
      date='year',
      cover='arturl'})
  helpers.merge(clementine.player_status, player_status)
  clementine.parse_status_callback(clementine.player_status)
end

return clementine
