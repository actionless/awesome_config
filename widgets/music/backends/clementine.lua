--[[
  Licensed under GNU General Public License v2
   * (c) 2014, Yauheni Kirylau
--]]

local awful		= require("awful")
local escape_f		= require("awful.util").escape

local asyncshell	= require("widgets.asyncshell")
local helpers           = require("widgets.helpers")


local clementine = {}
clementine.player_status = {}
clementine.cover_path = "/tmp/playercover.png"

function clementine.init(default_player_status, parse_status_callback)
  clementine.default_player_status = default_player_status
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
  clementine.player_status = clementine.default_player_status
  asyncshell.request(
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
    asyncshell.request(
      "qdbus org.mpris.MediaPlayer2.clementine /Player GetMetadata",
      function(f) clementine.parse_metadata(f) end)
  else
    clementine.parse_status_callback(clementine.player_status)
  end
end
-------------------------------------------------------------------------------
function clementine.parse_metadata(lines)
--  for _, line in pairs(lines) do
--    k, v = string.match(line, "([%w]+): (.*)$")
--    if     k == "location" then
--      clementine.player_status.file = v:match("^.*://(.*)$")
--    elseif k == "artist" then clementine.player_status.artist = escape_f(v)
--    elseif k == "title"  then clementine.player_status.title  = escape_f(v)
--    elseif k == "album"  then clementine.player_status.album  = escape_f(v)
--    elseif k == "year"   then clementine.player_status.date   = escape_f(v)
--    elseif k == "arturl" then
--      clementine.player_status.cover = v:match("^file://(.*)$")
--    end
--  end
  local player_status = helpers.find_values_in_lines(
    lines, "([%w]+): (.*)$", {
      file='location',
      artist='artist',
      title='title',
      album='album',
      date='year',
      cover='arturl'})
  helpers.dict_merge(clementine.player_status, player_status)
  clementine.parse_status_callback(clementine.player_status)
end

return clementine
