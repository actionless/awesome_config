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

function debug_module._naughty_log(formatted, naughty_args)
  naughty_args = naughty_args or {}
  local default_naughty_args = {
    title="DEBUG",
    text=formatted,
    timeout=60,
  }
  for k, v in pairs(naughty_args) do
    default_naughty_args[k] = v
  end
  eprint("nlog: " .. formatted)
  naughty.notify(default_naughty_args)
end

function debug_module.naughty_log(...)
  local formatted = my_inspect(...)
  debug_module._naughty_log(formatted)
end

function debug_module.naughty_log_eternal(...)
  local formatted = my_inspect(...)
  debug_module._naughty_log(formatted, {timeout=0})
end


function debug_module.get_decorated_logger(module_name)
  return function(...)
    eprint('[AWESOME_CONFIG > '..module_name..'] '..my_inspect(...))
  end
end

debug_module.nlog = debug_module.naughty_log
debug_module.nloge = debug_module.naughty_log_eternal

return debug_module
