--[[
  Licensed under GNU General Public License v2
   * (c) 2024, Yauheni Kirylau
--]]

local awful = require("awful")
local beautiful = require("beautiful")

local script_switcher = require("actionless.widgets.script_switcher")
local get_icon = require("actionless.util.xdg").get_icon


-- pipewire_helper infos
local pipewire_helper = {
}


function pipewire_helper.init(widget_args)
  widget_args = widget_args or {}
  widget_args.name = widget_args.name or "pipewire_helper"
  widget_args.icon_enabled = beautiful.widget_wires_high
  widget_args.icon_disabled = beautiful.widget_wires
  widget_args.scripts = widget_args.scripts or {
    {
      cmd="monitoring_pipewire_easyeffects_blackjack",
      title="Monitoring: BlackJack: EasyEffects",
    },
    {
      cmd="monitoring_pipewire_easyeffects_blackjack_carla",
      title="Monitoring: BlackJack+Carla: EasyEffects",
    },
    {
      cmd="monitoring_pipewire_easyeffects_blackjack_zam",
      title="Monitoring: BlackJack+Zam Standalone: EasyEffects",
    },
    {
      cmd="monitoring_pipewire_blackjack",
      title="Monitoring: BlackJack",
    },
  }
  widget_args.extra_funcs = widget_args.extra_funcs or {
    {
        "restuck",
        function()
          awful.spawn.with_shell(
            "pw-metadata -n settings 0 clock.force-quantum 256"
            .." ; pw-metadata -n settings 0 clock.force-quantum 1024"
          )
        end,
        get_icon('actions', 'view-refresh')
    },
    {
        "RESTART PIPEWIRE",
        function()
          awful.spawn.with_shell(
            "pkill easyeffects -9"
            .." ; sleep 1"
            .." ; systemctl --user stop pipewire pipewire-pulse wireplumber pipewire.socket pipewire-pulse.socket"
            .." ; sleep 2"
            .." ; systemctl --user start pipewire pipewire-pulse pipewire.socket pipewire-pulse.socket"
            .." ; sleep 1"
            .." ; systemctl --user start wireplumber"
            .." ; sleep 1"
            .." ; easyeffects"
          )
          for enabled_script_id, _ in pairs(pipewire_helper.enabled_scripts) do
            pipewire_helper.enabled_scripts[enabled_script_id] = false
          end
          pipewire_helper.save()
          pipewire_helper.update()
        end,
        get_icon('actions', 'view-refresh')
    },
  }
  pipewire_helper = script_switcher.init(widget_args)
  return setmetatable(pipewire_helper, { __index = pipewire_helper.widget })
end

return setmetatable(
  pipewire_helper,
  { __call = function(_, ...)
      return pipewire_helper.init(...)
    end
  }
)
