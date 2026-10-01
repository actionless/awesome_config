local surface = require("gears.surface")

local menu_addon = require("actionless.menu_addon")


local menu_gen = {}

menu_gen.all_categories = {}


--- Generate an array of all visible menu entries.
-- @tparam function callback Will be fired when all menu entries were parsed
-- with the resulting list of menu entries as argument.
-- @tparam table callback.entries All menu entries.
-- @staticfct menubar.menu_gen.generate
-- @noreturn
function menu_gen.generate(callback)
  local result = {}
  local items = menu_addon.clients_with_icons_menugen()
  for _, item in ipairs(items) do
    table.insert(result, { name = item[1],
                 cmdline = item[2],
                 icon = item[3] and surface.duplicate_surface(item[3]),
                 category = "none" })
  end

  if callback then
    callback(result)
  end
end

return menu_gen
