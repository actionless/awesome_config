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
          size_hints_honor = false
        },
        callback = awful.client.setslave
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

      --{ rule = { class = "Spotify" },
        --properties = {
          --tag=capi.screen.primary.tags[7],
          --raise=false
        --}
      --},

      { rule = { class = "Transmission-gtk"},
        properties = {
          tag=capi.screen.primary.tags[6],
        },
      },
      { rule = { class = "Transmission-gtk", role = "tr-info" },
        properties = {
          floating = false
        },
      },

  }
end
return rules
