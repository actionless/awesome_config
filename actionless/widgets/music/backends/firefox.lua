--[[
  Licensed under GNU General Public License v2
   * (c) 2020, Yauheni Kirylau
--]]

local mpris_creator = require("actionless.widgets.music.mpris_creator")

return mpris_creator.create_for_match('firefox', {seek=30})
