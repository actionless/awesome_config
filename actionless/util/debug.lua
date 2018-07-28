local inspect = require("actionless.util.inspect")
local naughty = require("naughty")

local debug_module = {}

function debug_module.log(object)
  io.stderr:write(inspect(object)..'\n')
end

function debug_module.nlog(object)
  naughty.notify{
    title="DEBUG",
    text=inspect(object),
    timeout=60,
  }
end

return debug_module
