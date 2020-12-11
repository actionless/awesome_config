local naughty = require("naughty")
local beautiful = require("beautiful")

local naughty_sidebar = require("actionless.widgets.naughty_sidebar")


local notify = {}
function notify.init(_awesome_context)

  naughty.config.padding = beautiful.useless_gap
  naughty.config.defaults.font = beautiful.notification_font
  naughty.config.defaults.bg = beautiful.notification_bg
  naughty.config.defaults.bg = "#00000000"  -- fix for doubled bg with opacity
  naughty.config.defaults.fg = beautiful.notification_fg
  naughty.config.defaults.border_color = beautiful.notification_border_color
  naughty.config.defaults.border_width = beautiful.notification_border_width
  naughty.config.defaults.margin = beautiful.notification_margin
  naughty.config.defaults.padding = beautiful.notification_spacing

  naughty.config.presets.low.font = beautiful.notification_font

  naughty.config.presets.critical.font = beautiful.notification_font
  naughty.config.presets.critical.bg = beautiful.fg_urgent
  naughty.config.presets.critical.fg = beautiful.bg_urgent

  naughty_sidebar.init_naughty{
    skip_rule={app_name = {'', "xfce4-power-manager"}},
  }

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
