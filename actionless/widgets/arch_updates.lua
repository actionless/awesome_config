--[[
     Licensed under GNU General Public License v2
      * (c) 2013-2019, Yauheni Kirylau
--]]
local beautiful = require("beautiful")
local awful = require("awful")
local gears_timer = require("gears.timer")
local g_string = require("gears.string")
local naughty = require("naughty")
local gmath = require('gears.math')

local parse = require("actionless.util.parse")
local h_string = require("actionless.util.string")
local decorated_widget = require("actionless.widgets.common").decorated
local markup = require("actionless.util.markup")

local cpu = require("actionless.widgets.cpu")

-- arch-updates
local updates = {}


function updates.show_notification()
  if not updates.notification then
    updates.notification = naughty.notification({
      position = beautiful.widget_notification_position,
      font = beautiful.mono_font,
      timeout=0,
      max_width = math.ceil(awful.screen.focused().workarea.width / 2),
    })
  end
  local n = updates.notification
  if updates.updates then
    n.title = "updates available:"
    n.message = h_string.rstrip(updates.updates)
  else
    n.title = "no updates"
    n.message = ''
  end
end


function updates.hide_notification()
  if updates.notification ~= nil then
    naughty.destroy(updates.notification)
    updates.notification = nil
  end
end


function updates.check_updates()
  if cpu.now and cpu.now.la1 and cpu.cores_number and (
      (cpu.now.la1 / cpu.cores_number) > 1
  ) then
    -- don't check for updates when CPU queue loaded more than 100%
    return
  end
  local cmd = "checkupdates"
  if updates.helper == "pikaur" then
    cmd = "checkupdates ; pikaur -Qua 2>/dev/null"
  end
  awful.spawn.easy_async({'sh', '-c', cmd}, updates._check_updates_callback)
end


function updates._check_updates_callback(updates_str)
  updates_str = h_string.strip(updates_str)
  if g_string.startswith(updates_str, "Do you want to retry") then
      updates.widget:set_error()
      updates.widget:set_text('x')
      updates.widget:show()
  else
    updates.updates = updates_str
      :gsub(" +", " ")
      :gsub("^%s", "")
      :gsub("\n%s", "\n")
      :gsub('->', markup.fg.color(beautiful.notification_border_color, '->'))
    local updates_found = #(parse.string_to_lines(updates_str))
    if updates_found > 0 then
      updates.widget:set_normal()
      updates.widget:set_text(updates_found)
      updates.widget:show()
    else
      updates.widget:hide()
    end
  end
end


function updates.init(args)
  args = args or {}
  args.margin = args.margin or {
    left = gmath.round(beautiful.panel_widget_spacing/2),
    right = (
      (beautiful.show_widget_icon and beautiful.widget_updates) and
      beautiful.panel_widget_spacing or
      gmath.round(beautiful.panel_widget_spacing/2)
    )
  }
  local update_interval = args.update_interval or 60
  updates.helper = args.helper or "pikaur"

  updates.widget = decorated_widget(args)
  if beautiful.show_widget_icon and beautiful.widget_updates then
    updates.widget:set_image(beautiful.widget_updates)
  else
    updates.widget:hide()
  end

  updates.widget:connect_signal(
    "mouse::enter", function () updates.show_notification() end
  )
  updates.widget:connect_signal(
    "mouse::leave", function () updates.hide_notification() end
  )

  gears_timer({
    callback=updates.check_updates,
    timeout=update_interval,
    autostart=true,
    call_now=true,
  })

  return updates.widget
end


return setmetatable(updates, { __call = function(_, ...) return updates.init(...) end })
