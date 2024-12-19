--[[
  Licensed under GNU General Public License v2
   * (c) 2024, Yauheni Kirylau
--]]

--local awful = require("awful")

local script_switcher = require("actionless.widgets.script_switcher")
--local get_icon = require("actionless.util.xdg").get_icon


-- screen_layouts infos
local screen_layouts = {
}


function screen_layouts.init(widget_args)
  local home = os.getenv("HOME")
  widget_args = widget_args or {}
  widget_args.name = widget_args.name or "screen_layouts"
  widget_args.scripts = widget_args.scripts or {
    {
      cmd=home.."/.screenlayout/main_only.sh",
      cmd_off="true",
      title="Main Screen Only",
    },
    {
      cmd=home.."/.screenlayout/two_screens_bottom_right.sh",
      cmd_off="true",
      title="2 screens: Main -> TouchScreen",
    },
  }
  widget_args.extra_funcs = widget_args.extra_funcs or {
    --{
    --    "restuck",
    --    function()
    --      awful.spawn.with_shell(
    --        "pw-metadata -n settings 0 clock.force-quantum 256"
    --        .." ; pw-metadata -n settings 0 clock.force-quantum 1024"
    --      )
    --    end,
    --    get_icon('actions', 'view-refresh')
    --},
  }
  screen_layouts = script_switcher.init(widget_args)
  return setmetatable(screen_layouts, { __index = screen_layouts.widget })
end

return setmetatable(
  screen_layouts,
  { __call = function(_, ...)
      return screen_layouts.init(...)
    end
  }
)
