--[[
 Licensed under GNU General Public License v2
 * (c) 2014, Yauheni Kirylau
--]]

local awful		= require("awful")
local string		= { format	= string.format,
                            match	= string.match }

local parse		= require("actionless.parse")
local async		= require("actionless.async")

local blockify = {}

-------------------------------------------------------------------------------
function blockify.toggle()
  awful.util.spawn_with_shell(
    "blockify-dbus toggle")
end

function blockify.next_song()
  awful.util.spawn_with_shell(
    "blockify-dbus next")
end

function blockify.prev_song()
  awful.util.spawn_with_shell(
    "blockify-dbus prev")
end
-------------------------------------------------------------------------------
function blockify.update(parse_status_callback)
  async.execute(
    "blockify-dbus get all",
    function(str)
      blockify.parse_metadata(str, parse_status_callback)
    end
  )
end
-------------------------------------------------------------------------------
function blockify.parse_metadata(result_string, parse_status_callback)
  local player_status = {}
  local state = nil

  if result_string:match("Playing") then
    state  = 'play'
  elseif result_string:match("Paused") then
    state = 'pause'
  end

  if state then
    player_status = parse.find_values_in_string(
      result_string, "([%w]+)%s+= (.*)$", {
        artist='artist',
        title='title',
        album='album',
        cover_url='artUrl',
        date='contentCreated'})
    player_status.file = "spotify stream"
  end
  player_status.state = state

  parse_status_callback(player_status)
end
-------------------------------------------------------------------------------
function blockify.resize_cover(
  player_status, cover_size, default_art, notification_callback
)
  player_status.cover = "/tmp/spotifycover.png"
  async.execute(
    string.format(
      "wget %s -O %s",
      player_status.cover_url,
      player_status.cover
    ),
    function(f) notification_callback() end
  )
end
return blockify
