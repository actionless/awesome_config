local awful = require("awful")
local beautiful = require("beautiful")
local delayed_call = require("gears.timer").delayed_call
local gears = require("gears")
local cairo = require("lgi").cairo

local titlebar	= require("actionless.titlebar")
local persistent = require("actionless.persistent")
local tag_helpers = require("actionless.util.tag")


-- enable autofocus
require("awful.autofocus")

-- disable popups when hovering titlebar buttons
awful.titlebar.enable_tooltip = false


local debug_messages_enabled = false
--local debug_messages_enabled = true

local function clog(msg, c)
  --if debug_messages_enabled then nlog(...) end
    --log(msg .. " " .. c.name .. " " .. tostring(c:tags()[1]))
  if c and c.class == "Spotify" then nlog(msg) end
end



awful.tag.object.get_gap = function(t)
  t = t or awful.screen.focused().selected_tag
  if #tag_helpers.get_tiled(t) == 1 and t.master_fill_policy == "expand" then
    return 0
  end
  return awful.tag.getproperty(t, "useless_gap") or beautiful.useless_gap or 0
end


local function apply_shape(draw, shape, ...)
  local client_tag = draw.first_tag  -- @TODO: fix when multiple tags are selected

  local geo = draw:geometry()

  --local shape_args = ...
  --local shape_args = (client_tag.layout.name == "floating" or client_tag:get_gap() ~= 0) and ... or 0
  local shape_args = 0
  --nlog({draw.name, client_tag.name, client_tag:get_gap()})
  --@TODO: :get_gap() not correct on startup!!!
  if client_tag.layout.name == "floating" or client_tag:get_gap() ~= 0 then
    shape_args = ...
  end

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


local pending_shapes = {}
local function round_up_client_corners(c, force, reference)
  if not force and ((
    -- @TODO: figure it out and uncomment
    not beautiful.border_radius or beautiful.border_radius == 0
  ) or (
    not c.valid
  ) or (
    c.fullscreen
  ) or (
    pending_shapes[c]
  ) or (
    #c:tags() < 1
  )) or beautiful.skip_rounding_for_crazy_borders then
    --nlog('R1 F='..(force and force or 'nil').. ', R='..reference..', C='.. c.name)
    return
  end
  --clog({"Geometry", c:tags()}, c)
  pending_shapes[c] = true
  --delayed_call(apply_shape, c, gears.shape.rounded_rect, beautiful.border_radius)
  delayed_call(function()
    local client_tag = c.first_tag  -- @TODO: fix when multiple tags are selected
    if not client_tag then
      nlog('no client tag')
      return
    end
    local num_tiled = #tag_helpers.get_tiled(client_tag)
    --clog({"Shape", num_tiled, client_tag.master_fill_policy, c.name}, c)
    --if not force and (c.maximized or (
    if (
      c.maximized
    or (
      (num_tiled<=1 and client_tag.master_fill_policy=='expand')
      and not c.floating
      and client_tag.layout.name ~= "floating"
    )) then
      pending_shapes[c] = nil
      --nlog('R2 F='..(force and force or 'nil').. ', R='..reference..', C='.. c.name)
      return
    end
    apply_shape(c, gears.shape.rounded_rect, beautiful.border_radius)
    clog("apply_shape "..reference, c)
    pending_shapes[c] = nil
    --nlog('OK F='..(force and "true" or 'nil').. ', R='..reference..', C='.. c.name)
  end)
end

local signals = {}

function signals.init(awesome_context)

  local function _on_client_unfocus (c)
    if c.minimized then return end
    local t = c.first_tag  -- @TODO: fix when multiple tags are selected
    local layout = t.layout
    local num_tiled = #tag_helpers.get_tiled(t)

    if persistent.titlebar.get() and (
      num_tiled > 1 or (
        num_tiled > 0 and t.master_fill_policy ~= 'expand'
      )
    ) then
      clog("U: tile: titlebars enabled explicitly", c)
      titlebar.make_titlebar(c, beautiful.actionless_titlebar_bg_normal, beautiful.titlebar_shadow_normal)
      c.border_color = beautiful.border_normal
    elseif c.floating then
      clog("U: floating client", c)
      titlebar.make_titlebar(c, beautiful.actionless_titlebar_bg_normal, beautiful.titlebar_shadow_normal)
      c.border_color = beautiful.titlebar_border
    elseif layout == awful.layout.suit.floating then
      clog(c, "U: floating layout", c)
      titlebar.make_titlebar(c, beautiful.actionless_titlebar_bg_normal, beautiful.titlebar_shadow_normal)
      c.border_color = beautiful.titlebar_border
    elseif num_tiled > 1 then
      clog("U: multiple tiling clients", c)
      titlebar.make_border(c, beautiful.actionless_titlebar_bg_normal, beautiful.titlebar_shadow_normal)
      c.border_color = beautiful.border_normal
    elseif num_tiled == 1 then
      if t.master_fill_policy == 'expand' and screen.count() == 1 then
        clog("U: one tiling client: expand", c)
        titlebar.remove_border(c)
      else
        clog("U: one tiling client", c)
        titlebar.make_border(c, beautiful.actionless_titlebar_bg_normal, beautiful.titlebar_shadow_normal)
        c.border_color = beautiful.border_normal
      end
    else
      nlog('Signals: U: How did that happened?')
      nlog(num_tiled)
    end
  end

  local function on_client_unfocus(c, callback)
    --return _on_client_unfocus(c)
    delayed_call(function()
      if not c.valid or c == client.focus then
        return
      end
      -- Actually draw changes only if client is visible:
      for _, sel_tag in ipairs(c.screen.selected_tags) do
        for _, cli_tag in ipairs(c:tags()) do
          if sel_tag.index == cli_tag.index then
            _on_client_unfocus(c)
            if callback then
              callback(c)
            end
          end
        end
      end
    end)
  end


  local function on_client_focus(c)
    local s = c.screen
    local t = c.first_tag  -- @TODO: fix when multiple tags are selected
    local layout = awful.layout.get(s)
    local num_tiled = #tag_helpers.get_tiled(t)

    --c.border_color = beautiful.border_focus
    --

    if persistent.titlebar.get() and (
      num_tiled > 1 or (
        num_tiled > 0 and t.master_fill_policy ~= 'expand'
      )
    ) then
      clog("F: tile: titlebars enabled explicitly")
      --choose_screen_padding(s, t, num_tiled)
      titlebar.make_titlebar(c, beautiful.actionless_titlebar_bg_focus, beautiful.titlebar_shadow_focus)
    elseif c.maximized then
      clog("F: maximized")
      --set_default_screen_padding(s)
      titlebar.remove_border(c)
    elseif c.floating then
      clog("F: floating client")
      --choose_screen_padding(s, t, num_tiled)
      titlebar.make_titlebar(c, beautiful.actionless_titlebar_bg_focus, beautiful.titlebar_shadow_focus)
    elseif layout == awful.layout.suit.floating then
      clog("F: floating layout")
      --choose_screen_padding(s, t, num_tiled)
      titlebar.make_titlebar(c, beautiful.actionless_titlebar_bg_focus, beautiful.titlebar_shadow_focus)
    elseif num_tiled > 1 then
      clog("F: multiple tiling clients")
      --set_default_screen_padding(s)
      c.border_width = beautiful.border_width
      titlebar.make_border(c, beautiful.actionless_titlebar_bg_focus, beautiful.titlebar_shadow_focus)
    elseif num_tiled == 1 then
      if t.master_fill_policy == 'expand' and screen.count() == 1 then
        clog("F: one tiling client: expand")
        --set_default_screen_padding(s)
        titlebar.remove_border(c)
      else
        clog("F: one tiling client")
        --set_mwfact_screen_padding(t)
        c.border_width = beautiful.border_width
        titlebar.make_border(c, beautiful.actionless_titlebar_bg_focus, beautiful.titlebar_shadow_focus)
      end
    else
      clog("F: zero tiling clients -- other tag?")
      return on_client_unfocus(c)
    end

    c.border_color = beautiful.border_focus
  end


  local function on_client_signal(c, callback)
    if c == client.focus then
      on_client_focus(c)
      if callback then
        callback(c)
      end
    else
      on_client_unfocus(c, callback)
    end
  end

  local function on_tag_signal(t)
    --t = t or awful.screen.focused().selected_tag
    for _, c in ipairs(t:clients()) do
      on_client_signal(c)
    end
  end

  tag.connect_signal("property::layout", on_tag_signal)
  screen.connect_signal("tag::history::update", function (s)
    if #s.selected_tags > 1 then
      for _, t in ipairs(s.selected_tags) do
        on_tag_signal(t)
      end
    end
  end)

  -- New client appears
  client.connect_signal("manage", function (c)
    local callback
    if awesome.startup then
      callback = round_up_client_corners
    end
    delayed_call(function()
      on_client_signal(c, callback)
    end)
  end)

  client.connect_signal("focus", function(c)
    return on_client_focus(c)
  end)

  client.connect_signal("unfocus", function(c)
    return on_client_unfocus(c)
  end)

  client.connect_signal("property::maximized", function (c)
    delayed_call(function()
      on_client_signal(c)
    end)
  end)

  --client.connect_signal("property::geometry", function (c)
  client.connect_signal("property::size", function (c)
    if not awesome.startup then
      round_up_client_corners(c, false, "S")
    end
    --nlog("|S| "..c.name)
  end)

  --client.connect_signal("request::titlebars", function(c)
    --titlebar.make_titlebar(c)
  --end)


end

return signals
