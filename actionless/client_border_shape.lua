--=============================================================================
-- Window shape
--
local beautiful = require("beautiful")
local gears = require("gears")
local cairo = require("lgi").cairo
local delayed_call = require("gears.timer").delayed_call

local tag_helpers = require("actionless.util.tag")


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
    local client_tag = tag_helpers.get_client_tag(c)
    if not client_tag then
      nlog('no client tag')
      return
    end
    local num_tiled = #tag_helpers.get_tiled(client_tag)
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

    if not awesome.composite_manager_running then
      apply_shape(c, gears.shape.rounded_rect, outer_shape_args, inner_shape_args)
    else
      -- needed for compoton's shadow:
      c.shape = function(cr, w, h) gears.shape.rounded_rect(
        cr, w, h, beautiful.client_border_radius*0.9
      ) end
    end

    --clog("apply_shape "..(reference or 'no_ref'), c)
    pending_shapes[c] = nil
    --nlog('OK F='..(force and "true" or 'nil').. ', R='..reference..', C='.. c.name)
  end)
end

return {
  round_up_client_corners=round_up_client_corners,
}
