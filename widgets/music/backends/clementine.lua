--[[
	 Licensed under GNU General Public License v2
	  * (c) 2014, Yauheni Kirylau
--]]

local awful			= require("awful")
local escape_f		= require("awful.util").escape
local string		= { format	= string.format,
					    match	= string.match }

local asyncshell	= require("widgets.asyncshell")

local clementine	= {}

function clementine.init(player, player_status)
	clementine.player = player
	clementine.player_status = player_status
end
-------------------------------------------------------------------------------
function clementine.toggle()
	awful.util.spawn_with_shell(
		"qdbus org.mpris.MediaPlayer2.clementine /org/mpris/MediaPlayer2 PlayPause")
end

function clementine.next_song()
	awful.util.spawn_with_shell(
		"qdbus org.mpris.MediaPlayer2.clementine /org/mpris/MediaPlayer2 Next")
end

function clementine.prev_song()
	awful.util.spawn_with_shell(
		"qdbus org.mpris.MediaPlayer2.clementine /org/mpris/MediaPlayer2 Previous")
end
-------------------------------------------------------------------------------
function clementine.update()
	asyncshell.request(
		"qdbus org.mpris.MediaPlayer2.clementine /org/mpris/MediaPlayer2 PlaybackStatus",
		function(f) clementine.post_update(f) end)
end
-------------------------------------------------------------------------------
function clementine.post_update(f)
	for line in f:lines() do
		if string.match(line,"Playing") then
			clementine.player_status.state  = 'play'
		elseif string.match(line,"Paused") then
			clementine.player_status.state = 'pause' end
	end
	if clementine.player_status.state == 'play'
		or clementine.player_status.state == 'pause'
	then
		asyncshell.request(
			"qdbus org.mpris.MediaPlayer2.clementine /Player GetMetadata",
			function(f) clementine.parse_metadata(f) end)
	else
		clementine.player.parse_status()
	end
end
-------------------------------------------------------------------------------
function clementine.parse_metadata(f)
	for line in f:lines() do
		k, v = string.match(line, "([%w]+): (.*)$")
		if     k == "location" then
			clementine.player_status.file = v:match("^file://(.*)$")
		elseif k == "artist" then clementine.player_status.artist = escape_f(v)
		elseif k == "title"  then clementine.player_status.title  = escape_f(v)
		elseif k == "album"  then clementine.player_status.album  = escape_f(v)
		elseif k == "year"   then clementine.player_status.date   = escape_f(v)
		elseif k == "arturl" then
			clementine.player_status.cover	= v:match("^file://(.*)$")
		end
	end
	clementine.player.parse_status()
end
-------------------------------------------------------------------------------
function clementine.resize_cover()
	asyncshell.request(string.format(
		[[convert "%q" -thumbnail "%q" -gravity center -background "none" -extent "%q" "%q"]],
		clementine.player_status.cover, resize, resize, clementine.player.cover),
		function(f) clementine.player.show_notification() end)
end

return clementine
