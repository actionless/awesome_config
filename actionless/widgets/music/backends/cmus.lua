--[[
 Licensed under GNU General Public License v2
 * (c) 2014, Yauheni Kirylau
--]]

local awful		= require("awful")
local string		= { format	= string.format,
                            match	= string.match }

local parse		= require("actionless.parse")
local async		= require("actionless.async")

local cmus = {
  player_cmd = 'st -e cmus'
}

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
function cmus.update(parse_status_callback)
  async.execute(
    "cmus-remote --query",
    function(str)
      cmus.parse_metadata(str, parse_status_callback)
    end
  )
end
-------------------------------------------------------------------------------
function cmus.parse_metadata(result_string, parse_status_callback)
  local player_status = {}
  local state = nil

  if result_string:match("status playing") then
    state  = 'play'
  elseif result_string:match("status paused") then
    state = 'pause'
  end

  if state then
    player_status = parse.find_values_in_string(
      result_string, "([%w]+) (.*)$", {
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
return cmus
