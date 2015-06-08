local awful = require("awful")
local wibox = require("wibox")
local client = client
local beautiful = require("beautiful")

local titlebar	= require("actionless.titlebar")
local lain = require("third_party.lain")
local helpers = require("actionless.helpers")

local delayed_call = require("gears.timer").delayed_call


local signals = {}

function signals.init(awesome_context)

local function on_client_focus(c)
  local layout = awful.layout.get(c.screen)
  if awesome_context.show_titlebar then
    -- titlebars enabled explicitly
    --nlog(" titlebars enabled explicitly")
    c.border_color = beautiful.border_focus
    c.border_width = beautiful.border_width
    titlebar.make_titlebar(c)
  elseif c.maximized then
    -- maximized
    --nlog("maximized")
    titlebar.remove_border(c)
  elseif awful.client.floating.get(c) then
    -- floating client
    --nlog("-- floating client")
    c.border_width = beautiful.border_width
    titlebar.make_titlebar(c)
  elseif layout == awful.layout.suit.floating then
    -- floating layout
    --nlog("floating layout")
    c.border_width = beautiful.border_width
    titlebar.make_titlebar(c)
  elseif #awful.client.tiled(c.screen) == 1 and not (
    layout == lain.layout.centerwork
    or layout == lain.layout.uselesstile
  ) then
    -- one tiling client
    --nlog("-- one tiling client")
    titlebar.remove_border(c)
  else
    -- more tiling clients
    --nlog("-- more tiling clients")
    c.border_width = beautiful.border_width
    c.border_color = beautiful.border_focus
    titlebar.remove_titlebar(c)
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
    if not awesome_context.show_titlebar then
      titlebar.remove_titlebar(c)
    else
      titlebar.make_titlebar(c)
    end
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


----------------------------------------

local function lcars_unite(t, from)
  if not awesome_context.lcars_is_separated then return end
  --nlog("unite|"..from)
  local s = helpers.get_current_screen()
  local w = awesome_context.topwibox[s]
  w:struts({top = beautiful.panel_height})
  w:geometry({height = beautiful.panel_height})
  awful.wibox.set_position(w, "top", s)
  awesome_context.leftwibox_separator[s]:set_height(0)
  awesome_context.internal_corner_wibox[s]:geometry({y = beautiful.basic_panel_height})
  awesome_context.topwibox_layout[s]:set_first(nil)
  awesome_context.top_internal_corner_wibox[s].visible = false

  awesome_context.left_panel_top_layouts[s]:reset()
  awesome_context.left_panel_bottom_layouts[s]:reset()
  for i, widget in ipairs(awesome_context.left_panel_widgets[s]) do
      awesome_context.left_panel_bottom_layouts[s]:add(widget)
  end

  awesome_context.lcars_is_separated = false
end

local function lcars_separate(t, from)
  local s = awful.tag.getscreen(t)
  local nmaster = awful.tag.getnmaster(t)
  if nmaster < 1 or #awful.client.tiled(s) <= nmaster then
    return lcars_unite(t, from)
  end
  --nlog("separate|"..from)
  local w = awesome_context.topwibox[s]
  if not awesome_context.lcars_is_separated then
    w:struts({top = 0})
  end
  local mwfact =  awful.tag.getmwfact(t)
  local height = screen[s].workarea.height
  local computed_y = math.floor(
    (height-beautiful.panel_height)*(1-mwfact) + beautiful.useless_gap_width
  )
  if awesome_context.lcars_is_separated
    and computed_y == awesome_context.lcars_last_y
  then return end
  --nlog("--not cached")
  awesome_context.lcars_last_y = computed_y

  w:geometry({height = beautiful.panel_height * 2 + beautiful.panel_padding_bottom})
  w:struts({top = 0})
  w:geometry({y = computed_y - beautiful.panel_height - beautiful.panel_padding_bottom })

  awesome_context.leftwibox_separator[s]:set_height(computed_y)

  awesome_context.internal_corner_wibox[s]:geometry({y = computed_y+beautiful.basic_panel_height})
  awesome_context.top_internal_corner_wibox[s].visible = true
  awesome_context.top_internal_corner_wibox[s]:geometry({
    y = computed_y-beautiful.panel_height - beautiful.left_panel_internal_corner_radius
  })

  awesome_context.topwibox_layout[s]:set_first(awesome_context.topwibox_toplayout[s])


  awesome_context.left_panel_top_layouts[s]:reset()
  awesome_context.left_panel_bottom_layouts[s]:reset()
  local height_sum = 0
  local last_bottom_widget_id = 1
  for i, widget in ipairs(awesome_context.left_panel_widgets[s]) do
    if widget._height and widget._height + height_sum < computed_y - (beautiful.left_panel_width/2) then
      awesome_context.left_panel_top_layouts[s]:add(widget)
      height_sum = height_sum + widget._height
      last_bottom_widget_id = i
    else
      break
    end
  end
  for c = last_bottom_widget_id, #awesome_context.left_panel_widgets[s] do
    awesome_context.left_panel_bottom_layouts[s]:add(awesome_context.left_panel_widgets[s][c])
  end

  awesome_context.lcars_is_separated = true
end


local function tag_callback(t, from)
  if not t then t = awful.tag.selected(helpers.get_current_screen()) end

  if not t.selected then return end
  if awful.tag.getproperty(t, 'layout').name == 'lcars' then
    lcars_separate(t, from)
  else
    lcars_unite(t, from)
  end
end

client.connect_signal("tagged", function (c, t)
  return tag_callback(t, "c:tagged on " .. t.name)
end)
client.connect_signal("untagged", function (c, t)
  return tag_callback(t, "c:untagged")
end)
client.connect_signal("property::minimized", function (c)
  return tag_callback(c:tags()[1], "c:min")
end)

tag.connect_signal("property::layout", function (t)
  return tag_callback(t, "t:layout")
end)
tag.connect_signal("property::selected", function (t)
  if t.selected then 
    return tag_callback(t, "t:selected")
  end
end)
tag.connect_signal("property::mwfact", function (t)
  if awful.tag.getproperty(t, 'layout').name == 'lcars' then
    lcars_separate(t, "t:mwfact")
  end
end)
tag.connect_signal("property::ncol", function (t)
  return tag_callback(t, "t:ncol")
end)
tag.connect_signal("property::nmaster", function (t)
  return tag_callback(t, "t:nmaster")
end)

client.connect_signal("property::maximized", function (c)
      awesome_context.left_panel_visible = not awesome_context.left_panel_visible
      --awesome_context.leftwibox[1]:struts({left=0})
      awesome_context.leftwibox[1].visible = awesome_context.left_panel_visible
      awesome_context.internal_corner_wibox[1].visible = awesome_context.left_panel_visible
      awful.wibox.stretch(awesome_context.topwibox[1], 1)
      c:geometry({width=screen[c.screen].workarea.width})
end)

end
-- }}}
return signals
