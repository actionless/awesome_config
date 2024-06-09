--[[
  Licensed under GNU General Public License v2
   * (c) 2024, Yauheni Kirylau
--]]

local awful		= require("awful")
local wibox	= require("wibox")
local naughty		= require("naughty")
local beautiful		= require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local common = require("actionless.widgets.common")
local decorated_widget	= common.decorated
local db = require("actionless.util.db")
local get_icon = require("actionless.util.xdg").get_icon
local log = require("actionless.util.debug").log


local DEBUG_LOG = false
--local DEBUG_LOG = true
local function _log(...)
  if DEBUG_LOG then
    log({"::PIPEWIRE-HELPER:" ,...})
  end
end


-- pipewire_helper infos
local pipewire_helper = {
  menu_width=dpi(300),
  notification_object=nil,
}


function pipewire_helper.init(args)
  args = args or {}
  pipewire_helper.args = args
  args.spacing = 0
  local timeout = args.popup_timeout or 5
  local available_scripts = args.scripts or {
    monitoring_pipewire_easyeffects_blackjack={
      title="Monitoring: BlackJack: EasyEffects",
    },
    monitoring_pipewire_easyeffects_blackjack_zam={
      title="Monitoring: BlackJack+Zam: EasyEffects",
    },
    monitoring_pipewire_blackjack={
      title="Monitoring: BlackJack",
    },
  }
  pipewire_helper.enable_notifications = args.enable_notifications or false
  pipewire_helper.icon_widget = common.widget({margin={
    left=beautiful.show_widget_icon and dpi(4) or 0,
    right=beautiful.show_widget_icon and dpi(4) or 0
  }})

  args.widgets = {
    --wibox.widget.textbox(' '),
    beautiful.show_widget_icon and pipewire_helper.icon_widget or wibox.widget.textbox('pw'),
    --common.constraint({
      --height = beautiful.panel_padding_bottom * 2,
      --width = beautiful.panel_padding_bottom * 2,
    --}),
    --wibox.widget.textbox(' '),
  }
  pipewire_helper.widget = decorated_widget(args)


  local enabled_scripts = db.get_or_set("pipewire_monitoring_enabled", {1, })
-------------------------------------------------------------------------------
  function pipewire_helper.hide_notification()
    if pipewire_helper.notification_object ~= nil then
      naughty.destroy(pipewire_helper.notification_object)
      pipewire_helper.notification_object = nil
    end
  end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
  function pipewire_helper.show_notification()
    local text = tostring(enabled_scripts)
    pipewire_helper.hide_notification()

    if not pipewire_helper.notification_object then
      pipewire_helper.notification_object = naughty.notification({
        timeout = timeout,
        position = beautiful.widget_notification_position,
      })
    end
    pipewire_helper.notification_object.message = text
  end

-------------------------------------------------------------------------------
  function pipewire_helper.update()
    local connected = false
    for enabled_script_id, status in pairs(enabled_scripts) do
      connected = connected or status
    end
    if connected then
      pipewire_helper.icon_widget:set_image(beautiful.widget_wires_high)
    else
      pipewire_helper.icon_widget:set_image(beautiful.widget_wires)
    end
  end
-------------------------------------------------------------------------------
  function pipewire_helper.turn_off(script_id)
    local script_data = available_scripts[script_id]
    if script_data then
      local cmd = script_data.command or script_id
      local cmd_off = script_data.command_off or cmd.." -d"
      awful.spawn.with_shell(cmd_off)
    end
    enabled_scripts[script_id] = false
    pipewire_helper.update()
  end
-------------------------------------------------------------------------------
  function pipewire_helper.switch(script_id)
    for enabled_script_id, _ in pairs(enabled_scripts) do
      pipewire_helper.turn_off(enabled_script_id)
    end
    local script_data = available_scripts[script_id]
    local cmd = script_data.command or script_id
    awful.spawn.with_shell(cmd)
    enabled_scripts[script_id] = true
    db.set('pipewire_monitoring_enabled', enabled_scripts)
    pipewire_helper.update()
  end
-------------------------------------------------------------------------------
  function pipewire_helper.restart()
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
    for enabled_script_id, _ in pairs(enabled_scripts) do
      enabled_scripts[enabled_script_id] = false
    end
    db.set('pipewire_monitoring_enabled', enabled_scripts)
    pipewire_helper.update()
  end
-------------------------------------------------------------------------------
  function pipewire_helper.restuck()
    awful.spawn.with_shell(
      "pw-metadata -n settings 0 clock.force-quantum 256"
      .." ; pw-metadata -n settings 0 clock.force-quantum 1024"
    )
  end

-------------------------------------------------------------------------------
  function pipewire_helper.show_menu(menu_args)
    menu_args = menu_args or {}
    if pipewire_helper.menu and pipewire_helper.menu.wibox.visible then
      pipewire_helper.menu:hide()
    else
      local items = {}
      for script_id, script_data in pairs(available_scripts) do
        local display_name = script_data.title
        local item = {display_name, }
        item[2] = function()
          pipewire_helper.menu:hide()
          pipewire_helper.switch(script_id)
          --pipewire_helper.show_notification()
        end
        if enabled_scripts[script_id] then
          item[2] = function()
            pipewire_helper.menu:hide()
            pipewire_helper.turn_off(script_id)
          end
          item[3] = get_icon('actions', 'object-select-symbolic')
        end
        table.insert(items, item)
      end
      table.insert(items, {
        "restuck",
        function()
          pipewire_helper.restuck()
        end,
        get_icon('actions', 'view-refresh')
      })
      table.insert(items, {
        "RESTART PIPEWIRE",
        function()
          pipewire_helper.restart()
        end,
        get_icon('actions', 'view-refresh')
      })
      pipewire_helper.menu = awful.menu{
        items=items,
        theme={
          width=pipewire_helper.menu_width,
        },
      }
      pipewire_helper.menu:show{
        coords=menu_args.coords,
      }
    end
  end
-------------------------------------------------------------------------------

  --pipewire_helper.widget:connect_signal(
  --  "mouse::enter", function () pipewire_helper.show_notification() end)
  --pipewire_helper.widget:connect_signal(
  --  "mouse::leave", function () pipewire_helper.hide_notification() end)
  pipewire_helper.widget:buttons(awful.util.table.join(
    awful.button({ }, 1, pipewire_helper.show_menu),
    --awful.button({ }, 2, pipewire_helper.seek),
    awful.button({ }, 3, pipewire_helper.show_menu)
    --awful.button({ }, 3, function() pipewire_helper.show_menu() end),
    --awful.button({ }, 5, pipewire_helper.next_song),
    --awful.button({ }, 4, pipewire_helper.prev_song)
  ))

-------------------------------------------------------------------------------
  pipewire_helper.update()
  return setmetatable(pipewire_helper, { __index = pipewire_helper.widget })
end

return setmetatable(
  pipewire_helper,
  { __call = function(_, ...)
      return pipewire_helper.init(...)
    end
  }
)
