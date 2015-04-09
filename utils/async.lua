--[[
	Licensed under GNU General Public License v2
	20?? Alexander Yakushev
	2014 Yauheni Kirylau
--]]

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
    --"]]-- syntax highlighter fix
    id,
    command:gsub('"','\"'),
    [[awk 1 ORS='\\\\n' | sed 's/"/\\"/g']]
  ))
  return id
end

function async.pipe_multiline_done(id, str)
  if not async.request_table[id] then return end
  str = str:gsub('\\n','\n')
  async.request_table[id].callback(str)
  async.request_table[id] = nil
end

local fd = require("third_party.fd_async")
local nlog = require("utils.debug").nlog
local log = require("utils.debug").log

function async.execute_debug(command, callback)
  --local req = fd.exec.command('bash -c \\"' .. command:gsub('"','\"') .. '\\"')
  local req = fd.exec.command(command)
  function patched_callback(str)
    nlog("TA-DAM!!!")
    result = str:gsub('\\n','\n')
    nlog(result)
    return callback(result)
  end
  req:connect_signal("request::completed", patched_callback)
  req:connect_signal("new::error", log)
  req:connect_signal("new::line", log)
end

function async.execute_ng(command, callback)
  --local req = fd.exec.command('bash -c \\"' .. command:gsub('"','\"') .. '\\"')
  local req = fd.exec.command(command)
  req:connect_signal("request::completed", callback)
end

--local exec = fd.exec.command
--local req1 = exec( 'echo test')
--req1:connect_signal(
  --"request::completed",
  --function(res)
    --print('1.begin')
    --print(res)
    --local req2 = exec( 'echo ' .. res)
    --req2:connect_signal(
      --"request::completed",
      --function(res2)
        --print(res2)
      --end
    --)
    --print('1.end')
  --end
--)

return async
