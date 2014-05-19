--[[
 Licensed under GNU General Public License v2
 * (c) 2014, Yauheni Kirylau
--]]

local awful		= require("awful")
local escape_f  	= require("awful.util").escape
local string		= { format	= string.format,
                            match	= string.match }

local helpers		= require("widgets.helpers")
local asyncshell	= require("widgets.asyncshell")

local mpd = {
  player_status = {},
  cover_script = helpers.scripts_dir .. "mpdcover"
}

function mpd.init(args, default_player_status,
                  parse_status_callback, notification_callback)
  local args = args or {} 
  mpd.music_dir = args.music_dir or os.getenv("HOME") .. "/Music"
  mpd.host = args.host or "127.0.0.1"
  mpd.port = args.port or "6600"
  mpd.password = args.password or [[""]]

  mpd.default_player_status = default_player_status
  mpd.parse_status_callback = parse_status_callback
  mpd.notification_callback = notification_callback
end
-------------------------------------------------------------------------------
function mpd.toggle()
  awful.util.spawn_with_shell(
    "mpc toggle || ncmpcpp toggle || ncmpc toggle || pms toggle")
end

function mpd.next_song()
  awful.util.spawn_with_shell(
    "mpc next || ncmpcpp next || ncmpc next || pms next")
end

function mpd.prev_song()
  awful.util.spawn_with_shell(
    "mpc prev || ncmpcpp prev || ncmpc prev || pms prev")
end
-------------------------------------------------------------------------------
function mpd.update()
  asyncshell.request(
    [[mpc --format "file:%file%
                    Artist:%artist%
                    Title:%title%
                    Album:%album%
                    Date:%date%"]],
  -- "function( -- <==workaround for syntax highlighter :)   @TODO
  function(f) mpd.parse_metadata(f) end)
end
-------------------------------------------------------------------------------
function mpd.parse_metadata(lines)
  for _, line in pairs(lines) do

    if string.match(line,"%[playing%]") then
       mpd.player_status.state  = 'play'
    elseif string.match(line,"%[paused%]") then
       mpd.player_status.state = 'pause'
    end

    k, v = string.match(line, "([%w]+):(.*)$")
    if     k == "file"   then mpd.player_status.file   = v
    elseif k == "Artist" then mpd.player_status.artist = escape_f(v)
    elseif k == "Title"  then mpd.player_status.title  = escape_f(v)
    elseif k == "Album"  then mpd.player_status.album  = escape_f(v)
    elseif k == "Date"   then mpd.player_status.date   = escape_f(v)
    end

  end
  mpd.parse_status_callback(mpd.player_status)
end
-------------------------------------------------------------------------------
function mpd.resize_cover(cover_size, default_art)
  -- @TODO: do we still need it?
  asyncshell.request(string.format(
    "%s %q %q %d %q",
    mpd.cover_script,
    mpd.music_dir,
    mpd.player_status.file,
    cover_size,
    default_art),
  function(f) mpd.notification_callback() end)
end

return mpd
