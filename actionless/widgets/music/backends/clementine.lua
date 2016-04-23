--[[
  Licensed under GNU General Public License v2
   * (c) 2014, Yauheni Kirylau
--]]

local dbus = dbus -- luacheck: ignore
local awful = require("awful")

local h_table = require("utils.table")
local parse = require("utils.parse")


local dbus_cmd = "qdbus org.mpris.MediaPlayer2.clementine "

local clementine = {
  player_status = {},
  player_cmd = 'clementine'
}

function clementine.init(widget)
  dbus.add_match("session", "path='/org/mpris/MediaPlayer2',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged'")
  dbus.connect_signal(
    "org.freedesktop.DBus.Properties",
    function()
      widget.update(clementine.update)
    end)
end
-------------------------------------------------------------------------------
function clementine.toggle()
  awful.spawn.with_shell(dbus_cmd .. "/org/mpris/MediaPlayer2 PlayPause")
end

function clementine.next_song()
  awful.spawn.with_shell(dbus_cmd .. "/org/mpris/MediaPlayer2 Next")
end

function clementine.prev_song()
  awful.spawn.with_shell(dbus_cmd .. "/org/mpris/MediaPlayer2 Previous")
end
-------------------------------------------------------------------------------
function clementine.update(parse_status_callback)
  local callback = function(str) clementine.post_update(str, parse_status_callback) end
  awful.spawn.easy_async(
    dbus_cmd .. " /org/mpris/MediaPlayer2 PlaybackStatus",
    callback
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
    awful.spawn.easy_async(
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
