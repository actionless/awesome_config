local awful = require("awful")
local client = client
local beautiful = require("beautiful")
local delayed_call = require("gears.timer").delayed_call


local debug_messages_enabled = true
--local debug_messages_enabled = false
local log = function(...) if debug_messages_enabled then nlog(...) end end


local lcars_layout_helper = {
  last_y = nil,
  is_separated = false,
  is_visible = true
}

function lcars_layout_helper.init(awesome_context)


client.connect_signal("property::maximized", function (c)
  local t = c:tags()[1]
  lcars_layout_helper.setlpv(not c.maximized, t)
end)

local function handle_left_panel_visibility(t)
  --log("handle left panel visibility")
  local visible = lcars_layout_helper.getlpv(t)
  if visible == lcars_layout_helper.is_visible then
    return
  else
    lcars_layout_helper.is_visible = visible
  end
  local s = t.screen.index
  --awesome_context.lcars_assets.leftwibox[s]:struts({left=0})
  awesome_context.lcars_assets.leftwibox[s].visible = visible
  awesome_context.lcars_assets.internal_corner_wibox[s].visible = visible
  awesome_context.lcars_assets.external_corner_wibox[s].visible = visible
  awesome_context.topwibox[s].stretch = 1
  if visible then
    awesome_context.topwibox[s]:set_widget(
      awesome_context.lcars_assets.topwibox_layout[s]
    )
  else
    awesome_context.topwibox[s]:set_widget(
      awesome_context.topwibox_layout[s]
    )
  end
  --c:geometry({width=screen[c.screen].workarea.width})
end
function lcars_layout_helper.getlpv(t)
  return awful.tag.getproperty(t, 'left_panel_visible') or false
end
function lcars_layout_helper.setlpv(prop, t)
  awful.tag.setproperty(t, 'left_panel_visible', prop)
end
tag.add_signal("property::left_panel_visible")
tag.connect_signal("property::left_panel_visible", handle_left_panel_visibility)
handle_left_panel_visibility(awful.screen.focused().selected_tag)


local function lcars_unite(t, from)
  if not lcars_layout_helper.is_separated then return end
  log("LCARS: unite|"..from)
  local s = t.screen.index
  local w = awesome_context.topwibox[s]
  awesome_context.lcars_assets.topwibox_layout[s]:reset()
  w:struts({top = beautiful.panel_height})
  w.height = beautiful.panel_height
  awful.wibar.set_position(w, "top", s)
  awesome_context.lcars_assets.top_left_corner_container[s]:set_widget(awesome_context.lcars_assets.top_left_corner_placeholder[s])
  awesome_context.lcars_assets.leftwibox_separator[s]:set_height(0)
  awesome_context.lcars_assets.internal_corner_wibox[s].y = beautiful.basic_panel_height
  awesome_context.lcars_assets.internal_corner_wibox[s]:apply_shape()
  awesome_context.lcars_assets.topwibox_layout[s]:set_first(nil)
  awesome_context.lcars_assets.top_internal_corner_wibox[s].visible = false

  awesome_context.lcars_assets.left_panel_top_layouts[s]:reset()
  awesome_context.lcars_assets.left_panel_bottom_layouts[s]:reset()
  for _, widget in ipairs(awesome_context.lcars_assets.left_panel_widgets[s]) do
      awesome_context.lcars_assets.left_panel_bottom_layouts[s]:add(widget)
  end

  lcars_layout_helper.is_separated = false
end

local function lcars_separate(t, from)
  local s = t.screen.index
  local nmaster = t.master_count
  if nmaster < 1 or #awful.client.tiled(s) <= nmaster then
    return lcars_unite(t, from)
  end
  log("LCARS: separate|"..from)
  local w = awesome_context.topwibox[s]
  if not lcars_layout_helper.is_separated then
    w:struts({top = 0})
  end
  local mwfact =  t.master_width_factor
  local height = screen[s].workarea.height
  local computed_y = math.floor(
    height*(1-mwfact) + beautiful.panel_height
  )
  if lcars_layout_helper.is_separated and lcars_layout_helper.last_y == computed_y
    then return end
  log("LCARS: not cached")
  lcars_layout_helper.setlpv(true, t)
  lcars_layout_helper.last_y = computed_y

  awesome_context.lcars_assets.topwibox_layout[s]:set_first(awesome_context.lcars_assets.topwibox_toplayout[s])
  w:set_widget(awesome_context.lcars_assets.topwibox_layout[s])
  --w:geometry({height = beautiful.panel_height * 8 + beautiful.panel_padding_bottom})
  --w.height = beautiful.panel_height * 8 + beautiful.panel_padding_bottom
  --nlog(w:struts())
  --w:struts({top = 0, bottom=0})
  --nlog(w:struts())
  w.y = computed_y - beautiful.panel_height - beautiful.panel_padding_bottom
  w.x = beautiful.left_panel_width
  --w.visible = false
  --nlog({y = computed_y - beautiful.panel_height * 1 - beautiful.panel_padding_bottom * 1 })

  awesome_context.lcars_assets.top_left_corner_container[s]:set_widget(awesome_context.lcars_assets.top_left_corner_imagebox[s])

  awesome_context.lcars_assets.leftwibox_separator[s]:set_height(computed_y)

  awesome_context.lcars_assets.internal_corner_wibox[s].y = computed_y+beautiful.basic_panel_height
  awesome_context.lcars_assets.internal_corner_wibox[s]:apply_shape()
  awesome_context.lcars_assets.top_internal_corner_wibox[s].visible = true
  awesome_context.lcars_assets.top_internal_corner_wibox[s].y = computed_y-beautiful.panel_height - beautiful.left_panel_internal_corner_radius

    --awesome_context.lcars_assets.topwibox_layout[s]:set_third(
      --awesome_context.topwibox_layout[s]
    --)


  awesome_context.lcars_assets.left_panel_top_layouts[s]:reset()
  awesome_context.lcars_assets.left_panel_bottom_layouts[s]:reset()
  local height_sum = 0
  local last_bottom_widget_id = 1
  for i, widget in ipairs(awesome_context.lcars_assets.left_panel_widgets[s]) do
    if widget._height and widget._height + height_sum < computed_y - (beautiful.left_panel_width/2) then
      awesome_context.lcars_assets.left_panel_top_layouts[s]:add(widget)
      height_sum = height_sum + widget._height
      last_bottom_widget_id = i
    else
      break
    end
  end
  for c = last_bottom_widget_id, #awesome_context.lcars_assets.left_panel_widgets[s] do
    awesome_context.lcars_assets.left_panel_bottom_layouts[s]:add(awesome_context.lcars_assets.left_panel_widgets[s][c])
  end

  lcars_layout_helper.is_separated = true
end



local function tag_callback(t, from)
  if not t then t = awful.screen.focused().selected_tag end
  if not t.selected then return end

  if awful.tag.getproperty(t, 'layout').name == 'lcars' then
    lcars_separate(t, from)
  else
    lcars_unite(t, from)
  end
end

tag.connect_signal("property::selected", function (t)
  handle_left_panel_visibility(t)
  return tag_callback(t, "t:selected")
end)
tag.connect_signal("property::layout", function (t)
  return tag_callback(t, "t:layout")
end)

client.connect_signal("tagged", function (_, t)
  --handle_left_panel_visibility(t)
  return tag_callback(t, "c:tagged on " .. t.name)
end)
client.connect_signal("untagged", function (_, t)
  --handle_left_panel_visibility(t)
  return tag_callback(t, "c:untagged")
end)
client.connect_signal("property::minimized", function (c)
  local t = c:tags()[1]
  return tag_callback(t, "c:min")
end)


local function size_change_callback(t, from)
  if awful.tag.getproperty(t, 'layout').name == 'lcars' then
    return lcars_separate(t, from)
  end
end

tag.connect_signal("property::mwfact", function (t)
  delayed_call(function()
    size_change_callback(t, "t:mwfact")
  end)
end)
tag.connect_signal("property::ncol", function (t)
    size_change_callback(t, "t:ncol")
end)
tag.connect_signal("property::nmaster", function (t)
    size_change_callback(t, "t:nmaster")
end)



end
-- }}}
return lcars_layout_helper
