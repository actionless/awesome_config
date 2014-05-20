--[[
  Licensed under GNU General Public License v2
   * (c) 2014, Yauheni Kirylau
--]]

local awful		= require("awful")

local async	= require("actionless.async")
local helpers           = require("actionless.helpers")


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
    function(f) clementine.post_update(f) end)
end
-------------------------------------------------------------------------------
function clementine.post_update(lines)
  local state = nil
  if helpers.find_in_lines(lines, "Playing") then
    state  = 'play'
  elseif helpers.find_in_lines(lines, "Paused") then
    state = 'pause'
  end
  clementine.player_status.state = state
  if state == 'play' or state == 'pause'
  then
    async.execute(
      "qdbus org.mpris.MediaPlayer2.clementine /Player GetMetadata",
      function(f) clementine.parse_metadata(f) end)
  else
    clementine.parse_status_callback(clementine.player_status)
  end
end
-------------------------------------------------------------------------------
function clementine.parse_metadata(lines)
  local player_status = helpers.find_values_in_lines(
    lines, "([%w]+): (.*)$", {
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
