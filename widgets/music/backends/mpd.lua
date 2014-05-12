--[[
	 Licensed under GNU General Public License v2
	  * (c) 2014, Yauheni Kirylau
--]]

local awful			= require("awful")
local escape_f		= require("awful.util").escape
local string		= { format	= string.format,
					    match	= string.match }

local asyncshell	= require("widgets.asyncshell")

local mpd = {}

function mpd.init(player, player_status)
	mpd.player = player
	mpd.player_status = player_status
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
		'mpc --format "file:%file%\\nArtist:%artist%\\nTitle:%title%\\nAlbum:%album%\\nDate:%date%"',
		function(f) mpd.parse_metadata(f) end)
end
-------------------------------------------------------------------------------
function mpd.parse_metadata(f)
	for line in f:lines() do

		if string.match(line,"%[playing%]") then
			player_status.state  = 'play'
		elseif string.match(line,"%[paused%]") then
			player_status.state = 'pause' end

		k, v = string.match(line, "([%w]+):(.*)$")
		if     k == "file"   then player_status.file   = v
		elseif k == "Artist" then player_status.artist = escape_f(v)
		elseif k == "Title"  then player_status.title  = escape_f(v)
		elseif k == "Album"  then player_status.album  = escape_f(v)
		elseif k == "Date"   then player_status.date   = escape_f(v)
		end

	end
	mpd.player.parse_status()
end
-------------------------------------------------------------------------------
function mpd.resize_cover()
	asyncshell.request(string.format(
		"%s %q %q %d %q",
		cover_script, music_dir, player_status.file, cover_size, default_art),
		function(f) player.show_notification() end)
end

return mpd
