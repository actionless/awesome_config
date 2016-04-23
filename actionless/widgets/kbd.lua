--[[
Licensed under GNU General Public License v2
* (c) 2013-2014, Yauheni Kirylau
--]]

local capi      = {
  awesome=awesome
}

local common	= require("actionless.widgets.common")
local awesome_keyboardlayout = require("awful.widget.keyboardlayout")


local kbd = {}
kbd.widget = common.widget()

local function worker(args)
  args	 = args or {}
  args.orientation = args.orientation or "horizontal"
  local replacements = args.replacements or {us="eng", ["ru(winkeys)"]="rus"}
  local default_layout = args.default_layout or "us"
  args.widget=kbd.widget
  kbd.widget = common.decorated(args)
  kbd.widget:hide()

  local awesome_keayboardlayout_instance = awesome_keyboardlayout()

  local function update_status()
    local self =  awesome_keayboardlayout_instance
    self._current = awesome.xkb_get_layout_group();
    local text = ""
    if (#self._layout > 0) then
        text = (self._layout[self._current])
    end
    if text == default_layout then
      kbd.widget:hide()
    else
      kbd.widget:show()
      kbd.widget:set_markup(replacements[text] or text)
    end
  end

  local function update_layout()
    local self = awesome_keayboardlayout_instance
    self._layout = {};
    local layouts = awesome_keyboardlayout.get_groups_from_group_names(
      awesome.xkb_get_group_names()
    )
    if layouts == nil or layouts[1] == nil then
      error("Failed to get list of keyboard groups")
      return;
    end
    if #layouts == 1 then
      layouts[1].group_idx = 0
    end
    for _, v in ipairs(layouts) do
      local layout_name = self.layout_name(v)
      -- Please note that numbers of groups reported by xkb_get_group_names
      -- is greater by one than the real group number.
      self._layout[v.group_idx - 1] = layout_name
    end
    update_status(self)
  end

  capi.awesome.connect_signal("xkb::group_changed",
    function () update_status() end);
  capi.awesome.connect_signal("xkb::map_changed",
    function () update_layout() end)

  return setmetatable(kbd, { __index = kbd.widget })
end

return setmetatable(kbd, { __call = function(_, ...) return worker(...) end })
