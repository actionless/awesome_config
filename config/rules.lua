local awful = require("awful")
local beautiful = require("beautiful")
local capi = {
  screen = screen
}
local dpi = beautiful.xresources.apply_dpi


local function apply_delayed_rule(c)
  if not c.class and not c.name then
    local begin_message = {"begin", c.class, c.name}
    local f
    f = function(_c)
        _c:disconnect_signal("property::class", f)
        if _c.class == "Spotify" then
            awful.rules.apply(_c)
        else
          nlog(begin_message)
          nlog({"end", _c.class, _c.name})
        end
    end
    c:connect_signal("property::class", f)
  end
end


local rules = {}

function rules.init(awesome_context)

  awful.rules.rules = {

      { rule = { },
        properties = {
          --border_width = beautiful.border_width,
          --border_color = beautiful.border_normal,
          focus = awful.client.focus.filter,
          raise = true,
          keys = awesome_context.clientkeys,
          buttons = awesome_context.clientbuttons,
          placement =
            awful.placement.centered +
            awful.placement.no_overlap, --+
            --awful.placement.no_offscreen,
          size_hints_honor = false,
          screen = awful.screen.preferred,
          --slave = true,
          --slave = awesome_context.DEVEL_DYNAMIC_LAYOUTS,
        },
        --callback = apply_delayed_rule,
        callback = function(c)
          --if not awesome_context.DEVEL_DYNAMIC_LAYOUTS then
            awful.client.setslave(c)
          --end
          apply_delayed_rule(c)
        end
      },
      { rule = {type = "dialog"},
        properties = {
          titlebars_enabled = true,
          ontop = true
        },
      },

      -- Applications:

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
      }, },
      { rule = { class = "Transmission-gtk", role = "tr-info" },
        properties = {
          floating = false,
          ontop = false,
      }, },
      { rule = { class = "Transmission-gtk", name = "Torrent Options" },
        properties = {
          width = dpi(800),
      }, },

      { rule = { class = "qBittorent"},
        properties = {
          tag=capi.screen.primary.tags[6],
        },
      },

      { rule = { name = "xfce4-panel"},
        properties = {
          valid=false,
        },
        callback = function(c)
          c.valid = false
          c.focusable = false
        end,
      },

      { rule = { class = "Pidgin"},
        properties = {
          tag=capi.screen.primary.tags[10],
        },
      },
      { rule = { class = "Pidgin", role = "buddy_list"},
        properties = {
          placement = awful.placement.top_right,
        },
        callback = function(c)
          local wa = c.screen.workarea
          local g = c:geometry()
          g.x = wa.x + wa.width - g.width - (beautiful.useless_gap*9) - (beautiful.border_width*2)
          g.y = wa.y + (beautiful.useless_gap*6)
          c:geometry(g)
        end
      },
      { rule = { class = "Pidgin", role = "smiley_dialog"},
        properties = {
          placement = awful.placement.centered,
        },
      },

      { rule = { class = "mpv" },
        properties = {
          size_hints_honor = true,
        }
      },

  }

  --awful.ewmh.add_activate_filter(function(c, source)
      --nlog({source, c.class})
      --if source=="rules" and c.class == "Firefox-developer-edition" then
        --return false
      --end
  --end)
  --
end

return rules
