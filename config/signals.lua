local awful = require("awful")
local beautiful = require("beautiful")
local delayed_call = require("gears.timer").delayed_call
local gears = require("gears")
local cairo = require("lgi").cairo

local titlebar	= require("actionless.titlebar")
local persistent = require("actionless.persistent")


-- enable autofocus
require("awful.autofocus")

-- disable popups when hovering titlebar buttons
awful.titlebar.enable_tooltip = false


local debug_messages_enabled = false
--local debug_messages_enabled = true
local log = function(...) if debug_messages_enabled then nlog(...) end end


local function get_num_tiled(t, s)
  s = s or t.screen
  local num_tiled
  if t == s.selected_tag then
    num_tiled = #awful.client.tiled(s)
  else
    num_tiled = 0
    for _, tc in ipairs(t:clients()) do
      if not tc.floating
        and not tc.fullscreen
        and not tc.maximized_vertical
        and not tc.maximized_horizontal
      then
        num_tiled = num_tiled + 1
      end
    end
  end
  return num_tiled
end


awful.tag.object.get_gap = function(t)
  t = t or awful.screen.focused().selected_tag
  if get_num_tiled(t) == 1 and t.master_fill_policy == "expand" then
    return 0
  end
  return awful.tag.getproperty(t, "useless_gap") or beautiful.useless_gap or 0
end


local function apply_shape(draw, shape, ...)
  local client_tag = draw.first_tag
  if not client_tag then
    nlog('no client tag')
    return
  end

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
  )) then
    --nlog('R1 F='..(force and force or 'nil').. ', R='..reference..', C='.. c.name)
    return
  end
  --log{"Geometry", c:tags()}
  pending_shapes[c] = true
  --delayed_call(apply_shape, c, gears.shape.rounded_rect, beautiful.border_radius)
  delayed_call(function()
    local num_tiled = #awful.client.tiled(c.screen)
    local client_tag = c.first_tag
    log{"Shape", num_tiled, client_tag.master_fill_policy, c.name}
    --if not force and (c.maximized or (
    if (c.maximized or (
      #c:tags() < 1
    ) or (
      (num_tiled<=1 and client_tag.master_fill_policy=='expand')
      and not c.floating
      and client_tag.layout.name ~= "floating"
    )) then
      pending_shapes[c] = nil
      --nlog('R2 F='..(force and force or 'nil').. ', R='..reference..', C='.. c.name)
      return
    end
    apply_shape(c, gears.shape.rounded_rect, beautiful.border_radius)
    pending_shapes[c] = nil
    --nlog('OK F='..(force and "true" or 'nil').. ', R='..reference..', C='.. c.name)
  end)
end

local signals = {}

function signals.init(awesome_context)


  local function set_default_screen_padding(s)
    if not awesome_context.DEVEL_DYNAMIC_LAYOUTS then return end
    s.padding = {
      left = beautiful.screen_padding,
      right = beautiful.screen_padding,
      top = beautiful.screen_padding,
      bottom = beautiful.screen_padding,
    }
  end

  local function set_mwfact_screen_padding(t)
    if not awesome_context.DEVEL_DYNAMIC_LAYOUTS then return end
    local s = t.screen
    local padding = s.geometry.width * (1-t.master_width_factor) / 2
    s.padding = {
      left=padding,
      right=padding,
      top = beautiful.screen_padding,
      bottom = beautiful.screen_padding,
    }
  end

  local function choose_screen_padding(s, t, num_tiled)
    if num_tiled > 1 then
      set_default_screen_padding(s)
    else
      set_mwfact_screen_padding(t)
    end
  end

  local function clog(c, msg)
      log(msg .. " " .. c.name .. " " .. tostring(c:tags()[1]))
  end

  local function _on_client_unfocus (c)
    if c.minimized then return end
    local t = c:tags()[1]
    local s = t.screen
    local layout = t.layout
    local num_tiled = get_num_tiled(t, s)

    if persistent.titlebar.get() and (
      num_tiled > 1 or (
        num_tiled > 0 and t.master_fill_policy ~= 'expand'
      )
    ) then
      log("U: tile: titlebars enabled explicitly")
      titlebar.make_titlebar(c, beautiful._titlebar_bg_normal, beautiful.titlebar_shadow_normal)
      c.border_color = beautiful.border_normal
    elseif c.floating then
      log("U: floating client")
      titlebar.make_titlebar(c, beautiful._titlebar_bg_normal, beautiful.titlebar_shadow_normal)
      c.border_color = beautiful.titlebar_border
    elseif layout == awful.layout.suit.floating then
      clog(c, "U: floating layout")
      titlebar.make_titlebar(c, beautiful._titlebar_bg_normal, beautiful.titlebar_shadow_normal)
      c.border_color = beautiful.titlebar_border
    elseif num_tiled > 1 then
      log("U: multiple tiling clients")
      titlebar.make_border(c, beautiful._titlebar_bg_normal, beautiful.titlebar_shadow_normal)
      c.border_color = beautiful.border_normal
    elseif num_tiled == 1 then
      if t.master_fill_policy == 'expand' and screen.count() == 1 then
        log("U: one tiling client: expand")
        titlebar.remove_border(c)
      else
        log("U: one tiling client")
        titlebar.make_border(c, beautiful._titlebar_bg_normal, beautiful.titlebar_shadow_normal)
        c.border_color = beautiful.border_normal
      end
    else
      nlog('Signals: U: How did that happened?')
      nlog(num_tiled)
    end
  end

  local function on_client_unfocus(c, force, callback)
    --return _on_client_unfocus(c)
    --extremely_delayed_call(function()
    delayed_call(function()
      if not c.valid or c == client.focus then
        return
      end
      if force then 
        _on_client_unfocus(c)
        if callback then
          callback(c)
        end
      end
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
    local t = s.selected_tag
    local layout = awful.layout.get(s)
    local num_tiled = #awful.client.tiled(s)

    --c.border_color = beautiful.border_focus
    --

    if persistent.titlebar.get() and (
      num_tiled > 1 or (
        num_tiled > 0 and t.master_fill_policy ~= 'expand'
      )
    ) then
      log("F: tile: titlebars enabled explicitly")
      --choose_screen_padding(s, t, num_tiled)
      titlebar.make_titlebar(c, beautiful._titlebar_bg_focus, beautiful.titlebar_shadow_focus)
    elseif c.maximized then
      log("F: maximized")
      --set_default_screen_padding(s)
      titlebar.remove_border(c)
    elseif c.floating then
      log("F: floating client")
      --choose_screen_padding(s, t, num_tiled)
      titlebar.make_titlebar(c, beautiful._titlebar_bg_focus, beautiful.titlebar_shadow_focus)
    elseif layout == awful.layout.suit.floating then
      log("F: floating layout")
      --choose_screen_padding(s, t, num_tiled)
      titlebar.make_titlebar(c, beautiful._titlebar_bg_focus, beautiful.titlebar_shadow_focus)
    elseif num_tiled > 1 then
      log("F: multiple tiling clients")
      --set_default_screen_padding(s)
      c.border_width = beautiful.border_width
      titlebar.make_border(c, beautiful._titlebar_bg_focus, beautiful.titlebar_shadow_focus)
    elseif num_tiled == 1 then
      if t.master_fill_policy == 'expand' and screen.count() == 1 then
        log("F: one tiling client: expand")
        --set_default_screen_padding(s)
        titlebar.remove_border(c)
      else
        log("F: one tiling client")
        --set_mwfact_screen_padding(t)
        c.border_width = beautiful.border_width
        titlebar.make_border(c, beautiful._titlebar_bg_focus, beautiful.titlebar_shadow_focus)
      end
    else
      log("F: zero tiling clients -- other tag?")
      return on_client_unfocus(c) --luacheck: ignore
    end

    c.border_color = beautiful.border_focus
  end


  local function on_master_fill_change(t)
    if t.layout == 'floating' then return end
    if t.master_fill_policy == 'always_master_width_factor' or (
      t.master_fill_policy == 'master_width_factor' and #awful.client.tiled(t.screen) == 1
    ) then
      set_mwfact_screen_padding(t)
    else
      set_default_screen_padding(t.screen)
    end
  end

  tag.connect_signal("property::master_width_factor", on_master_fill_change)
  tag.connect_signal("property::master_fill_policy", on_master_fill_change)
  tag.connect_signal("property::layout", function (t)
    --t = t or awful.screen.focused().selected_tag
    for _, c in ipairs(t:clients()) do
      if c == client.focus then
        on_client_focus(c)
      else
        --log("tag::property::layout")
        on_client_unfocus(c)
      end
    end
  end)

  -- New client appears
  client.connect_signal("manage", function (c)
    --if awesome.startup then
      --extremely_delayed_call(function()
      delayed_call(function()
        --local tagged
          if c == client.focus then
            on_client_focus(c)
            round_up_client_corners(c, true, "MF")
            --nlog("|MF| "..c.name)
          else
            on_client_unfocus(c, true, function(_c)
              round_up_client_corners(_c, true, "MU")
              --nlog("|MU| "..c.name)
            end)
          end
      end)
    --end
  end)

  client.connect_signal("focus", function(c)
    return on_client_focus(c)
  end)

  client.connect_signal("unfocus", function(c)
    return on_client_unfocus(c)
  end)

  client.connect_signal("property::maximized", function (c)
    delayed_call(function()
      if c == client.focus then
        on_client_focus(c)
      else
        on_client_unfocus(c)
      end
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
