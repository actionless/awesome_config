--[[
     Licensed under GNU General Public License v2
      * (c) 2013-2019, Yauheni Kirylau
--]]
local beautiful = require("beautiful")
local awful = require("awful")
local gears_timer = require("gears.timer")
local naughty = require("naughty")

local parse = require("actionless.util.parse")
local h_string = require("actionless.util.string")
local decorated_widget = require("actionless.widgets.common").decorated
local markup = require("actionless.util.markup")

local cpu = require("actionless.widgets.cpu")

-- arch-updates
local updates = {}


function updates.show_notification()
  updates.notification = naughty.notify({
    title = "updates available:",
    text = h_string.rstrip(updates.updates),
    font = beautiful.mono_font,
    replaces_id = updates.notification and updates.notification.id,
    position = beautiful.widget_notification_position,
    timeout=0,
  })
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
  updates.updates = updates_str
    :gsub(" +", " ")
    :gsub("^%s", "")
    :gsub("\n%s", "\n")
    :gsub('->', markup.fg.color(beautiful.notification_border_color, '->'))
  local updates_found = #(parse.string_to_lines(updates_str))
  if updates_found > 0 then
    updates.widget:show()
    updates.widget:set_text(string.format(" %i ", updates_found))
  else
    updates.widget:hide()
  end
end


function updates.init(args)
  args = args or {}
  local update_interval = args.update_interval or 60
  updates.helper = args.helper or "pikaur"

  updates.widget = decorated_widget(args)
  updates.widget:set_image(beautiful.widget_updates)
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
