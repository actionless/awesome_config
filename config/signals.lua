local awful = require("awful")
local beautiful = require("beautiful")
local delayed_call = require("gears.timer").delayed_call

local titlebar	= require("actionless.titlebar")
local persistent = require("actionless.persistent")


local debug_messages_enabled = false
local log = function(...) if debug_messages_enabled then nlog(...) end end


local signals = {}

function signals.init(_)

  awful.tag.object.get_gap = function(t)
    t = t or awful.tag.selected()
    if #awful.client.tiled(t.screen) == 1 and t.master_fill_policy == "expand" then
        return 0
    end
    return awful.tag.getproperty(t, "useless_gap") or beautiful.useless_gap or 0
  end


local function on_client_focus(c)
  local t = awful.screen.focused().selected_tag
  local layout = awful.layout.get(c.screen)
  local num_tiled = #awful.client.tiled(c.screen)

  c.border_color = beautiful.border_focus

  if persistent.titlebar.get() and (
    num_tiled > 1 or (
      num_tiled > 0 and t.master_fill_policy ~= 'expand'
    )
  ) then
    log("F: tile: titlebars enabled explicitly")
    c.border_width = beautiful.border_width
    titlebar.make_titlebar(c)
  elseif c.maximized then
    log("F: maximized")
    titlebar.remove_border(c)
  elseif c.floating then
    log("F: floating client")
    c.border_width = beautiful.border_width
    titlebar.make_titlebar(c)
  elseif layout == awful.layout.suit.floating then
    log("F: floating layout")
    c.border_width = beautiful.border_width
    titlebar.make_titlebar(c)
  elseif num_tiled == 1 then
    if t.master_fill_policy == 'expand' then
      log("F: one tiling client: expand")
      titlebar.remove_border(c)
    else
      log("F: one tiling client")
      titlebar.remove_titlebar(c)
      c.border_width = beautiful.border_width
    end
  else
    log("F: more tiling clients")
    c.border_width = beautiful.border_width
    titlebar.remove_titlebar(c)
  end
end

local function on_client_unfocus (c)
  local t = awful.screen.focused().selected_tag
  local layout = awful.layout.get(c.screen)
  local num_tiled = #awful.client.tiled(c.screen)

  if persistent.titlebar.get() and (
    num_tiled > 1 or (
      num_tiled > 0 and t.master_fill_policy ~= 'expand'
    )
  ) then
    log("U: tile: titlebars enabled explicitly")
    c.border_width = beautiful.border_width
    titlebar.make_titlebar(c)
    c.border_color = beautiful.border_normal
  elseif c.floating then
    log("U: floating client")
    c.border_color = beautiful.titlebar_border
  elseif layout == awful.layout.suit.floating then
    log("U: floating layout")
    c.border_color = beautiful.titlebar_border
  elseif num_tiled == 1 then
    if t.master_fill_policy == 'expand' then
      log("U: one tiling client: expand")
      titlebar.remove_border(c)
    else
      log("U: one tiling client")
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
  t = t or awful.tag.selected(awful.screen.focused())
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
