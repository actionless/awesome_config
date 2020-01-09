--[[
  Licensed under GNU General Public License v2
   * (c) 2020, Yauheni Kirylau
--]]

local spawn = require("awful.spawn")

local mpris_creator = require("actionless.widgets.music.mpris_creator")


local headset = mpris_creator('headset')

function headset.seek()
  spawn.with_shell(
    headset.dbus_prefix .. "/org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Seek 60000000"
  )
end

return headset
