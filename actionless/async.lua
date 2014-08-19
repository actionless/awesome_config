-- Asynchronous io.popen for Awesome WM.
-- How to use:
-- async.execute('echo hello!', function(str) widget.text = str end)

local awful = require('awful')

-- !!! it should be GLOBAL
async = {}
async.request_table = {}
async.id_counter = 0

-- Returns next tag - unique identifier of the request
local function next_id()
  -- @TODO: add lock?
  async.id_counter = (async.id_counter + 1) % 100000
  return string.format("%d", async.id_counter)
end

-- Sends an asynchronous request for an output of the shell command.
-- @param command Command to be executed and taken output from
-- @param callback Function to be called when the command finishes
-- @return Request ID
function async.execute(command, callback)
  local id = next_id()
  async.request_table[id] = {
    callback = callback,
    table = {}}
  awful.util.spawn_with_shell(string.format(
    [[
  echo async.pipe_multiline_done\(\"%q\", \""$(%s | %s)"\"\) | awesome-client;
    ]],
    id, command:gsub('"','\"'), [[awk 1 ORS='\\\\n' | sed 's/"/\\"/g']]
  )) --:-'")]]))  that beardy smiley is helping my stupid syntax highlighter
  return id
end

function async.pipe_multiline_done(id, str)
  if not async.request_table[id] then return end
  str = str:gsub('\\n','\n')
  async.request_table[id].callback(str)
  async.request_table[id] = nil
end

-- Sends an asynchronous request for an output of the shell command.
-- @param command Command to be executed and taken output from
-- @param callback Function to be called when the command finishes
-- @return Request ID
function async.execute_iter(command, callback)
  local id = next_id()
  async.request_table[id] = {
    callback = callback,
    table = {}}
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
  async.request_table[id].table:insert(line)
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


return async
