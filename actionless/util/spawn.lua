--[[
Licensed under GNU General Public License v2
* (c) 2013,      Luke Bonham
* (c) 2010-2012, Peter Hofmann
--]]

local awful_spawn = require("awful.spawn")

local spawn = {}

function spawn.run_once(cmd)
  if type(cmd) == "table" then
    cmd = table.concat(cmd, " ")
  end
  awful_spawn.with_shell('ps x | grep -v grep | grep "'..cmd..'" || '..cmd)
end

return spawn
