--[[
Licensed under GNU General Public License v2
* (c) 2013-2014, Yauheni Kirylau
--]]

local wibox = require('wibox')
local beautiful = require('beautiful')
local awful_widget_keyboardlayout = require("awful.widget.keyboardlayout")

local capi = {
  awesome=awesome
}

local common = require("actionless.widgets.common")

local kbd = {}

local function widget_factory(args)
  args	 = args or {}
  local default_layout = args.default_layout or "us"
  local replacements = args.replacements or {us="eng", ["ru(winkeys)"]="rus"}

  args.widget = args.widget or wibox.widget.textbox()
  args.orientation = args.orientation or "horizontal"
  args.padding = args.padding or {
    left=math.ceil((beautiful.panel_widget_spacing or beautiful.xresources.apply_dpi(3)) / 2),
    right=math.ceil((beautiful.panel_widget_spacing or beautiful.xresources.apply_dpi(3)) / 2),
  }
  local decorated = common.decorated(args)
  kbd.widget = common.panel_shape(decorated)

  local akb_widget = awful_widget_keyboardlayout()

  local function update_status()
    akb_widget._current = capi.awesome.xkb_get_layout_group()
    local text = ""
    if (#akb_widget._layout > 0) then
        text = (akb_widget._layout[akb_widget._current+1])
    end
    if text == default_layout then
      decorated:hide()
    else
      decorated:show()
      decorated:set_markup(replacements[text] or text)
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
