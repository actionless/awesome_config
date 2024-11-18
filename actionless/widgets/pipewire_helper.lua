--[[
  Licensed under GNU General Public License v2
   * (c) 2024, Yauheni Kirylau
--]]

local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local common = require("actionless.widgets.common")
local decorated_widget = common.decorated
local db = require("actionless.util.db")
local get_icon = require("actionless.util.xdg").get_icon
--local log = require("actionless.util.debug").log


--local DEBUG_LOG = false
----local DEBUG_LOG = true
--local function _log(...)
--  if DEBUG_LOG then
--    log({"::PIPEWIRE-HELPER:" ,...})
--  end
--end


-- pipewire_helper infos
local pipewire_helper = {
  menu_width=dpi(300),
  notification_object=nil,
  available_scripts={},
  enabled_scripts={},
  last_script=nil,
}
local db_ids = {
  enabled="pipewire_monitoring_enabled",
  last="pipewire_monitoring_last",
}


function pipewire_helper.init(widget_args)
  widget_args = widget_args or {}
  pipewire_helper.args = widget_args
  pipewire_helper.available_scripts = widget_args.scripts or {
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

  pipewire_helper.icon_widget = common.widget({margin={
    left=beautiful.show_widget_icon and dpi(4) or 0,
    right=beautiful.show_widget_icon and dpi(4) or 0
  }})
  widget_args.spacing = 0
  widget_args.widgets = {
    --wibox.widget.textbox(' '),
    beautiful.show_widget_icon and pipewire_helper.icon_widget or wibox.widget.textbox('pw'),
    --common.constraint({
      --height = beautiful.panel_padding_bottom * 2,
      --width = beautiful.panel_padding_bottom * 2,
    --}),
    --wibox.widget.textbox(' '),
  }
  pipewire_helper.widget = decorated_widget(widget_args)
-------------------------------------------------------------------------------

  function pipewire_helper.load()
    pipewire_helper.enabled_scripts = db.session_db().get_or_set(db_ids.enabled, {})
    pipewire_helper.last_script = db.get_or_set(
      db_ids.last,
      pipewire_helper.available_scripts[1].id
      or pipewire_helper.available_scripts[1].cmd
    )
  end
-------------------------------------------------------------------------------

  function pipewire_helper.save()
    db.session_db().set(db_ids.enabled, pipewire_helper.enabled_scripts)
    local current_script = pipewire_helper.get_current_script()
    if current_script then
      db.set(db_ids.last, current_script.id)
    end
  end
-------------------------------------------------------------------------------

  function pipewire_helper.hide_notification()
    if pipewire_helper.notification_object ~= nil then
      naughty.destroy(pipewire_helper.notification_object)
      pipewire_helper.notification_object = nil
    end
  end
-------------------------------------------------------------------------------

  function pipewire_helper.show_notification()
    -- @TODO: remove it?
    local notification_timeout = widget_args.popup_timeout or 5
    local text = tostring(pipewire_helper.enabled_scripts)
    pipewire_helper.hide_notification()

    if not pipewire_helper.notification_object then
      pipewire_helper.notification_object = naughty.notification({
        timeout = notification_timeout,
        position = beautiful.widget_notification_position,
      })
    end
    pipewire_helper.notification_object.message = text
  end
-------------------------------------------------------------------------------

  function pipewire_helper.get_current_script()
    for script_id, status in pairs(pipewire_helper.enabled_scripts) do
      if status then
        return pipewire_helper.get_script_data_by_id(script_id)
      end
    end
  end
-------------------------------------------------------------------------------

  function pipewire_helper.update()
    if pipewire_helper.get_current_script() then
      pipewire_helper.icon_widget:set_image(beautiful.widget_wires_high)
    else
      pipewire_helper.icon_widget:set_image(beautiful.widget_wires)
    end
  end
-------------------------------------------------------------------------------

  function pipewire_helper.get_script_data_by_id(script_id)
      for _, script_data in ipairs(pipewire_helper.available_scripts) do
        local current_script_id = script_data.id or script_data.cmd
        if current_script_id == script_id then
          if not script_data.id then
            script_data.id = script_data.cmd
          end
          return script_data
        end
      end
  end
-------------------------------------------------------------------------------

  function pipewire_helper.turn_off(script_id, args)
    args = args or {}
    local script_data = pipewire_helper.get_script_data_by_id(script_id)
    if script_data then
      local cmd = script_data.command or script_id
      local cmd_off = script_data.command_off or cmd.." -d"
      awful.spawn.with_shell(cmd_off)
    end
    pipewire_helper.enabled_scripts[script_id] = false
    if args.save then
      pipewire_helper.save()
    end
    pipewire_helper.update()
  end
-------------------------------------------------------------------------------

  function pipewire_helper.switch(script_id)
    for enabled_script_id, _ in pairs(pipewire_helper.enabled_scripts) do
      pipewire_helper.turn_off(enabled_script_id, {save=false})
    end
    local script_data = pipewire_helper.get_script_data_by_id(script_id)
    local cmd = script_data.command or script_id
    awful.spawn.with_shell(cmd)
    pipewire_helper.enabled_scripts[script_id] = true
    pipewire_helper.save()
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
    for enabled_script_id, _ in pairs(pipewire_helper.enabled_scripts) do
      pipewire_helper.enabled_scripts[enabled_script_id] = false
    end
    pipewire_helper.save()
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

  function pipewire_helper.toggle_last()
    local script_data = pipewire_helper.get_current_script()
    if script_data then
      pipewire_helper.turn_off(script_data.id)
    else
      pipewire_helper.switch(pipewire_helper.last_script)
    end
  end
-------------------------------------------------------------------------------

  function pipewire_helper.show_menu(menu_args)
    menu_args = menu_args or {}
    if pipewire_helper.menu and pipewire_helper.menu.wibox.visible then
      pipewire_helper.menu:hide()
    else
      local items = {}
      for _, script_data in ipairs(pipewire_helper.available_scripts) do
        local script_id = script_data.id or script_data.cmd
        local display_name = script_data.title
        local item = {display_name, }
        item[2] = function()
          pipewire_helper.menu:hide()
          pipewire_helper.switch(script_id)
        end
        if pipewire_helper.enabled_scripts[script_id] then
          item[2] = function()
            pipewire_helper.menu:hide()
            pipewire_helper.turn_off(script_id, {save=true})
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
    awful.button({ }, 2, pipewire_helper.toggle_last),
    awful.button({ }, 3, pipewire_helper.show_menu)
    --awful.button({ }, 3, function() pipewire_helper.show_menu() end),
    --awful.button({ }, 5, pipewire_helper.next_song),
    --awful.button({ }, 4, pipewire_helper.prev_song)
  ))

  pipewire_helper.load()
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
