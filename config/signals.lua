local awful = require("awful")
local beautiful = require("beautiful")
local delayed_call = require("gears.timer").delayed_call
local gears = require("gears")
local cairo = require("lgi").cairo
local capi = {
  screen=screen,
  client=client,
}

local titlebar	= require("actionless.titlebar")
local persistent = require("actionless.persistent")


local debug_messages_enabled = false
--local debug_messages_enabled = true
local log = function(...) if debug_messages_enabled then nlog(...) end end


local signals = {}


function signals.init(_)


  local function apply_shape(draw, shape, ...)
    local client_tag = draw.first_tag
    if not client_tag then
      nlog('no client tag')
      return
    end
    local num_tiled = #awful.client.tiled(draw.screen)
    if draw.maximized or (
      (num_tiled==1 and client_tag.master_fill_policy=='expand')
      and not draw.floating
      and client_tag.layout.name ~= "floating"
    ) then
      return
    end

    local geo = draw:geometry()
    local shape_args = ...
    local border = beautiful.base_border_width
    local titlebar_height = border
    --local titlebar_height = titlebar.is_enabled(draw) and beautiful.titlebar_height or border

    local img = cairo.ImageSurface(cairo.Format.A1, geo.width, geo.height)
    local cr = cairo.Context(img)

    cr:set_operator(cairo.Operator.CLEAR)
    cr:set_source_rgba(0,0,0,1)
    cr:paint()
    cr:set_operator(cairo.Operator.SOURCE)
    cr:set_source_rgba(1,1,1,1)

    shape(cr, geo.width, geo.height, shape_args)
    cr:fill()
    draw.shape_bounding = img._native

    cr:set_operator(cairo.Operator.CLEAR)
    cr:set_source_rgba(0,0,0,1)
    cr:paint()
    cr:set_operator(cairo.Operator.SOURCE)
    cr:set_source_rgba(1,1,1,1)

    gears.shape.transform(shape):translate(
      border, titlebar_height
    )(
      cr,
      geo.width-border*2,
      geo.height-titlebar_height-border,
      beautiful.border_radius*0.75
    )
    cr:fill()
    draw.shape_clip = img._native

    img:finish()
  end


  capi.client.connect_signal("property::geometry", function (c)
    if not c.fullscreen and beautiful.border_radius and beautiful.border_radius > 0 then
      delayed_call(apply_shape, c, gears.shape.rounded_rect, beautiful.border_radius)
    end
  end)


  awful.tag.object.get_gap = function(t)
    t = t or awful.screen.focused().selected_tag
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
      titlebar.make_titlebar(c, beautiful._titlebar_bg_focus, beautiful.titlebar_shadow_focus)
    elseif c.maximized then
      log("F: maximized")
      titlebar.remove_border(c)
    elseif c.floating then
      log("F: floating client")
      --titlebar.make_titlebar(c)
      titlebar.make_titlebar(c, beautiful._titlebar_bg_focus, beautiful.titlebar_shadow_focus)
    elseif layout == awful.layout.suit.floating then
      log("F: floating layout")
      --titlebar.make_titlebar(c)
      titlebar.make_titlebar(c, beautiful._titlebar_bg_focus, beautiful.titlebar_shadow_focus)
    elseif num_tiled == 1 then
      if t.master_fill_policy == 'expand' and capi.screen.count() == 1 then
        log("F: one tiling client: expand")
        titlebar.remove_border(c)
      else
        log("F: one tiling client")
        titlebar.make_border(c, beautiful._titlebar_bg_focus, beautiful.titlebar_shadow_focus)
      end
    else
      log("F: more tiling clients")
      c.border_width = beautiful.border_width
      titlebar.make_border(c, beautiful._titlebar_bg_focus, beautiful.titlebar_shadow_focus)
      if not c.fullscreen and beautiful.border_radius and beautiful.border_radius > 0 then
        delayed_call(apply_shape, c, gears.shape.rounded_rect, beautiful.border_radius)
      end
    end
  end

  local function _on_client_unfocus (c)
    local t = awful.screen.focused().selected_tag
    local layout = awful.layout.get(c.screen)
    local num_tiled = #awful.client.tiled(c.screen)

    if persistent.titlebar.get() and (
      num_tiled > 1 or (
        num_tiled > 0 and t.master_fill_policy ~= 'expand'
      )
    ) then
      log("U: tile: titlebars enabled explicitly")
      --titlebar.make_titlebar(c)
      titlebar.make_titlebar(c, beautiful._titlebar_bg_normal, beautiful.titlebar_shadow_normal)
      c.border_color = beautiful.border_normal
    elseif c.floating then
      log("U: floating client")
      c.border_color = beautiful.titlebar_border
      titlebar.make_titlebar(c, beautiful._titlebar_bg_normal, beautiful.titlebar_shadow_normal)
    elseif layout == awful.layout.suit.floating then
      log("U: floating layout")
      c.border_color = beautiful.titlebar_border
      titlebar.make_titlebar(c, beautiful._titlebar_bg_normal, beautiful.titlebar_shadow_normal)
    elseif num_tiled == 1 then
      if t.master_fill_policy == 'expand' and capi.screen.count() == 1 then
        log("U: one tiling client: expand")
        titlebar.remove_border(c)
      else
        log("U: one tiling client")
        c.border_color = beautiful.border_normal
        titlebar.make_border(c, beautiful._titlebar_bg_normal, beautiful.titlebar_shadow_normal)
      end
    else
      log("U: more tiling clients")
      titlebar.make_border(c, beautiful._titlebar_bg_normal, beautiful.titlebar_shadow_normal)
      c.border_color = beautiful.border_normal
    end
  end


  local function on_client_unfocus (c)
    return _on_client_unfocus(c)
    --delayed_call(function()
      --if not c.valid then return end
      --for _, sel_tag in ipairs(c.screen.selected_tags) do
        --for _, cli_tag in ipairs(c:tags()) do
          --if sel_tag.index == cli_tag.index then
            --return _on_client_unfocus(c)
          --end
        --end
      --end
    --end)
  end

  -- New client appears
  client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end
    if awesome.startup and
      not c.size_hints.user_position and
      not c.size_hints.program_position
    then
      -- Prevent clients from being unreachable after screen count change
      awful.placement.no_offscreen(c)
      delayed_call(function()
        --local tagged
        --tagged = function()
          if c == client.focus then
            on_client_focus(c)
          else
            on_client_unfocus(c)
          end
          --c.disconnect_signal("tagged", tagged)
        --end
        --c.connect_signal("tagged", tagged)
        --c.connect_signal("request::activate", tagged)
      end)
    end
  end)



  client.connect_signal("focus", function(c)
    return on_client_focus(c)
  end)

  client.connect_signal("unfocus", function(c)
    return on_client_unfocus(c)
  end)

  tag.connect_signal("property::layout", function (t)
    t = t or awful.screen.focused().selected_tag
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



  --client.connect_signal("property::minimized", function (c)
  --if c.minimized then
  --c.skip_taskbar = false
  --elseif titlebar.is_enabled(c) then
  --c.skip_taskbar = true
  --end
  --end)

  --client.connect_signal("request::titlebars", function(c)
    --titlebar.make_titlebar(c)
  --end)


end

return signals
