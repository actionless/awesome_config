local awful = require("awful")
local beautiful = require("beautiful")
local delayed_call = require("gears.timer").delayed_call
local gears = require("gears")
local cairo = require("lgi").cairo

local titlebar	= require("actionless.titlebar")
local persistent = require("actionless.persistent")
local tag_helpers = require("actionless.util.tag")


local function clog(msg, c) -- luacheck: ignore
  --if c and c.class == 'mpv' then
    --nlog({msg, c and c.name})
  --end
  --log(msg .. " " .. c.name .. " " .. tostring(c:tags()[1]))
  --if c and c.class == "Spotify" then nlog(msg) end
end


local function choose_tag(c)
  if c.screen and c.screen.selected_tags then
    for _, sel_tag in ipairs(c.screen.selected_tags) do
      for _, cli_tag in ipairs(c:tags()) do
        if sel_tag.index == cli_tag.index then
          return cli_tag
        end
      end
    end
  end
  return c.first_tag
end

local function get_num_tiled(t)
  -- @TODO: add some fix for sticky clients: DONE?
  local s = t.screen
  if s.selected_tags and #s.selected_tags > 1 then
    return #s.tiled_clients
  end
  return #tag_helpers.get_tiled(t)
end

--=============================================================================
-- Unfocused (normal) window logic

local function _on_client_unfocus (c)
  if not c or not c.valid then return end
  if c.minimized then return end
  c.border_color = beautiful.border_normal
  local t = choose_tag(c)
  local layout = t.layout
  local num_tiled = get_num_tiled(t)
  if persistent.titlebar.get() and (
    num_tiled > 1 or (
      num_tiled > 0 and t.master_fill_policy ~= 'expand'
    )
  ) then
    clog("U: tile: titlebars enabled explicitly", c)
    titlebar.make_titlebar(c, beautiful.actionless_titlebar_bg_normal, beautiful.titlebar_shadow_normal)
  elseif c.maximized or c.fullscreen then
    clog("U: maximized", c)
    --set_default_screen_padding(s)
    titlebar.remove_border(c)
  elseif c.floating then
    clog("U: floating client", c)
    titlebar.make_titlebar(c, beautiful.actionless_titlebar_bg_normal, beautiful.titlebar_shadow_normal)
  elseif layout == awful.layout.suit.floating then
    clog("U: floating layout", c)
    titlebar.make_titlebar(c, beautiful.actionless_titlebar_bg_normal, beautiful.titlebar_shadow_normal)
  elseif num_tiled > 1 then
    clog("U: multiple tiling clients", c)
    titlebar.make_border(c, beautiful.actionless_titlebar_bg_normal, beautiful.titlebar_shadow_normal)
  elseif num_tiled == 1 then
    if t.master_fill_policy == 'expand' and screen.count() == 1 then
      clog("U: one tiling client: expand", c)
      titlebar.remove_border(c)
    else
      clog("U: one tiling client", c)
      titlebar.make_border(c, beautiful.actionless_titlebar_bg_normal, beautiful.titlebar_shadow_normal)
    end
  else
    nlog('Signals: U: How did that happened?')
    nlog(num_tiled)
  end
end

local function on_client_unfocus(c, force, callback)

  local function unfocus_sequence()
    _on_client_unfocus(c)
    if callback then
      callback(c)
    end
  end

  if force then
    unfocus_sequence()
    return
  end
  delayed_call(function()
    if not c.valid or c == client.focus then
      return
    end
    -- Actually draw changes only if client is visible:
    if c.sticky then
      unfocus_sequence()
      return
    end
    for _, sel_tag in ipairs(c.screen.selected_tags) do
      for _, cli_tag in ipairs(c:tags()) do
        if sel_tag.index == cli_tag.index then
          unfocus_sequence()
        end
      end
    end
  end)
end

--=============================================================================
-- Focused (active, selected) window logic

local function on_client_focus(c)
  if not c or not c.valid then return end
  local t = choose_tag(c)
  local layout = t.layout
  local num_tiled = get_num_tiled(t)

  c.border_color = beautiful.border_focus
  --

  if persistent.titlebar.get() and (
    num_tiled > 1 or (
      num_tiled > 0 and t.master_fill_policy ~= 'expand'
    )
  ) then
    clog("F: tile: titlebars enabled explicitly", c)
    --choose_screen_padding(s, t, num_tiled)
    titlebar.make_titlebar(c, beautiful.actionless_titlebar_bg_focus, beautiful.titlebar_shadow_focus)
  elseif c.maximized or c.fullscreen then
    clog("F: maximized", c)
    --set_default_screen_padding(s)
    titlebar.remove_border(c)
  elseif c.floating then
    clog("F: floating client", c)
    --choose_screen_padding(s, t, num_tiled)
    titlebar.make_titlebar(c, beautiful.actionless_titlebar_bg_focus, beautiful.titlebar_shadow_focus)
  elseif layout == awful.layout.suit.floating then
    clog("F: floating layout", c)
    --choose_screen_padding(s, t, num_tiled)
    titlebar.make_titlebar(c, beautiful.actionless_titlebar_bg_focus, beautiful.titlebar_shadow_focus)
  elseif num_tiled > 1 then
    clog("F: multiple tiling clients", c)
    --set_default_screen_padding(s)
    c.border_width = beautiful.border_width
    titlebar.make_border(c, beautiful.actionless_titlebar_bg_focus, beautiful.titlebar_shadow_focus)
  elseif num_tiled == 1 then
    if t.master_fill_policy == 'expand' and screen.count() == 1 then
      clog("F: one tiling client: expand", c)
      --set_default_screen_padding(s)
      titlebar.remove_border(c)
    else
      clog("F: one tiling client", c)
      --set_mwfact_screen_padding(t)
      c.border_width = beautiful.border_width
      titlebar.make_border(c, beautiful.actionless_titlebar_bg_focus, beautiful.titlebar_shadow_focus)
    end
  else
    clog("F: zero tiling clients -- other tag?", c)
    return on_client_unfocus(c)
  end

  --c.border_color = beautiful.border_focus
end

--=============================================================================
-- Window shape

local function apply_shape(draw, shape, outer_shape_args, inner_shape_args)

  local geo = draw:geometry()

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

  shape(cr, geo.width, geo.height, outer_shape_args)
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
    inner_shape_args
  )
  cr:fill()
  draw.shape_clip = img._native

  img:finish()
end


local pending_shapes = {}
local function round_up_client_corners(c, force, reference) -- luacheck: no unused
  if not force and ((
    -- @TODO: figure it out and uncomment
    not beautiful.client_border_radius or beautiful.client_border_radius == 0
  ) or (
    not c.valid
  ) or (
    c.fullscreen
  ) or (
    pending_shapes[c]
  ) or (
    #c:tags() < 1
  )) or beautiful.skip_rounding_for_crazy_borders then
    --clog('R1 F='..(force or 'nil').. ', R='..(reference or '')..', C='.. (c and c.name or '<no name>'), c)
    return
  end
  --clog({"Geometry", c:tags()}, c)
  pending_shapes[c] = true
  delayed_call(function()
    if not c or not c.valid then return end
    local client_tag = choose_tag(c)
    if not client_tag then
      nlog('no client tag')
      return
    end
    local num_tiled = get_num_tiled(client_tag)
    --clog({"Shape", num_tiled, client_tag.master_fill_policy, c.name}, c)
    --if not force and (c.maximized or (
    if (
      c.maximized or c.fullscreen
    or (
      (num_tiled<=1 and client_tag.master_fill_policy=='expand')
      and not c.floating
      and client_tag.layout.name ~= "floating"
    )) then
      pending_shapes[c] = nil
      --nlog('R2 F='..(force and force or 'nil').. ', R='..reference..', C='.. c.name)
      return
    end
    -- Draw outer shape only if floating layout or useless gaps
    local outer_shape_args = 0
    if client_tag.layout.name == "floating" or client_tag:get_gap() ~= 0 then
      outer_shape_args = beautiful.client_border_radius
    end
    local inner_shape_args = beautiful.client_border_radius*0.75
    --local inner_shape_args = beautiful.client_border_radius - beautiful.base_border_width
    --if inner_shape_args < 0 then inner_shape_args = 0 end
    apply_shape(c, gears.shape.rounded_rect, outer_shape_args, inner_shape_args)
    --clog("apply_shape "..(reference or 'no_ref'), c)
    pending_shapes[c] = nil
    --nlog('OK F='..(force and "true" or 'nil').. ', R='..reference..', C='.. c.name)
  end)
end

--=============================================================================
-- Common signal handlers

local function on_client_signal(c, args)
  args = args or {}
  if c == client.focus and not args.unfocus_only then
    on_client_focus(c)
  else
    on_client_unfocus(c)
  end
end

local function on_tag_signal(t, args)
  for _, c in ipairs(t:clients()) do
    on_client_signal(c, args)
  end
end


--=============================================================================
-- INIT

local signals = {}
function signals.init(_)

  -- enable autofocus
  require("awful.autofocus")

  -- disable popups when hovering titlebar buttons
  awful.titlebar.enable_tooltip = false

  -- remove useless gaps for single expanded window
  awful.tag.object.get_gap = function(t)
    t = t or awful.screen.focused().selected_tag
    if not t then return end
    local num_tiled = get_num_tiled(t)
    if num_tiled == 1 and t.master_fill_policy == "expand" then
      return 0
    end
    return awful.tag.getproperty(t, "useless_gap") or beautiful.useless_gap or 0
  end

  -- SIGNALS

  -- Tag changed
  screen.connect_signal("tag::history::update", function (s)
    --if #s.selected_tags > 1 or s.selected_tags[1] and s.selected_tags[1].name == 'Revelation' then
      for _, t in ipairs(s.selected_tags) do
        on_tag_signal(t, {unfocus_only = true})
      end
    --end
  end)

  -- Tag property changed
  tag.connect_signal("property::layout", on_tag_signal)
  tag.connect_signal("property::master_fill_policy", on_tag_signal)
  tag.connect_signal("property::gap", on_tag_signal)

  -- New client appears
  client.connect_signal("manage", function (c)
    local awesome_startup = awesome.startup
    delayed_call(function()
        if c == client.focus then
          on_client_focus(c)
          if awesome_startup then
            round_up_client_corners(c, false, "MF")
          end
        else
          on_client_unfocus(c, true, function(_c)
            if awesome_startup then
              round_up_client_corners(_c, false, "MU")
            end
          end)
        end
    end)
  end)

  -- Other client callbacks:

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

  client.connect_signal("property::fullscreen", function (c)
    delayed_call(function()
      on_client_signal(c)
    end)
  end)

  client.connect_signal("property::size", function (c)
    if not awesome.startup then
      round_up_client_corners(c, false, "S")
    end
  end)

  --client.connect_signal("request::titlebars", function(c)
    --titlebar.make_titlebar(c)
  --end)


end

return signals
