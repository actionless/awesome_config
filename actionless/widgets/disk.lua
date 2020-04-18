--[[
     Licensed under GNU General Public License v2
      * (c) 2013-2014, Yauheni Kirylau
--]]
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local awful = require("awful")
local gears_timer = require("gears.timer")
local g_string = require("gears.string")

local parse = require("actionless.util.parse")
local h_table = require("actionless.util.table")
local h_string = require("actionless.util.string")
local decorated_widget= require("actionless.widgets.common").decorated


-- coredisk
local disk = {
  default_warning={
    pcent=90,
    --avail=307200,  -- 300MiB
    avail=1048576,  -- 1GiB
    -- test params:
    --pcent=80,
    --avail=10485760,  -- 10GiB
  }
}

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
      max.source = source
      max.target = target
    end
  end

  if max.pcent > 0 then
    disk.widget:set_text(string.format(
      "%2.1f%% %s",
      max.pcent, max.target or max.source
    ))
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
  args.margin = args.margin or {
    left = math.ceil(beautiful.panel_widget_spacing / 4) or dpi(3),
    right = beautiful.panel_widget_spacing or dpi(3),
  }
  disk.warning_rules = args.rules or {}
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

  gears_timer({
    callback=disk.update,
    timeout=update_interval,
    autostart=true,
    call_now=true,
  })

  return disk.widget
end

return setmetatable(disk, { __call = function(_, ...) return disk.init(...) end })
