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


-- script_switcher infos
local module = {}

function module.init(widget_args)
  -- widget_args:
  --  name: str
  --  icon_enabled: image
  --  icon_disabled: image
  --  scripts: list[dict[cmd=,title=,[id=,cmd_off=]]]
  --  extra_funcs: list[title, func, icon] | None
  --
  local script_switcher = {
    menu_width=dpi(300),
    notification_object=nil,
    available_scripts={},
    enabled_scripts={},
    last_script=nil,
  }

  widget_args = widget_args or {}
  script_switcher.args = widget_args
  local name = widget_args.name
  local db_ids = {
    enabled=name.."_enabled",
    last= name.."_last",
  }
  script_switcher.name = widget_args.name or "script_switcher"
  script_switcher.available_scripts = widget_args.scripts
  script_switcher.extra_funcs = widget_args.extra_funcs
  script_switcher.icon_enabled = widget_args.icon_enabled
  script_switcher.icon_disabled = widget_args.icon_disabled

  script_switcher.icon_widget = common.widget({margin={
    left=beautiful.show_widget_icon and dpi(4) or 0,
    right=beautiful.show_widget_icon and dpi(4) or 0
  }})
  widget_args.spacing = 0
  widget_args.widgets = {
    --wibox.widget.textbox(' '),
    beautiful.show_widget_icon and script_switcher.icon_widget or wibox.widget.textbox('pw'),
    --common.constraint({
      --height = beautiful.panel_padding_bottom * 2,
      --width = beautiful.panel_padding_bottom * 2,
    --}),
    --wibox.widget.textbox(' '),
  }
  script_switcher.widget = decorated_widget(widget_args)
-------------------------------------------------------------------------------

  function script_switcher.load()
    script_switcher.enabled_scripts = db.session_db().get_or_set(db_ids.enabled, {})
    script_switcher.last_script = db.get_or_set(
      db_ids.last,
      script_switcher.available_scripts[1].id
      or script_switcher.available_scripts[1].cmd
    )
  end
-------------------------------------------------------------------------------

  function script_switcher.save()
    db.session_db().set(db_ids.enabled, script_switcher.enabled_scripts)
    local current_script = script_switcher.get_current_script()
    if current_script then
      db.set(db_ids.last, current_script.id)
    end
  end
-------------------------------------------------------------------------------

  function script_switcher.hide_notification()
    if script_switcher.notification_object ~= nil then
      naughty.destroy(script_switcher.notification_object)
      script_switcher.notification_object = nil
    end
  end
-------------------------------------------------------------------------------

  function script_switcher.show_notification()
    -- @TODO: remove it?
    local notification_timeout = widget_args.popup_timeout or 5
    local text = tostring(script_switcher.enabled_scripts)
    script_switcher.hide_notification()

    if not script_switcher.notification_object then
      script_switcher.notification_object = naughty.notification({
        timeout = notification_timeout,
        position = beautiful.widget_notification_position,
      })
    end
    script_switcher.notification_object.message = text
  end
-------------------------------------------------------------------------------

  function script_switcher.get_current_script()
    for script_id, status in pairs(script_switcher.enabled_scripts) do
      if status then
        return script_switcher.get_script_data_by_id(script_id)
      end
    end
  end
-------------------------------------------------------------------------------

  function script_switcher.update()
    local current_script = script_switcher.get_current_script()
    if current_script then
      if script_switcher.icon_enabled then
        script_switcher.icon_widget:set_image(script_switcher.icon_enabled)
      else
        script_switcher.icon_widget:set_text(current_script.title or script_switcher.name or "")
      end
    else
      if script_switcher.icon_disabled then
        script_switcher.icon_widget:set_image(script_switcher.icon_disabled)
      else
        script_switcher.icon_widget:set_text(script_switcher.name or "")
      end
    end
  end
-------------------------------------------------------------------------------

  function script_switcher.get_script_data_by_id(script_id)
      for _, script_data in ipairs(script_switcher.available_scripts) do
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

  function script_switcher.turn_off(script_id, args)
    args = args or {}
    local script_data = script_switcher.get_script_data_by_id(script_id)
    if script_data then
      local cmd = script_data.cmd or script_id
      local cmd_off = script_data.cmd_off or cmd.." -d"
      awful.spawn.with_shell(cmd_off)
    end
    script_switcher.enabled_scripts[script_id] = false
    if args.save then
      script_switcher.save()
    end
    script_switcher.update()
  end
-------------------------------------------------------------------------------

  function script_switcher.switch(script_id)
    for enabled_script_id, _ in pairs(script_switcher.enabled_scripts) do
      script_switcher.turn_off(enabled_script_id, {save=false})
    end
    local script_data = script_switcher.get_script_data_by_id(script_id)
    local cmd = script_data.cmd or script_id
    awful.spawn.with_shell(cmd)
    script_switcher.enabled_scripts[script_id] = true
    script_switcher.save()
    script_switcher.update()
  end
-------------------------------------------------------------------------------

  function script_switcher.toggle_last()
    local script_data = script_switcher.get_current_script()
    if script_data then
      script_switcher.turn_off(script_data.id)
    else
      script_switcher.switch(script_switcher.last_script)
    end
  end
-------------------------------------------------------------------------------

  function script_switcher.show_menu(menu_args)
    menu_args = menu_args or {}
    if script_switcher.menu and script_switcher.menu.wibox.visible then
      script_switcher.menu:hide()
    else
      local items = {}
      for _, script_data in ipairs(script_switcher.available_scripts) do
        local script_id = script_data.id or script_data.cmd
        local display_name = script_data.title
        local item = {display_name, }
        item[2] = function()
          script_switcher.menu:hide()
          script_switcher.switch(script_id)
        end
        if script_switcher.enabled_scripts[script_id] then
          item[2] = function()
            script_switcher.menu:hide()
            script_switcher.turn_off(script_id, {save=true})
          end
          item[3] = get_icon('actions', 'object-select-symbolic')
        end
        table.insert(items, item)
      end
      for _, extra_item in ipairs(script_switcher.extra_funcs) do
        table.insert(items, extra_item)
      end
      script_switcher.menu = awful.menu{
        items=items,
        theme={
          width=script_switcher.menu_width,
        },
      }
      script_switcher.menu:show{
        coords=menu_args.coords,
      }
    end
  end
-------------------------------------------------------------------------------

  --script_switcher.widget:connect_signal(
  --  "mouse::enter", function () script_switcher.show_notification() end)
  --script_switcher.widget:connect_signal(
  --  "mouse::leave", function () script_switcher.hide_notification() end)
  script_switcher.widget:buttons(awful.util.table.join(
    awful.button({ }, 1, script_switcher.show_menu),
    awful.button({ }, 2, script_switcher.toggle_last),
    awful.button({ }, 3, script_switcher.show_menu)
    --awful.button({ }, 3, function() script_switcher.show_menu() end),
    --awful.button({ }, 5, script_switcher.next_song),
    --awful.button({ }, 4, script_switcher.prev_song)
  ))

  script_switcher.load()
  script_switcher.update()
  return setmetatable(script_switcher, { __index = script_switcher.widget })
end

return setmetatable(
  module,
  { __call = function(_, ...)
      return module.init(...)
    end
  }
)
