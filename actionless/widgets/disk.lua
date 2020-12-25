--[[
     Licensed under GNU General Public License v2
      * (c) 2013-2014, Yauheni Kirylau
--]]
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local awful = require("awful")
local gears_timer = require("gears.timer")
local gears_table = require("gears.table")
local g_string = require("gears.string")
local naughty = require("naughty")

local parse = require("actionless.util.parse")
local h_table = require("actionless.util.table")
local h_string = require("actionless.util.string")
local decorated_widget= require("actionless.widgets.common").decorated


-- coredisk
local disk = {
  default_warning={
    pcent=90,
    --avail=307200,  -- 300MiB
    --avail=1048576,  -- 1GiB
    --avail=2097152,  -- 2GiB
    avail=4194304,  -- 4GiB
    -- test params:
    --pcent=80,
    --avail=10485760,  -- 10GiB
  },
  current_warnings = {},
}

function disk.hide_notification()
  if disk.notification ~= nil then
    naughty.destroy(disk.notification)
    disk.notification = nil
  end
end


function disk.get_notification_id()
  return disk.notification and disk.notification.id or nil
end


function disk.show_notification()
  local max_source_len = 0
  local max_target_len = 0
  for _, warning in ipairs(disk.current_warnings) do
    if warning.source and #warning.source > max_source_len then
      max_source_len = #warning.source
    end
    if warning.target and #warning.target > max_target_len then
      max_target_len = #warning.target
    end
  end
  max_source_len = tostring(max_source_len+2)
  max_target_len = tostring(max_target_len+2)
  local message = string.format(
      "%-"..max_source_len.."s%-"..max_target_len.."s%5s%7s",
      'DEV',
      'MNT',
      'USED',
      'AVAIL'
    )
  for _, warning in ipairs(disk.current_warnings) do
    message = message..string.format(
      "\n%-"..max_source_len.."s%-"..max_target_len.."s%3.1f%%%5.1fGB",
      warning.source,
      warning.target,
      warning.pcent,
      warning.avail / 1024 / 1024
    )
  end
  disk.notification = naughty.notify({
    text = message,
    timeout = disk.notification_timeout,
    font = beautiful.mono_text_font,
    replaces_id = disk.get_notification_id(),
    position = beautiful.widget_notification_position,
  })
end

function disk.update()
  awful.spawn.easy_async({
    'df',
    '-x', 'tmpfs',
    '-x', 'devtmpfs',
    '--output=source,size,avail,target',
  }, disk._post_update)
end

function disk._post_update(str)
  local max = {
    pcent=0,
    source='',
    target='',
  }
  disk.current_warnings = {}

  for _, line in ipairs(h_table.range(
    parse.string_to_lines(
      h_string.strip(str)
    ), 2
  )) do
    local data = g_string.split(line, ' ')
    local source = data[1]
    local size = tonumber(data[2])
    local avail = tonumber(data[3])
    local pcent = (1 - avail / size) * 100
    local target = data[4]

    local warning = disk.warning_rules[source] or disk.default_warning
    if (
      pcent > max.pcent
    ) and (
      (
        warning.pcent and (pcent >= warning.pcent)
      ) or not warning.pcent
    ) and (
      (
        warning.avail and (avail <= warning.avail)
      ) or not warning.avail
    ) then
      max.pcent = pcent
      max.avail = avail
      max.message = (
        (avail and avail < warning.avail) and string.format(
          "%2.1fGB", (avail/1024/1024)
        ) or string.format(
          "%2.1f%", pcent
        )
      )
      max.source = source
      max.target = target
      table.insert(disk.current_warnings, gears_table.clone(max))
    end
  end

  if max.pcent > 0 then
    --disk.widget:set_text(string.format(
    --  "%s %s",
    --  max.message, max.target or max.source
    --))
    disk.widget:set_text(max.message)
    if beautiful.widget_disk_high then
      disk.widget:set_image(beautiful.widget_disk_high)
    end
    disk.widget:set_bg(beautiful.panel_widget_bg_error)
    disk.widget:set_fg(beautiful.panel_widget_fg_error)
    disk.widget:show()
  else
    disk.widget:hide()
    disk.widget:set_bg(disk.bg)
    disk.widget:set_fg(disk.fg)
  end
end

function disk.init(args)
  args = args or {}
  args.padding = args.padding or {
    left = beautiful.panel_widget_spacing or dpi(3),
    right = beautiful.panel_widget_spacing or dpi(3),
  }
  disk.warning_rules = args.rules or {}
  disk.notification_timeout = args.notification_timeout or 60
  local update_interval = args.update_interval or 100
  local exec = args.exec or "gnome-system-monitor -f"

  disk.bg = args.bg or beautiful.panel_widget_bg or beautiful.panel_fg or beautiful.fg
  disk.fg = args.fg or beautiful.panel_widget_fg or beautiful.panel_bg or beautiful.bg

  disk.widget = decorated_widget(args)
  if beautiful.widget_disk then
    disk.widget:set_image(beautiful.widget_disk)
  end
  disk.widget:buttons(awful.util.table.join(
    awful.button({ }, 1, function()
      awful.spawn.with_shell(exec)
    end)
  ))
  disk.widget:connect_signal(
    "mouse::enter", function () disk.show_notification() end
  )
  disk.widget:connect_signal(
    "mouse::leave", function () disk.hide_notification() end
  )

  gears_timer({
    callback=disk.update,
    timeout=update_interval,
    autostart=true,
    call_now=true,
  })

  return disk.widget
end

return setmetatable(disk, { __call = function(_, ...) return disk.init(...) end })
