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

local cmus = {
  player_status = {},
}

function cmus.init(args,
                  parse_status_callback, notification_callback)
  local args = args or {} 
  cmus.music_dir = args.music_dir or os.getenv("HOME") .. "/Music"
  cmus.host = args.host or "127.0.0.1"
  cmus.port = args.port or "6600"
  cmus.password = args.password or [[""]]

  cmus.parse_status_callback = parse_status_callback
  cmus.notification_callback = notification_callback
end
-------------------------------------------------------------------------------
function cmus.toggle()
  awful.util.spawn_with_shell(
    "cmus-remote --pause")
end

function cmus.next_song()
  awful.util.spawn_with_shell(
    "cmus-remote --next")
end

function cmus.prev_song()
  awful.util.spawn_with_shell(
    "cmus-remote --prev")
end
-------------------------------------------------------------------------------
function cmus.update()
  async.execute
  (
    "cmus-remote --query",
    function(str)
      cmus.parse_metadata(str)
    end
  )
end
-------------------------------------------------------------------------------
function cmus.parse_metadata(str)
  cmus.player_status = {}
  local state = nil

  if str:match("status playing") then
    state  = 'play'
  elseif str:match("status paused") then
    state = 'pause'
  end

  if state then
    cmus.player_status = parse.find_values_in_string(
      str, "([%w]+) (.*)$", {
        file='file',
        artist='Artist',
        title='Title',
        album='Album',
        date='Date'})
  end
  cmus.player_status.state = state

  cmus.parse_status_callback(cmus.player_status)
end
-------------------------------------------------------------------------------
function cmus.resize_cover(cover_size, default_art)
  async.execute(string.format(
    "%s %q %q %d %q",
    cmus.cover_script,
    cmus.music_dir,
    cmus.player_status.file,
    cover_size,
    default_art),
  function(f) cmus.notification_callback() end)
end

return cmus
