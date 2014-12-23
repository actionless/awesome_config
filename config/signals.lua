local awful = require("awful")
local client = client
local beautiful = require("beautiful")

local titlebar	= require("actionless.titlebar")


local signals = {}

function signals.init(awesome_context)

local function on_client_focus(c)
  if c.maximized_horizontal == true and c.maximized_vertical == true then
    -- maximized
    titlebar.remove_border(c)
    titlebar.remove_titlebar(c)
  elseif awful.client.floating.get(c) then
    -- floating client
    c.border_width = beautiful.border_width
    titlebar.make_titlebar(c)
  elseif awful.layout.get(c.screen) == awful.layout.suit.floating then
    -- floating layout
    c.border_width = beautiful.border_width
    titlebar.make_titlebar(c)
  elseif #awful.client.tiled(c.screen) == 1 then
    -- one tiling client
    titlebar.remove_border(c)
  else
    -- more tiling clients
    titlebar.remove_titlebar(c)
    c.border_width = beautiful.border_width
    c.border_color = beautiful.border_focus
  end
end

local function on_client_unfocus (c)
  if awful.client.floating.get(c) then
    -- floating client
    c.border_color = beautiful.titlebar_border
  elseif awful.layout.get(c.screen) == awful.layout.suit.floating then
    -- floating layout
    c.border_color = beautiful.titlebar_border
  elseif #awful.client.tiled(c.screen) == 1 then
    -- one tiling client
    titlebar.remove_border(c)
  else
    -- more tiling clients
    titlebar.remove_titlebar(c)
    c.border_width = beautiful.border_width
    c.border_color = beautiful.border_normal
  end
end

-- New client appears
client.connect_signal("manage", function (c, startup)
  if
    not startup and not c.size_hints.user_position
  and
    not c.size_hints.program_position
  then
      awful.placement.no_overlap(c)
      awful.placement.no_offscreen(c)
  end
end)

tag.connect_signal("property::layout", function (t)
  for _, c in ipairs(t.clients(t)) do
    if c == client.focus then
      on_client_focus(c)
    else
      on_client_unfocus(c)
    end
  end
end)

client.connect_signal("property::maximized_vertical", function (c)
  return on_client_focus(c)
end)

client.connect_signal("focus", function(c)
  return on_client_focus(c)
end)

client.connect_signal("unfocus", function(c)
  return on_client_unfocus(c)
end)

end
-- }}}
return signals
