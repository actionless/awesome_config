local inspect = require("actionless.util.inspect")
local naughty = require("naughty")

local debug_module = {}

local function eprint(text)
  io.stderr:write(text..'\n')
end

function debug_module.log(object)
  eprint(inspect(object))
end

function debug_module.nlog(object)
  local formatted = inspect(object)
  eprint("nlog: " .. formatted)
  naughty.notify{
    title="DEBUG",
    text=formatted,
    timeout=60,
  }
end

return debug_module
