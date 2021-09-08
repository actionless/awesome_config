local awful_spawn = require("awful.spawn")

local log = require("actionless.util.debug").log


local spawn = {}

function spawn.run_once(cmd)
  if type(cmd) == "table" then
    cmd = table.concat(cmd, " ")
  end
  log('::RUN_ONCE: Going to start "'..cmd..'"...')
  awful_spawn.with_shell(
    'ps x | grep -v grep | grep "' .. cmd ..
    '" || ('..cmd..' & echo "Started \\"'..cmd..'\\" with PID $!")'
  )
end

return spawn
