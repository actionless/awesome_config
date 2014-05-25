--[[
 Licensed under GNU General Public License v2
 * (c) 2014, Yauheni Kirylau
--]]

local awful		= require("awful")
local string		= { format	= string.format,
                            match	= string.match }

local helpers		= require("actionless.helpers")
local parse		= require("actionless.parse")
local async		= require("actionless.async")

local mpd = {
  player_status = {},
  cover_script = helpers.scripts_dir .. "mpdcover"
}

function mpd.init(args,
                  parse_status_callback, notification_callback)
  local args = args or {} 
  mpd.music_dir = args.music_dir or os.getenv("HOME") .. "/Music"
  mpd.host = args.host or "127.0.0.1"
  mpd.port = args.port or "6600"
  mpd.password = args.password or [[""]]

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
  async.execute(
    [[mpc --format "file:%file%
                    Artist:%artist%
                    Title:%title%
                    Album:%album%
                    Date:%date%"]],
  -- "function( -- <==workaround for syntax highlighter :)   @TODO
  function(str) mpd.parse_metadata(str) end)
end
-------------------------------------------------------------------------------
function mpd.parse_metadata(str)
  mpd.player_status = {}
  local state = nil

  if str:match("%[playing%]") then
    state  = 'play'
  elseif str:match("%[paused%]") then
    state = 'pause'
  end

  if state then
    mpd.player_status = parse.find_values_in_string(
      str, "([%w]+):(.*)$", {
        file='file',
        artist='Artist',
        title='Title',
        album='Album',
        date='Dear'})
  end
  mpd.player_status.state = state

  mpd.parse_status_callback(mpd.player_status)
end
-------------------------------------------------------------------------------
function mpd.resize_cover(cover_size, default_art)
  async.execute(string.format(
    "%s %q %q %d %q",
    mpd.cover_script,
    mpd.music_dir,
    mpd.player_status.file,
    cover_size,
    default_art),
  function(f) mpd.notification_callback() end)
end

return mpd
