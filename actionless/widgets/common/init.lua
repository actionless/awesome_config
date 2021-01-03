--[[
     Licensed under GNU General Public License v2
      * (c) 2014-2021  Yauheni Kirylau
--]]


local decorated = require('actionless.widgets.common.decorated')
local shape = require('actionless.widgets.common.shape')

local common = {
  constraint = require('actionless.widgets.common.constraint'),
  decorated = decorated,
  decorated_horizontal = decorated.horizontal,
  decorated_vertical = decorated.vertical,
  panel_widget_shape = shape.panel_widget_shape,
  set_panel_widget_shape = shape.set_panel_widget_shape,
  text_progressbar = require('actionless.widgets.common.progressbar'),
  widget = require('actionless.widgets.common.widget'),
}

return common
