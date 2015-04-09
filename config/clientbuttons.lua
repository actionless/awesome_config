local awful = require("awful")
local client = client

local clientbuttons = {}
function clientbuttons.init(awesome_context)
  local modkey = awesome_context.modkey
  awesome_context.clientbuttons = awful.util.table.join(
    awful.button({ }, 1,
      function (c)
        client.focus = c;
        c:raise();
      end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
  )
  awesome_context.clientbuttons_manage = awful.util.table.join(
    awful.button({ }, 1,
      function (c)
        client.focus = c;
        c:raise();
      end),
    awful.button({ }, 1, awful.mouse.client.move),
    awful.button({ }, 3, awful.mouse.client.resize)
  )
  end
return clientbuttons
