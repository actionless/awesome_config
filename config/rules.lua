local awful = require("awful")
local capi = {
  screen = screen
}


local rules = {}

function rules.init(awesome_context)

  -- Rules to apply to new clients (through the "manage" signal).
  awful.rules.rules = {

      -- All clients will match this rule.
      { rule = { },
        properties = {
          --border_width = beautiful.border_width,
          --border_color = beautiful.border_normal,
          focus = awful.client.focus.filter,
          raise = true,
          keys = awesome_context.clientkeys,
          buttons = awesome_context.clientbuttons,
          placement = awful.placement.no_overlap+awful.placement.no_offscreen,
          size_hints_honor = false,
          screen = awful.screen.preferred,
        },
        callback = function(c)
          awful.client.setslave(c)
          if not c.class and not c.name then
            nlog({"begin", c.class, c.name})
            local f
            f = function(_c)
                nlog({"end", _c.class, _c.name})
                _c:disconnect_signal("property::class", f)
                if _c.class == "Spotify" then
                    awful.rules.apply(_c)
                end
            end
            c:connect_signal("property::class", f)
          end
        end
      },
      -- Add titlebars to normal clients and dialogs
      { rule = {type = "dialog"},
        properties = {
          titlebars_enabled = true,
          ontop = true
        },
      },

      { rule = { class = "Skype" },
        properties = {
          tag=capi.screen.primary.tags[4],
          raise=false
        }
      },

      { rule = { class = "Spotify" },
        properties = {
          tag=capi.screen.primary.tags[7],
          raise=false
        }
      },

      { rule = { class = "Transmission-gtk"},
        properties = {
          tag=capi.screen.primary.tags[6],
        },
      },
      { rule = { class = "Transmission-gtk", role = "tr-info" },
        properties = {
          floating = false,
          ontop = false,
        },
      },

      { rule = { class = "Onboard"},
        callback = function(c)
          nlog(c)
          c.focusable = false
          c.valid = false
          c.ontop = true
          c.sticky = true
        end
      },

  }
  --awful.ewmh.add_activate_filter(function(c, source)
      --nlog({source, c.class})
      --if source=="rules" and c.class == "Firefox-developer-edition" then
        --return false
      --end
  --end)
end
return rules
