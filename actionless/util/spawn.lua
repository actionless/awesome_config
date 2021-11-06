local awful_spawn = require("awful.spawn")
local g_string = require("gears.string")

local h_string = require("actionless.util.string")
local h_table = require("actionless.util.table")
local log = require("actionless.util.debug").get_decorated_logger(':RUN_ONCE:')


local spawn = {}

function spawn.run_once(cmd)
  if type(cmd) == "table" then
    cmd = table.concat(cmd, " ")
  end
  log('Going to start "'..cmd..'"...')
  awful_spawn.easy_async_with_shell(
    'ps x | grep -v grep | grep "' .. cmd .. '"',
    function(output, err_output)
      if err_output ~= '' then
        log('ERROR: '..err_output)
        return
      end
      if output ~= '' then
        local pid, _tty, _stat, _time, _command = h_table.unpack(
            g_string.split(
              h_string.lstrip(
                h_string.rstrip(output, '\n'),
                ' '
              ),
              ' '
            )
          )
        log('"'..cmd..'" is already running with PID '..pid)
      else
        log('Starting "'..cmd..'"...')
        local pid = awful_spawn.spawn(cmd)
        log('Started "'..cmd..'" with PID '..tostring(pid))
      end
    end
  )
end

return spawn
