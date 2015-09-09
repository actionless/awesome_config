local awful = require("awful")
local beautiful = require("beautiful")

local titlebar	= require("actionless.titlebar")

local delayed_call = require("gears.timer").delayed_call


local debug_messages_enabled = false
local log = function(...) if debug_messages_enabled then nlog(...) end end


local signals = {}

function signals.init(awesome_context)

local function on_client_focus(c)
  local layout = awful.layout.get(c.screen)
  c.border_color = beautiful.border_focus
  if awesome_context.show_titlebar and #awful.client.tiled(c.screen) > 1 then
    log("F: tile: titlebars enabled explicitly")
    c.border_width = beautiful.border_width
    titlebar.make_titlebar(c)
  elseif c.maximized then
    log("F: maximized")
    titlebar.remove_border(c)
  elseif awful.client.floating.get(c) then
    log("F: floating client")
    c.border_width = beautiful.border_width
    titlebar.make_titlebar(c)
  elseif layout == awful.layout.suit.floating then
    log("F: floating layout")
    c.border_width = beautiful.border_width
    titlebar.make_titlebar(c)
  elseif #awful.client.tiled(c.screen) == 1 then
    if awful.tag.getgap() == 0 then
      log("F: one tiling client: no-gap")
      titlebar.remove_border(c)
    else
      log("F: one tiling client: gap")
      c.border_width = beautiful.border_width
      titlebar.remove_titlebar(c)
    end
  else
    log("F: more tiling clients")
    c.border_width = beautiful.border_width
    titlebar.remove_titlebar(c)
  end
  --print(c:get_xproperty('_GTK_APP_MENU_OBJECT_PATH'))
end

local function on_client_unfocus (c)
  local layout = awful.layout.get(c.screen)
  c.border_color = beautiful.border_normal
  if awesome_context.show_titlebar and #awful.client.tiled(c.screen) > 1 then
    log("U: tile: titlebars enabled explicitly")
    c.border_width = beautiful.border_width
    titlebar.make_titlebar(c)
  elseif awful.client.floating.get(c) then
    log("U: floating client")
    c.border_color = beautiful.titlebar_border
  elseif layout == awful.layout.suit.floating then
    log("U: floating layout")
    c.border_color = beautiful.titlebar_border
  elseif #awful.client.tiled(c.screen) == 1 then
    if awful.tag.getgap() == 0 then
      log("U: one tiling client: no-gap")
      titlebar.remove_border(c)
    else
      log("U: one tiling client: gap")
      c.border_color = beautiful.border_normal
      c.border_width = beautiful.border_width
      titlebar.remove_titlebar(c)
    end
  else
    log("U: more tiling clients")
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
  delayed_call(function()
    return on_client_focus(c)
  end)
end)

client.connect_signal("property::minimized", function (c)
  if c.minimized then
    c.skip_taskbar = false
  elseif titlebar.is_enabled(c) then
    c.skip_taskbar = true
  end
end)

end

return signals
