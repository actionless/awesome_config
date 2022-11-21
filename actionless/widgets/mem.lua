--[[
     Licensed under GNU General Public License v2
      * (c) 2013-2015, Yauheni Kirylau
      * (c) 2013,      Luke Bonham
      * (c) 2010-2012, Peter Hofmann
--]]

local naughty = require("naughty")
local beautiful = require("beautiful")
local awful = require("awful")
local gears_timer = require("gears.timer")
local gears_string = require("gears.string")

local h_table = require("actionless.util.table")
local h_string = require("actionless.util.string")
local parse = require("actionless.util.parse")
local common_widgets = require("actionless.widgets.common")

-- Memory usage (ignoring caches)
local mem = {
  critical_swap_ratio = 0.75,
  high_swap_ratio = 0.5,
  --critical_ram_ratio = 0.9,
  --high_ram_ratio = 0.7,
  now = {},
  notification = nil,
  show_percents = true,
  preserve_args = {
    python = true,
    lua = true,
    node = true,
  },
  _display_swap = false,
}


function mem.hide_notification()
  if mem.notification ~= nil then
    naughty.destroy(mem.notification)
    mem.notification = nil
  end
end


function mem.get_notification_id()
  return mem.notification and mem.notification.id or nil
end


function mem.show_notification()
  mem.notification = naughty.notify({
    text = "waiting for top...",
    timeout = mem.timeout,
    font = beautiful.mono_text_font,
    replaces_id = mem.get_notification_id(),
    position = beautiful.widget_notification_position,
  })
  awful.spawn.easy_async_with_shell(
    mem.command,
    mem._show_notification_callback
  )
  mem.update()
end


function mem._show_notification_callback(output)
  local notification_id = mem.get_notification_id()
  if not notification_id then return end
  local result = {}

  local column_headers = gears_string.split(
    h_string.lstrip(h_table.range(
      parse.string_to_lines(output),
      6, 6
    )[1]), ' '
  )
  for _, line in ipairs(
    h_table.range(
      parse.string_to_lines(output),
      7
    )
  ) do
    line = h_string.lstrip(line)
    local values = gears_string.split(line, ' ')
    local mem_percent = values[mem.columns.percent]
    local swap_mb = h_string.rstrip(values[mem.columns.swap], 'm')
    if gears_string.endswith(swap_mb, 'g') then
      swap_mb = h_string.rstrip(swap_mb, 'g') * 1024
    end
    if mem_percent then
      local path = values[mem.columns.name] and gears_string.split(values[mem.columns.name], '/')
      local name = path and path[#path]
      local args = h_table.range(values, mem.columns.name+1, #values)
      if args and mem.preserve_args[name] then
        name = name .. ' ' .. table.concat(args, ' ')
      end
      local mem_to_add = mem.show_percents and (mem_percent + 0) or (mem_percent * 0.01 * mem.now.total)
      local swap_to_add = mem.show_percents and (swap_mb / 0.01 / mem.now.total) or (swap_mb + 0)
      if result[name] then
        result[name] = result[name] + mem_to_add + swap_to_add
      elseif name then
        result[name] = mem_to_add + swap_to_add
      end
    end
  end

  local result_string = string.format(
    '%5s %s\n',
    mem.show_percents and column_headers[mem.columns.percent] or "MiB",
    column_headers[mem.columns.name]
  )
  local counter = 0
  for k, v in h_table.spairs(result, function(t,a,b) return t[b] < t[a] end) do
    result_string = result_string .. string.format(mem.show_percents and "%5.1f %s" or "%5d %s", v, k)
    counter = counter + 1
    if counter == mem.list_len then
      break
    end
    result_string = result_string .. '\n'
  end

  mem.notification = naughty.notify({
    text = result_string,
    timeout = mem.timeout,
    font = beautiful.mono_text_font,
    replaces_id = mem.get_notification_id(),
    position = beautiful.widget_notification_position,
  })
end


function mem.update()
  parse.find_values_in_file_async(
    "/proc/meminfo",
    "([%a]+):[%s]+([%d]+).+",
    { total = "MemTotal",
      free = "MemFree",
      available = "MemAvailable",
      buf = "Buffers",
      cache = "Cached",
      --shared = "Shmem",
      swap_total = "SwapTotal",
      swap_free = "SwapFree",
    },
    function(v) return math.floor(v / 1024) end,
    function(now)
      mem.now = now
      --mem.now.used = mem.now.total - (mem.now.free + mem.now.buf + mem.now.cache)
      mem.now.used = mem.now.total - mem.now.available
      mem.now.swap_used = mem.now.swap_total - mem.now.swap_free

      local msg = string.format(
        "%6s", mem.now.used .. "MB"
      )
      local swap_msg = ''
      local widget_icon
      local swap_widget_icon
      local display_swap

      local _ram_is_critical = (
        --mem.now.used > (mem.now.total * (1 - mem.swappiness * 0.8 / 100))
        mem.now.used > (mem.now.total * (1 - mem.swappiness * 0.8 / 100))
      )
      local _swap_is_critical = (
        mem.now.swap_used > (mem.now.swap_total * mem.critical_swap_ratio)
      )
      local _ram_is_high = (
        --mem.now.used > (mem.now.total * (1 - mem.swappiness / 100))
        mem.now.used > (mem.now.total * (1 - mem.swappiness / 100))
      )
      local _swap_is_high = (
        mem.now.swap_used > (mem.now.swap_total * mem.high_swap_ratio)
      )

      if _swap_is_critical or _swap_is_high then
        swap_msg = string.format(
          "%s", mem.now.swap_used .. "MB"
        )
        display_swap = true
        if _swap_is_critical then
          swap_widget_icon = beautiful.widget_mem_swap_critical
        else
        swap_widget_icon = beautiful.widget_mem_swap_high
        end
      else
        display_swap = false
      end

      if _ram_is_critical then
        widget_icon = beautiful.widget_mem_critical
      elseif _ram_is_high then
        widget_icon = beautiful.widget_mem_high
      else
        widget_icon = beautiful.widget_mem
      end

      if (
          _ram_is_critical or _swap_is_critical or
          (_swap_is_high and _ram_is_high)
      ) then
        mem.widget:set_error()
      elseif (
          _ram_is_high or _swap_is_high
      ) then
        mem.widget:set_warning()
      else
        mem.widget:set_normal()
        msg = mem.widget_text
      end

      mem.widget:set_text(msg)
      mem.swap_widget:set_text(swap_msg)
      mem.widget.progressbar:set_value(mem.now.used/mem.now.total)
      mem.swap_widget.progressbar:set_value(mem.now.swap_used/mem.now.swap_total)
      if display_swap ~= mem._display_swap then
        if display_swap then
          mem.widget:set_widgets({mem.ram_widget, mem.swap_widget})
        else
          mem.widget:set_widgets({mem.ram_widget})
        end
        mem._display_swap = display_swap
      end
      if widget_icon then
        mem.widget:set_image(widget_icon)
      end
      if swap_widget_icon then
        mem.swap_widget:set_image(swap_widget_icon)
      end
    end
  )
end


function mem._get_swappiness(callback)
  parse.filename_to_string_async('/proc/sys/vm/swappiness', function(result)
    mem.swappiness = tonumber(result)
    callback()
  end)
end


function mem.init(args)
  args = args or {}
  local update_interval  = args.update_interval or 5
  mem.timeout = args.timeout or 0
  mem.list_len = args.list_length or 10
  mem.widget_text = args.text or beautiful.widget_mem_text or 'RAM'

  local ram_widget = common_widgets.text_progressbar(args)
  local swap_widget = common_widgets.text_progressbar(args)
  mem.widget = common_widgets.decorated{widgets={ram_widget, }}
  mem.ram_widget = ram_widget
  mem.swap_widget = swap_widget
  mem.widget.progressbar = ram_widget.progressbar
  mem.widget.textbox = ram_widget.textbox

  if beautiful.show_widget_icon then
    mem.widget_text = args.text or ''
  end

  mem.widget:connect_signal(
    "mouse::enter", function () mem.show_notification() end
  )
  mem.widget:connect_signal(
    "mouse::leave", function () mem.hide_notification() end
  )
  mem.widget:buttons(awful.util.table.join(
    awful.button({ }, 3, function()
      mem.show_percents = not mem.show_percents
      mem.show_notification()
    end)
  ))

  local self_filepath = debug.getinfo(1)['short_src']
  local self_dirpath = h_string.join(
    '/',
    h_table.range(
      gears_string.split(self_filepath, '/'),
      0, -1
    )
  )
  mem.command = "HOME="..self_dirpath.." top -o \\%MEM -b -n 1 -w 512 -c -e m"
  mem.columns = args.columns or {
    percent=10,
    swap=11,
    name=13
  }
  mem._get_swappiness(function()
    gears_timer({
      callback=mem.update,
      timeout=update_interval,
      autostart=true,
      call_now=true,
    })
  end)

  return mem.widget
end


return setmetatable(mem, { __call = function(_, ...) return mem.init(...) end })
