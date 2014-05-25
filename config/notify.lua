local naughty = require("naughty")
local beautiful = require("beautiful")

local awesome = awesome

local notify = {}

function notify.init(status)
  naughty.config.presets.normal.opacity = beautiful.notification_opacity
  naughty.config.presets.low.opacity = beautiful.notification_opacity
  naughty.config.presets.critical.opacity = beautiful.notification_opacity

  naughty.config.presets.normal.font = beautiful.notification_font
  naughty.config.presets.low.font = beautiful.notification_font
  naughty.config.presets.critical.font = beautiful.notification_font


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
