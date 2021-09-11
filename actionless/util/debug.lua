local inspect = require("actionless.util.inspect")
local naughty = require("naughty")

local debug_module = {}

local function eprint(text)
  io.stderr:write(text..'\n')
end

local function my_inspect(...)
  local args = {...}
  if #args == 0 then return 'nil' end
  local obj = args[1]
  if #args == 1 then
    if type(obj) == 'string' then
      return obj
    end
  else
    obj = args
  end
  return inspect(obj)
end

function debug_module.log(...)
  eprint('[AWESOME_CONFIG] '..my_inspect(...))
end

function debug_module.naughty_log(object)
  local formatted = my_inspect(object)
  eprint("nlog: " .. formatted)
  naughty.notify{
    title="DEBUG",
    text=formatted,
    timeout=60,
  }
end

function debug_module.get_decorated_logger(module_name)
  return function(...)
    eprint('[AWESOME_CONFIG > '..module_name..'] '..my_inspect(...))
  end
end

debug_module.nlog = debug_module.naughty_log

return debug_module
