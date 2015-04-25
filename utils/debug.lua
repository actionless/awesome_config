local inspect = require("utils.inspect")
local naughty = require("naughty")
local beautiful = require("beautiful")

local debug_module = {}

function debug_module.log(object)
  print(inspect(object))
end

function debug_module.nlog(object)
  naughty.notify{
    title="DEBUG",
    text=inspect(object),
    timeout=60,
  }
end

return debug_module
