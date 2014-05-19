-- Asynchronous io.popen for Awesome WM.
-- How to use...
-- ...asynchronously:
-- asyncshell.request('wscript -Kiev', function(f) wwidget.text = f:read("*l") end)
-- ...synchronously
-- wwidget.text = asyncshell.demand('wscript -Kiev', 5):read("*l") or "Error"

local awful = require('awful')

asyncshell = {}
asyncshell.request_table = {}
asyncshell.id_counter = 0

-- Returns next tag - unique identifier of the request
local function next_id()
  -- @TODO: add lock?
  asyncshell.id_counter = (asyncshell.id_counter + 1) % 100000
  return string.format("%d", asyncshell.id_counter)
end

function asyncshell.wait(seconds, callback)
  local id = next_id()
  asyncshell.request_table[id] = {callback = callback}
  local req = string.format(
    [[ bash -c 'sleep %s;
       echo "asyncshell.deliver_timer(\"%s\")" | awesome-client' 2> /dev/null ]],
    seconds, id)
  awful.util.spawn_with_shell(req, false)
  return id
end

function asyncshell.deliver_timer(id)
  asyncshell.request_table[id].callback()
  table.remove(asyncshell.request_table, id)
end

-- Sends an asynchronous request for an output of the shell command.
-- @param command Command to be executed and taken output from
-- @param callback Function to be called when the command finishes
-- @return Request ID
function asyncshell.request(command, callback)
  local id = next_id()
  asyncshell.request_table[id] = {
    callback = callback,
    table = {},
    counter = 1}
  c = asyncshell.request_table[id].counter
  awful.util.spawn_with_shell(string.format(
    [[ sh -c '
       %s | while read line; do
         echo "asyncshell.pipe_consume(\"%q\", \"$line\")" | awesome-client;
       done
       echo "asyncshell.pipe_finish(\"%q\")" | awesome-client;'
    ]],
    string.gsub(command, "'", "'\\''"), id, id
  ))
  return id
end

-- Consumes command's output line by line
-- @param id Request ID
-- @param line The next line of the command's output
function asyncshell.pipe_consume(id, line)
  local c = asyncshell.request_table[id].counter
  asyncshell.request_table[id].table[c] = line
  asyncshell.request_table[id].counter = c + 1
end

-- Calls the remembered callback function on the output of the shell
-- command.
-- @param id Request ID
function asyncshell.pipe_finish(id)
  local output = asyncshell.request_table[id].table
  asyncshell.request_table[id].callback(output)
  table.remove(asyncshell.request_table, id)
end

------------------------------------------------------------------------------

asyncshell.folder = "/tmp/asyncshell"
asyncshell.file_template = asyncshell.folder .. '/req'
-- Create a directory for asynchell response files
os.execute("mkdir -p " .. asyncshell.folder)

-- Sends a synchronous request for an output of the command. Waits for
-- the output, but if the given timeout expires returns nil.
-- @param command Command to be executed and taken output from
-- @param timeout Maximum amount of time to wait for the result
-- @return File handler on success, nil otherwise
function asyncshell.demand(command, timeout)
  local id = next_id()
  local tmpfname = asyncshell.file_template .. id
  local f = io.popen(string.format(
    [[ (%s > %s;  echo asyncshell_done) &
       (sleep %s; echo asyncshell_timeout) ]],
    command, tmpfname, timeout))
  local result = f:read("*line")
  if result == "asyncshell_done" then
    return io.open(tmpfname)
  end
end


return asyncshell
