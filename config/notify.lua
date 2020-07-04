local naughty = require("naughty")
local beautiful = require("beautiful")
local ruled = require("ruled")
local awful = require("awful")
local gears = require("gears")

local notify = {}
function notify.init(awesome_context)

  naughty.config.padding = beautiful.useless_gap
  naughty.config.defaults.opacity = beautiful.notification_opacity
  naughty.config.defaults.font = beautiful.notification_font
  naughty.config.defaults.bg = beautiful.notification_bg
  naughty.config.defaults.fg = beautiful.notification_fg
  naughty.config.defaults.border_color = beautiful.notification_border_color
  naughty.config.defaults.border_width = beautiful.notification_border_width
  naughty.config.defaults.margin = beautiful.notification_margin
  naughty.config.defaults.padding = beautiful.notification_spacing

  naughty.config.presets.low.opacity = beautiful.notification_opacity
  naughty.config.presets.low.font = beautiful.notification_font

  naughty.config.presets.critical.opacity = beautiful.notification_opacity
  naughty.config.presets.critical.font = beautiful.notification_font
  naughty.config.presets.critical.bg = beautiful.fg_urgent
  naughty.config.presets.critical.fg = beautiful.bg_urgent

  ruled.notification.connect_signal('request::rules', function()
    ruled.notification.append_rules{
      {
        -- All notifications will match this rule.
        rule       = {},
        properties = {
          screen           = awful.screen.preferred,
          implicit_timeout = 5,
        },
      },{
        rule       = { },
        except_any = {app_name = {'', "xfce4-power-manager"}},
        callback = function(notification)
          awesome_context.widgets.naughty_counter:add_notification(notification)
        end
      }
    }
  end)

  naughty.persistence_enabled = true
  naughty.connect_signal('request::preset', function(n, _, args)
    n.args = args
  end)
  naughty.connect_signal('request::display', function(n, _, args)
    if (
      n.app_name ~= '' and
      awesome_context.widgets.naughty_counter and
      awesome_context.widgets.naughty_counter.sidebar and
      awesome_context.widgets.naughty_counter.sidebar.visible
    ) then
      return
    end
    n:set_title('<b>'..n:get_title()..'</b>')
    local box = naughty.layout.box{
      notification = n,
      -- workaround for https://github.com/awesomeWM/awesome/issues/3081 :
      shape = function(cr,w,h)
        gears.shape.rounded_rect(
          cr, w, h, beautiful.notification_border_radius+beautiful.notification_border_width+1
        )
      end,
    }
    if args.run then
      local buttons = box:buttons()
      buttons = awful.util.table.join(buttons,
        awful.button({}, 1,
        function()
          args.run(n)
        end)
      )
      box:buttons(buttons)
    end
  end)

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
