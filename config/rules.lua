local awful = require("awful")
local beautiful = require("beautiful")
local ruled = require("ruled")
local capi = {
  screen = screen
}
local dpi = beautiful.xresources.apply_dpi
local gears_timer = require("gears.timer")
local delayed_call = gears_timer.delayed_call

local nlog = require("actionless.util.debug").naughty_log


local function apply_delayed_rule(c)  -- luacheck: no unused
  if not c.class and c.name == "" then
    local begin_message = {"begin", c.class, c.name}
    local f
    f = function(c2)
        c2:disconnect_signal("property::class", f)
        if c2.class == "Spotify" then
            awful.rules.apply(c2)
        else
          nlog(begin_message)
          nlog({"end", c2.class, c2.name})
        end
    end
    c:connect_signal("property::class", f)
  end
end


local rules = {}

local no_offscreen_margined_placement = setmetatable(
              {
                is_placement = true,
                context = {},
              },
              {
                __call = function(_self, c, args)
                  args.honor_workarea = true
                  if not c.maximized then
                      local bm = beautiful.useless_gap + (beautiful.base_border_width or beautiful.border_width)
                      args.margins = {
                        left = bm,
                        right = bm*2,
                        top = bm,
                        bottom = (
                          bm + (beautiful.titlebar_height or 0) +
                          (beautiful.base_border_width or beautiful.border_width)
                        ),
                      }
                  end
                  return awful.placement.no_offscreen(c, args)
                end
              }
            --)
            )

function rules.init(awesome_context)

  ruled.client.connect_signal("request::rules", function()
    for _, rule in ipairs({

      { rule = { },
        --apply_on_restart=true,
        properties = {
          --border_width = beautiful.border_width,
          --border_color = beautiful.border_normal,
          focus = awful.client.focus.filter,
          raise = true,
          keys = awesome_context.clientkeys,
          buttons = awesome_context.clientbuttons,
          placement =
            awful.placement.centered +
            awful.placement.no_overlap +
            no_offscreen_margined_placement +
            awful.placement.skip_fullscreen,
          size_hints_honor = false,
          screen = awful.screen.preferred,
          --slave = true,
          --slave = awesome_context.DEVEL_DYNAMIC_LAYOUTS,
        },
        --callback = apply_delayed_rule,
        callback = function(c)
          c:deny("autoactivate", "mouse_enter")
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

      { rule = {class = "Nemo", instance = "file_progress"},
        properties = {
          titlebars_enabled = true,
          ontop = true,
        },
      },

      -- Applications:

      { rule_any = { class = {"Skype", "Microsoft Teams - Preview", } },
        properties = {
          tag=capi.screen.primary.tags[4],
          raise=false
        }
      },

      { rule_any = { class = {"Shortwave", "Goodvibes", "Spotify", } },
        properties = {
          tag=capi.screen.primary.tags[7],
          raise=false
        }
      },

      { rule = { class = "Tixati"},
        properties = {
          tag=capi.screen.primary.tags[6],
      }, },

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
          width = dpi(700),
          height = dpi(900),
          --placement = awful.placement.center,
        },
        callback = function(c)
          local wa = c.screen.workarea
          local g = c:geometry()
          g.x = (wa.width - g.width) / 2
          g.y = (wa.height - g.height) / 2
          c:geometry(g)
        end
      },

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

      { rule = { class = "ghostwriter", type = "dialog"},
        properties = {
          titlebars_enabled = false,
        },
        callback = function(c)
          c.titlebars_enabled = false
        end,
      },

      { rule = { class = "mpv" },
        properties = {
          size_hints_honor = true,
        }
      },

      { rule = { class = "Oomox", },
        properties = {
          floating = true,
        },
      },

      { rule_any = { class = {"MEGAsync"}, },
        properties = {
          floating = true,
        },
        callback = function(c)
          c.titlebars_enabled = false
        end,
      },

      { rule_any = { class = {
          "Blueman-manager",
          "easyeffects",
          "bluetooth_workaround_cli"
        }, },
        properties = {
          tag=capi.screen.primary.tags[11],
          raise=false,
        },
      },
      { rule = { class = "Carla2", name = "Carla - switch_multicomp.carxp" },
        properties = {
          width = dpi(1770),
          height = dpi(286),
          placement = no_offscreen_margined_placement,
          tag=capi.screen.primary.tags[11],
          raise=false,
        },
        callback = function(c)
          c:deny('geometry', 'arghhh_g')
          c:deny('client_geometry_requests', 'arghhh_cgr')
          --c:connect_signal("property::floating_geometry", function(c2)
          --end)
          --c:connect_signal("property::width", function(c2)
          --  nlog("Carla1")
          --  local g = c2:geometry()
          --  g.width = dpi(1770)
          --  g.height = dpi(286)
          --  c2:geometry(g)
          --end)
          c:connect_signal("request::geometry", function(c2)
            --nlog("Carla2")
            local g = c2:geometry()
            g.x = dpi(50)
            g.y = dpi(50)
            g.width = dpi(1770)
            g.height = dpi(286)
            delayed_call(function()
              c2:geometry(g)
              --nlog(c2:geometry())
            end)
          end)
        end
      },
      { rule = { class = "easyeffects" },
        properties = {
          width = dpi(1024),
          --height = dpi(768),
          height = dpi(708),
          placement = no_offscreen_margined_placement,
          tag=capi.screen.primary.tags[11],
          raise=false,
        },
      },


      { rule_any = { class = {"Blueman-manager",}, },
        properties = {
          width = dpi(480),
          placement =
            awful.placement.bottom_right +
            awful.placement.no_overlap +
            no_offscreen_margined_placement +
            awful.placement.skip_fullscreen,
        },
        apply_on_restart = true,
        callback = function(c)
          c:deny('geometry', 'arghhh')
          --c:deny('client_geometry_requests', 'arghhh')
          --c:connect_signal("property::floating_geometry", function(c2)
          --end)
          c:connect_signal("property::width", function(c2)
            local g = c2:geometry()
            g.width = dpi(480)
            c2:geometry(g)
          end)
          c:connect_signal("request::geometry", function(c2)
            local g = c2:geometry()
            g.width = dpi(480)
            c2:geometry(g)
          end)
        end
      },

    }) do
      ruled.client.append_rule(rule)
    end
    for i, _ in ipairs(screen.primary.tags) do
      ruled.client.append_rule(
        { rule = { instance = "tag"..tostring(i) },
          properties = {
            tag=capi.screen.primary.tags[i],
            raise=false
          }
        }
      )
    end
  end)

  --awful.ewmh.add_activate_filter(function(c, source)
      --nlog({source, c.class})
      --if source=="rules" and c.class == "Firefox-developer-edition" then
        --return false
      --end
  --end)
  --
end

return rules
