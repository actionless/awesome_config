-- Asynchronous io.popen for Awesome WM.
-- How to use...
-- ...asynchronously:
-- async.execute('wscript -Kiev', function(f) wwidget.text = f:read("*l") end)
-- ...synchronously
-- wwidget.text = async.demand('wscript -Kiev', 5):read("*l") or "Error"

local awful = require('awful')

async = {}
async.request_table = {}
async.id_counter = 0

-- Returns next tag - unique identifier of the request
local function next_id()
  -- @TODO: add lock?
  async.id_counter = (async.id_counter + 1) % 100000
  return string.format("%d", async.id_counter)
end

function async.wait(seconds, callback)
  local id = next_id()
  async.request_table[id] = {callback = callback}
  local req = string.format(
    [[ bash -c 'sleep %s;
       echo "async.deliver_timer(\"%s\")" | awesome-client' 2> /dev/null ]],
    seconds, id)
  awful.util.spawn_with_shell(req, false)
  return id
end

function async.deliver_timer(id)
  async.request_table[id].callback()
  table.remove(async.request_table, id)
end

-- Sends an asynchronous request for an output of the shell command.
-- @param command Command to be executed and taken output from
-- @param callback Function to be called when the command finishes
-- @return Request ID
function async.execute(command, callback)
  local id = next_id()
  async.request_table[id] = {
    callback = callback,
    table = {},
    counter = 1}
  c = async.request_table[id].counter
  awful.util.spawn_with_shell(string.format(
    [[ sh -c '
       %s | while read line; do
         echo "async.pipe_consume(\"%q\", \"$line\")" | awesome-client;
       done
       echo "async.pipe_finish(\"%q\")" | awesome-client;'
    ]],
    string.gsub(command, "'", "'\\''"), id, id
  ))
  return id
end

-- Consumes command's output line by line
-- @param id Request ID
-- @param line The next line of the command's output
function async.pipe_consume(id, line)
  if not async.request_table[id] then return end
  local c = async.request_table[id].counter
  async.request_table[id].table[c] = line
  async.request_table[id].counter = c + 1
end

-- Calls the remembered callback function on the output of the shell
-- command.
-- @param id Request ID
function async.pipe_finish(id)
  if not async.request_table[id] then return end
  async.request_table[id].callback(
    async.request_table[id].table)
  async.request_table[id] = nil
end

------------------------------------------------------------------------------

async.folder = "/tmp/async"
async.file_template = async.folder .. '/req'
-- Create a directory for asynchell response files
os.execute("mkdir -p " .. async.folder)

-- Sends a synchronous request for an output of the command. Waits for
-- the output, but if the given timeout expires returns nil.
-- @param command Command to be executed and taken output from
-- @param timeout Maximum amount of time to wait for the result
-- @return File handler on success, nil otherwise
function async.demand(command, timeout)
  local id = next_id()
  local tmpfname = async.file_template .. id
  local f = io.popen(string.format(
    [[ (%s > %s;  echo async_done) &
       (sleep %s; echo async_timeout) ]],
    command, tmpfname, timeout))
  local result = f:read("*line")
  if result == "async_done" then
    return io.open(tmpfname)
  end
end


return async
