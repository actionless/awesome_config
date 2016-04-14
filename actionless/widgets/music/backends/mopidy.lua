--[[
 Licensed under GNU General Public License v2
 * (c) 2014, Yauheni Kirylau
--]]

local awful		= require("awful")
local parse		= require("utils.parse")
local helpers		= require("actionless.helpers")
local dbus = dbus -- luacheck: ignore

local mopidy = {}

function mopidy.init(player_widget)
  player_widget = player_widget or {}
  mopidy.player_cmd = player_widget.args.mopidy_player_command or "xterm -e ncmpcpp"
  mopidy.music_dir = player_widget.music_dir or os.getenv("HOME") .. "/Music"
  mopidy.host = player_widget.host or "127.0.0.1"
  mopidy.port = player_widget.port or "6600"
  mopidy.password = player_widget.password or [[""]]
  --if not timer_added then
    --helpers.newinterval(2, function() return mopidy.update(player_widget.parse_status) end)
    --timer_added = true
  --end
  dbus.add_match("session", "path='/org/mpris/MediaPlayer2',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged'")
  dbus.connect_signal(
    "org.freedesktop.DBus.Properties",
    function()
      mopidy.update(player_widget.parse_status)
    end)
  helpers.newinterval(10, function() return mopidy.update(player_widget.parse_status) end)
  mopidy.update(player_widget.parse_status)
end
-------------------------------------------------------------------------------
function mopidy.toggle()
  awful.util.spawn.with_shell(
    "mpc toggle || ncmpcpp toggle")
end

function mopidy.next_song()
  awful.util.spawn.with_shell(
    "mpc next || ncmpcpp next")
end

function mopidy.prev_song()
  awful.util.spawn.with_shell(
    "mpc prev || ncmpcpp prev")
end
-------------------------------------------------------------------------------
function mopidy.update(parse_status_callback)
  awful.spawn.easy_async(
    [[mpc --format "file:%file%
                    Artist:%artist%
                    Title:%title%
                    Album:%album%
                    Date:%date%"
    ]],
  -- "function( -- <==workaround for syntax highlighter :)   @TODO
  function(str) mopidy.parse_metadata(str, parse_status_callback) end)
end
-------------------------------------------------------------------------------
function mopidy.parse_metadata(result_string, parse_status_callback)
  local player_status = {}
  local state = nil

  if result_string:match("%[playing%]") then
    state  = 'play'
  elseif result_string:match("%[paused%]") then
    state = 'pause'
  elseif result_string:match("volume") then
    state = 'stop'
  end

  if state then
    player_status = parse.find_values_in_string(
      result_string, "([%w]+):(.*)$", {
        file='file',
        artist='Artist',
        title='Title',
        album='Album',
        date='Date'})
  end
  player_status.state = state

  parse_status_callback(player_status)
end

function mopidy.resize_cover(_, _, _, notification_callback)
  return notification_callback()
end

return mopidy
