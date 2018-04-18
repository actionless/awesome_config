--[[
  Licensed under GNU General Public License v2
   * (c) 2014, Yauheni Kirylau
--]]

local dbus = dbus -- luacheck: ignore
local awful = require("awful")

local h_table = require("actionless.util.table")
local parse = require("actionless.util.parse")


local dbus_cmd = "qdbus org.mpris.MediaPlayer2.gradio "

local gradio = {
  player_status = {},
  player_cmd = 'gradio'
}

--function gradio.init(_widget)
--end
-------------------------------------------------------------------------------
function gradio.toggle()
  awful.spawn.with_shell(dbus_cmd .. "/org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause")
end

function gradio.next_song()
  awful.spawn.with_shell(dbus_cmd .. "/org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next")
end

function gradio.prev_song()
  awful.spawn.with_shell(dbus_cmd .. "/org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous")
end
-------------------------------------------------------------------------------
function gradio.update(parse_status_callback)
  local callback = function(str) gradio.post_update(str, parse_status_callback) end
  awful.spawn.easy_async(
    dbus_cmd .. " /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlaybackStatus",
    callback
  )
end
-------------------------------------------------------------------------------
function gradio.post_update(result_string, parse_status_callback)
  gradio.player_status = {}
  local state = nil
  if result_string:match("Playing") then
    state  = 'play'
  elseif result_string:match("Paused") then
    state = 'pause'
  end
  gradio.player_status.state = state
  if state == 'play' or state == 'pause' then
    awful.spawn.easy_async(
      dbus_cmd .. " /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Metadata",
      function(str) gradio.parse_metadata(str, parse_status_callback) end
    )
  else
    parse_status_callback(gradio.player_status)
  end
end
-------------------------------------------------------------------------------
function gradio.parse_metadata(result_string, parse_status_callback)
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
  h_table.merge(gradio.player_status, player_status)
  parse_status_callback(gradio.player_status)
end
-------------------------------------------------------------------------------
function gradio.resize_cover(
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

return gradio
