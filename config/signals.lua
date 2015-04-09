local awful = require("awful")
local client = client
local beautiful = require("beautiful")

local titlebar	= require("actionless.titlebar")
local lain = require("third_party.lain")


local signals = {}

function signals.init(awesome_context)

local function on_client_focus(c)
<<<<<<< Updated upstream
  local layout = awful.layout.get(c.screen)
  if c.maximized_horizontal == true and c.maximized_vertical == true then
=======
  if c.maximized then
>>>>>>> Stashed changes
    -- maximized
    titlebar.remove_border(c)
  elseif awful.client.floating.get(c) then
    -- floating client
    c.border_width = beautiful.border_width
    titlebar.make_titlebar(c)
<<<<<<< Updated upstream
  elseif layout == awful.layout.suit.floating then
=======
    print(awful.client.floating.get(c))
    print("DEBUG")
  elseif awful.layout.get(c.screen) == awful.layout.suit.floating then
>>>>>>> Stashed changes
    -- floating layout
    c.border_width = beautiful.border_width
    titlebar.make_titlebar(c)
  elseif #awful.client.tiled(c.screen) == 1 and not (
    layout == lain.layout.centerwork
    or layout == lain.layout.uselesstile
  ) then
    -- one tiling client
    titlebar.remove_border(c)
  else
    -- more tiling clients
    titlebar.remove_titlebar(c)
    c.border_width = beautiful.border_width
    c.border_color = beautiful.border_focus
  end
  --print(c:get_xproperty('_GTK_APP_MENU_OBJECT_PATH'))
end

local function on_client_unfocus (c)
  local layout = awful.layout.get(c.screen)
  if awful.client.floating.get(c) then
    -- floating client
    c.border_color = beautiful.titlebar_border
  elseif layout == awful.layout.suit.floating then
    -- floating layout
    c.border_color = beautiful.titlebar_border
  elseif #awful.client.tiled(c.screen) == 1 and not (
    layout == lain.layout.centerwork
    or layout == lain.layout.uselesstile
  ) then
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
  elseif not c.size_hints.user_position and not c.size_hints.program_position then
    -- Prevent clients from being unreachable after screen count change
    awful.placement.no_offscreen(c)
  end
end)

client.connect_signal("focus", function(c)
  return on_client_focus(c)
end)

client.connect_signal("unfocus", function(c)
  return on_client_unfocus(c)
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

client.connect_signal("property::maximized", function (c)
  return on_client_focus(c)
end)

client.connect_signal("property::minimized", function (c)
  if c.minimized then
    c.skip_taskbar = false
  elseif titlebar.is_enabled(c) then
    c.skip_taskbar = true
  end
end)

end
-- }}}
return signals
