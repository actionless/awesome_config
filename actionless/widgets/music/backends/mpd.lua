--[[
 Licensed under GNU General Public License v2
 * (c) 2014, Yauheni Kirylau
--]]

local awful		= require("awful")
local gears_timer = require("gears.timer")

local parse		= require("actionless.util.parse")


local mpd = {
  player_cmd = 'st -e ncmpcpp'
}

function mpd.init(args)
  args = args or {}
  mpd.host = args.host or "127.0.0.1"
  mpd.port = args.port or "6600"
  mpd.password = args.password or [[""]]
  gears_timer({
    callback=function() return mpd.update(args.parse_status) end,
    timeout=2,
    autostart=true,
    call_now=true,
  })
end
-------------------------------------------------------------------------------
function mpd.toggle()
  awful.util.spawn.with_shell(
    "mpc toggle || ncmpcpp toggle")
end

function mpd.next_song()
  awful.util.spawn.with_shell(
    "mpc next || ncmpcpp next")
end

function mpd.prev_song()
  awful.util.spawn.with_shell(
    "mpc prev || ncmpcpp prev")
end
-------------------------------------------------------------------------------
function mpd.update(parse_status_callback)
  awful.spawn.easy_async(

    [[mpc --format "file:%file%
                    Artist:%artist%
                    Title:%title%
                    Album:%album%
                    Date:%date%"
    ]],
  -- "function( -- <==workaround for syntax highlighter :)

    function(str) mpd.parse_metadata(str, parse_status_callback) end

  )
end
-------------------------------------------------------------------------------
function mpd.parse_metadata(result_string, parse_status_callback)
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
-------------------------------------------------------------------------------
function mpd.resize_cover(
  player_status, cover_size, default_art, notification_callback
)
  if notification_callback then
    local _, _, _ = player_status, cover_size, default_art
    return notification_callback()
  end
end

return mpd
