local awful = require("awful")
awful.rules = require("awful.rules")


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
        size_hints_honor = false
      },
      callback = awful.client.setslave
    },

    { rule = { class = "Skype" },
      properties = { tag=awesome_context.tags[1][4], raise=false } },
    { rule = { class = "Spotify" },
      properties = { tag=awesome_context.tags[1][7], raise=false } },

    { rule = { name = "Terminator Preferences" },
      properties = { floating = true } },
    { rule = { name = "Pinterest / Pin it. - Mozilla Firefox" },
      properties = { floating = true } },
    { rule_any = { class = { "pinentry", "Guake", "feh" } },
      properties = { floating = true } },

    { rule_any = { class = { "Transmission-gtk",  } },
      properties = { floating = false } },
      
  }
end
return rules
