--[[
 Licensed under GNU General Public License v2
 * (c) 2014, Yauheni Kirylau
--]]

local awful		= require("awful")
local parse		= require("utils.parse")
local dbus = dbus -- luacheck: ignore

local mopidy = {
  player_cmd = 'st -e ncmpcpp'
}

function mopidy.init(args)
  args = args or {} 
  mopidy.music_dir = args.music_dir or os.getenv("HOME") .. "/Music"
  mopidy.host = args.host or "127.0.0.1"
  mopidy.port = args.port or "6600"
  mopidy.password = args.password or [[""]]
  --if not timer_added then
    --helpers.newinterval(2, function() return mopidy.update(args.parse_status) end)
    --timer_added = true
  --end
  dbus.add_match("session", "path='/org/mpris/MediaPlayer2',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged'")
  dbus.connect_signal(
    "org.freedesktop.DBus.Properties",
    function()
      mopidy.update(args.parse_status)
    end)
  mopidy.update()
end
-------------------------------------------------------------------------------
function mopidy.toggle()
  awful.util.spawn_with_shell(
    "mpc toggle || ncmpcpp toggle")
end

function mopidy.next_song()
  awful.util.spawn_with_shell(
    "mpc next || ncmpcpp next")
end

function mopidy.prev_song()
  awful.util.spawn_with_shell(
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

return mopidy
