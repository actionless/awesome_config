--[[
  Licensed under GNU General Public License v2
   * (c) 2014-2020, Yauheni Kirylau
--]]

local mpris_creator = require("actionless.widgets.music.mpris_creator")

local spotify = mpris_creator('spotify')

local orig_parse_metadata = spotify.parse_metadata
function spotify.parse_metadata(result, parse_status_callback)
  -- Spotify client for Linux as usually sucks HUGE dicks:
  -- https://community.spotify.com/t5/Desktop-Linux/MPRIS-cover-art-url-file-not-found/td-p/4920104
  if result['mpris:artUrl'] ~= nil then
    result['mpris:artUrl'] = result['mpris:artUrl']:gsub('https://open.spotify.com/image/', 'https://i.scdn.co/image/')
  end
  return orig_parse_metadata(result, parse_status_callback)
end

return spotify
