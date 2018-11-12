--[[
Licensed under GNU General Public License v2
* (c) 2013-2014, Yauheni Kirylau
--]]

local wibox = require('wibox')
local awful_widget_keyboardlayout = require("awful.widget.keyboardlayout")

local capi = {
  awesome=awesome
}

local common = require("actionless.widgets.common")

local kbd = {}

local function widget_factory(args)
  args	 = args or {}
  args.orientation = args.orientation or "horizontal"
  local replacements = args.replacements or {us="eng", ["ru(winkeys)"]="rus"}
  local default_layout = args.default_layout or "us"

  args.widget = wibox.widget.textbox()
  kbd.widget = common.panel_shape(common.decorated(args))

  local akb_widget = awful_widget_keyboardlayout()

  local function update_status()
    akb_widget._current = capi.awesome.xkb_get_layout_group()
    local text = ""
    if (#akb_widget._layout > 0) then
        text = (akb_widget._layout[akb_widget._current+1])
    end
    if text == default_layout then
      kbd.widget:hide()
    else
      kbd.widget:show()
      kbd.widget:set_markup(replacements[text] or text)
    end
  end

  update_status()

  capi.awesome.connect_signal("xkb::group_changed", update_status)
  capi.awesome.connect_signal("xkb::map_changed", update_status)

  return setmetatable(kbd, { __index = kbd.widget })
end

return setmetatable(kbd, { __call = function(_, ...)
  return widget_factory(...)
end })
