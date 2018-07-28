--[[
Licensed under GNU General Public License v2
* (c) 2013,      Luke Bonham
* (c) 2010-2012, Peter Hofmann
--]]

local awful_spawn = require("awful.spawn")

local spawn = {}

function spawn.run_once(cmd)
  local findme = cmd
  local firstspace = cmd:find(" ")
  if firstspace then
    findme = cmd:sub(0, firstspace-1)
  end
  awful_spawn.with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

return spawn
