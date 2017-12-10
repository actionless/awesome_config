local naughty = require("naughty")
local beautiful = require("beautiful")
local gfs = require("gears.filesystem")
local surface = require("gears.surface")
local util = require("awful.util")

local awesome = awesome

local notify = {}

function notify.init(_)

  naughty.config.padding = beautiful.useless_gap
  naughty.config.defaults.opacity = beautiful.notification_opacity
  naughty.config.defaults.font = beautiful.notification_font
  naughty.config.defaults.bg = beautiful.notification_bg
  naughty.config.defaults.fg = beautiful.notification_fg
  naughty.config.defaults.border_color = beautiful.notification_border_color
  naughty.config.defaults.border_width = beautiful.notification_border_width
  naughty.config.defaults.margin = beautiful.notification_margin

  naughty.config.presets.low.opacity = beautiful.notification_opacity
  naughty.config.presets.low.font = beautiful.notification_font

  naughty.config.presets.critical.opacity = beautiful.notification_opacity
  naughty.config.presets.critical.font = beautiful.notification_font

  local naughty_max_icon_size = beautiful.notification_max_icon_size
  -- a) notification icons will be hardcoded to the size:
  --naughty.config.defaults.icon_size = naughty_max_icon_size
  -- b) notification icons will be only downscaled if bigger than max size:
  naughty.config.notify_callback = function(args)
    if args.icon then
      local icon = args.icon
      -- Is this really an URI instead of a path?
      if type(icon) == "string" and string.sub(icon, 1, 7) == "file://" then
          icon = string.sub(icon, 8)
          -- urldecode URI path
          icon = string.gsub(icon, "%%(%x%x)", function(x) return string.char(tonumber(x, 16)) end )
      end
      -- try to guess icon if the provided one is non-existent/readable
      if type(icon) == "string" and not gfs.file_readable(icon) then
          icon = util.geticonpath(icon, naughty.config.icon_formats, naughty.config.icon_dirs) or icon
      end
      -- is the icon file readable?
      icon = surface.load_uncached(icon)
      -- if we have an icon inspect its size
      if icon then
          local icon_w = icon:get_width()
          local icon_h = icon:get_height()
          if icon_h > naughty_max_icon_size or icon_w > naughty_max_icon_size then
            args.icon_size = naughty_max_icon_size
          end
      end
    end
    return args
  end


  -- {{{ Error handling
  -- Check if awesome encountered an error during startup and fell back to
  -- another config (This code will only ever execute for the fallback config)
  if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
  end

  -- Handle runtime errors after startup
  do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
      -- Make sure we don't go into an endless error loop
      if in_error then return end
      in_error = true

      naughty.notify({ preset = naughty.config.presets.critical,
                       title = "Oops, an error happened!",
                       text = err })
      in_error = false
    end)
  end
  -- }}}
end
return notify
