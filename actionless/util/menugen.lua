---------------------------------------------------------------------------
-- @author Harvey Mittens
-- @copyright 2014 Harvey Mittens
-- @email teknocratdefunct@riseup.net
-- @release v3.5.5
---------------------------------------------------------------------------

local awesome_menu_gen = require("menubar.menu_gen")
local awesome_menu_utils = require("menubar.utils")

local menugen = {}

--Expecting an wm_name of awesome omits too many applications and tools
awesome_menu_utils.wm_name = ""

-- Use MenuBar Parsing Utils to build StartMenu for Awesome
-- @return callback
-- @param callback.menulist awful.menu compliant menu items tree
function menugen.build_menu(callback)
  awesome_menu_gen.generate(function(menulist)

    local result = {}
    for k, v in pairs(awesome_menu_gen.all_categories) do
            table.insert(result, {k, {}, v["icon"] } )
    end

    for _, v in ipairs(menulist) do
            for _, cat in ipairs(result) do
                    if cat[1] == v["category"] then
                            table.insert( cat[2] , { v["name"], v["cmdline"], v["icon"] } )
                            break
                    end
            end
    end

    -- Cleanup Things a Bit
    for k,v in ipairs(result) do
            -- Remove Unused Categories
            if not next(v[2]) then
                    table.remove(result, k)
            else
                    --Sort entries Alphabetically (by Name)
                    table.sort(v[2], function (a,b) return string.byte(a[1]) < string.byte(b[1]) end)
                    -- Replace Catagory Name with nice name
                    v[1] = awesome_menu_gen.all_categories[v[1]].name
            end
    end

    --Sort Categories Alphabetically Also
    table.sort(result, function(a,b) return string.byte(a[1]) < string.byte(b[1]) end)

    callback(result)
  end)
end

return menugen
