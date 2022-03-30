local awful = require("awful")
local capi = {
  root = root,
}

local tag_helpers = require("actionless.util.tag")

local mouse = {}
function mouse.init(awesome_context)
  local modkey = awesome_context.modkey

  -- {{{ Client mouse bindings
  awful.layout.suit.floating.resize_jump_to_corner = false
  awful.layout.suit.tile.resize_jump_to_corner = false

  awesome_context.clientbuttons = awful.util.table.join(
    awful.button({ }, 1,
      function (c)
        if c.focusable then
          client.focus = c;
          c:raise();
        end
      end),
    awful.button({ }, 3,
      function (c)
        if c.focusable then
          client.focus = c;
          c:raise();
        end
      end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, function(c)
      awful.mouse.resize(c, nil, {jump_to_corner=false})
    end),
    awful.button({ modkey, "Control" }, 1, function(c)
      awful.mouse.resize(c, nil, {jump_to_corner=false})
    end)
  )
  -- }}}


  -- {{{ Root mouse bindings
  capi.root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () awesome_context.menu.mainmenu_toggle() end),
    awful.button({ }, 4, function()
      tag_helpers.view_noempty(-1)
    end),
    awful.button({ }, 5, function()
      tag_helpers.view_noempty(1)
    end)
  ))
  -- }}}

end
return mouse
