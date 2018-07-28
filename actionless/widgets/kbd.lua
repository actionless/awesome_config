--[[
Licensed under GNU General Public License v2
* (c) 2013-2014, Yauheni Kirylau
--]]

local capi = {
  awesome=awesome
}
local awesome_keyboardlayout = require("awful.widget.keyboardlayout")

local common = require("actionless.widgets.common")

local kbd = {}
kbd.widget = common.widget()

local function worker(args)
  args	 = args or {}
  args.orientation = args.orientation or "horizontal"
  args.widget=kbd.widget
  kbd.widget = common.decorated(args)
  kbd.widget:hide()

  local awesome_keayboardlayout_instance = awesome_keyboardlayout()
  local replacements = args.replacements or {us="eng", ["ru(winkeys)"]="rus"}
  local default_layout = args.default_layout or "us"

  local function update_status()
    local self =  awesome_keayboardlayout_instance
    self._current = capi.awesome.xkb_get_layout_group()
    local text = ""
    if (#self._layout > 0) then
        text = (self._layout[self._current+1])
    end
    if text == default_layout then
      kbd.widget:hide()
    else
      kbd.widget:show()
      kbd.widget:set_markup(replacements[text] or text)
    end
  end

  update_status()
  capi.awesome.connect_signal("xkb::group_changed",
    function () update_status() end);
  capi.awesome.connect_signal("xkb::map_changed",
    function () update_status() end)

  return setmetatable(kbd, { __index = kbd.widget })
end

return setmetatable(kbd, { __call = function(_, ...) return worker(...) end })
