--[[
     Licensed under GNU General Public License v2
      * (c) 2014-2021  Yauheni Kirylau
--]]


local wibox = require("wibox")


local module = {}


function module.constraint(args)
  args = args or {}
  local strategy = args.strategy or "exact"
  local result = wibox.container.constraint()
  result:set_strategy(strategy)
  if args.width then
    result:set_width(args.width)
  end
  if args.height then
    result:set_height(args.height)
  end
  if args.widget then
    result:set_widget(args.widget)
  end
  return result
end


return setmetatable(module, { __call = function(_, ...) return module.constraint(...) end })
