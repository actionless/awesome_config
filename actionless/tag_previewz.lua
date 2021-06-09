-- upstream url:
-- https://github.com/BlingCorp/bling
-- forked from:
-- https://github.com/BlingCorp/bling/blob/487cdb69a5b38b48a8a6045218cbdea313325b8a/widget/tag_preview.lua
--
-- Provides:
-- tag_previewz::update   -- first line is the signal
--      t    (tag)              -- indented lines are function parameters
-- tag_previewz::visibility::toggle
--      s    (screen)
--      args (table)
--

local cairo = require("lgi").cairo

local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local awful = require("awful")
local dpi = beautiful.xresources.apply_dpi

local h_string = require("actionless.util.string")
local get_icon = require("actionless.util.xdg").get_icon


local function rounded_rect(radius)
    return function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, radius)
    end
end


local function draw_widget(tag_preview_box, original_tag, tag_preview_image, scale,
                           screen_radius, client_radius, client_opacity,
                           client_bg, client_border_color, client_border_width,
                           widget_bg, widget_border_color, widget_border_width,
                           geo, margin,
                           tag_bg, icon_size, default_client_icon)

    local client_lists = {}
    local s = original_tag.screen
    for _, t in ipairs(s.tags) do

      local client_list = wibox.layout.manual()
      table.insert(client_lists, client_list)
      client_list.forced_height = geo.height
      client_list.forced_width = geo.width

      for _, c in ipairs(t:clients()) do

        if not c.hidden and not c.minimized then
            local img_box = wibox.widget {
                image = gears.surface.load(c.icon or default_client_icon),
                resize = true,
                forced_height = icon_size,
                forced_width = icon_size,
                widget = wibox.widget.imagebox,
                valign = "center",
            }

            if tag_preview_image then
                if c.prev_content or t.selected then
                local content
                if t.selected then
                    content = gears.surface(c.content)
                else
                    content = gears.surface(c.prev_content)
                end

                  local cr = cairo.Context(content)
                  local x, y, w, h = cr:clip_extents()
                  local img = cairo.ImageSurface.create(cairo.Format.ARGB32,
                                                        w - x, h - y)
                  cr = cairo.Context(img)
                  cr:set_source_surface(content, 0, 0)
                  cr.operator = cairo.Operator.SOURCE
                  cr:paint()

                  img_box = wibox.widget {
                      image = gears.surface.load(img),
                      resize = true,
                      opacity = client_opacity,
                      forced_height = math.floor(c.height * scale),
                      forced_width = math.floor(c.width * scale),
                      widget = wibox.widget.imagebox
                  }
              end
            end

            local client_box = wibox.widget {
                {
                    nil,
                    {
                        nil,
                        {
                            {
                              img_box,
                              wibox.widget.textbox(
                                gears.string.xml_escape(
                                  h_string.max_length(c.name, 80, true)
                                )
                              ),
                              layout = wibox.layout.fixed.horizontal,
                              spacing = margin * 2,
                              fill_space = false,
                            },
                            margins = margin * 3,
                            widget = wibox.container.margin
                        },
                        nil,
                        expand = "outside",
                        layout = wibox.layout.align.horizontal
                    },
                    nil,
                    expand = "outside",
                    widget = wibox.layout.align.vertical
                },
                forced_height = math.floor(c.height * scale),
                forced_width = math.floor(c.width * scale),
                bg = client_bg,
                fg = client_border_color,
                border_color = client_border_color,
                border_width = client_border_width,
                shape = rounded_rect(client_radius),
                widget = wibox.container.background
            }

            client_box.point = {
                x = math.floor((c.x - geo.x) * scale),
                y = math.floor((c.y - geo.y) * scale)
            }
            client_box:buttons(awful.util.table.join({
              awful.button({}, 1, function()
                if not tag_preview_box.visible then return end
                awesome.emit_signal(
                  "tag_previewz::visibility::toggle",
                  s, { visible = false }
                )
                t:view_only()
                client.focus = c
                c:raise()
              end)
            }))

            client_list:add(client_box)
        end
      end
    end

    local all_widths = 0
    local previews_v = wibox.layout.fixed.vertical()
    previews_v.fill_space = false
    previews_v.spacing = margin * 2
    local previews_h = wibox.layout.fixed.horizontal()
    previews_h.fill_space = false
    previews_h.spacing = margin * 2
    previews_v:add(previews_h)
    for tag_idx, client_list in ipairs(client_lists) do
      if geo.width * scale * tag_idx > (geo.width + all_widths) then
        previews_h = wibox.layout.fixed.horizontal()
        previews_h.fill_space = false
        previews_h.spacing = margin * 2
        previews_v:add(previews_h)
        all_widths = all_widths + geo.width
      end
      previews_h:add(wibox.widget{
          {
              {
                  {
                      {
                        {
                            client_list,
                            bg = tag_bg,
                            widget = wibox.container.background
                        },
                        layout = wibox.container.constraint,
                        height = geo.height * scale,
                        width = geo.width * scale,
                        strategy = "exact",
                      },
                      layout = wibox.layout.align.horizontal
                  },
                  layout = wibox.layout.align.vertical
              },
              margins = margin,
              widget = wibox.container.margin
          },
          bg = widget_bg,
          border_width = widget_border_width,
          border_color = widget_border_color,
          shape = rounded_rect(screen_radius),
          widget = wibox.container.background
      })
    end
    tag_preview_box:set_widget(previews_v)
end

local enable = function(opts)
    local tag_preview_image = false
    --local tag_preview_image = true
    --local widget_x = dpi(20)
    --local widget_y = dpi(20)
    local widget_x = dpi(0)
    --local widget_y = beautiful.panel_height or dpi(0)
    local widget_y = dpi(0)
    local margin = beautiful.tag_preview_widget_margin or dpi(1)
    local screen_radius = beautiful.tag_preview_widget_border_radius or (beautiful.client_border_radius or dpi(0))*2.7
    local client_radius = beautiful.tag_preview_client_border_radius or beautiful.client_border_radius or dpi(0)
    local client_opacity = beautiful.tag_preview_client_opacity or 0.5
    local client_bg = beautiful.tag_preview_client_bg or "#60006088"
    local client_border_color = beautiful.tag_preview_client_border_color or
                                    "#ffffff88"
    local client_border_width = beautiful.tag_preview_client_border_width or
                                    dpi(3)
    local widget_bg = beautiful.tag_preview_widget_bg or "#00000013"  -- ???
    local tag_bg = beautiful.tag_preview_tag_bg or "#60600023"
    local widget_border_color = beautiful.tag_preview_widget_border_color or
                                    "#ffffff22"
    local widget_border_width = beautiful.tag_preview_widget_border_width or
                                    dpi(0)

    local scale = 0.1963
    --local scale = 0.2
    local work_area = false
    local padding = false

    local icon_size = 32 or dpi(24)
    local default_client_icon = get_icon('apps', 'terminal')

    if opts then
        tag_preview_image = opts.show_client_content or tag_preview_image
        widget_x = opts.x or widget_x
        widget_y = opts.y or widget_y
        scale = opts.scale or scale
        work_area = opts.honor_workarea or work_area
        padding = opts.honor_padding or padding
    end

    local tag_preview_box = wibox({
        visible = false,
        ontop = true,
        --input_passthrough = true,
        bg = "#00000000"
    })

    if tag_preview_image then
      tag.connect_signal("property::selected", function(t)
          for _, c in ipairs(t:clients()) do
              c.prev_content = gears.surface.duplicate_surface(c.content)
          end
      end)
    end

    awesome.connect_signal("tag_previewz::update", function(t)
        local geo = t.screen:get_bounding_geometry{
            honor_padding = padding,
            honor_workarea = work_area
        }

        tag_preview_box.width = geo.width
        tag_preview_box.height = geo.height

        draw_widget(tag_preview_box, t, tag_preview_image, scale, screen_radius,
                    client_radius, client_opacity, client_bg,
                    client_border_color, client_border_width, widget_bg,
                    widget_border_color, widget_border_width, geo, margin,
                    tag_bg, icon_size, default_client_icon)
    end)

    awesome.connect_signal("tag_previewz::visibility::toggle", function(s, args)
      s = s or awful.screen.focused()
      args = args or {}
      if args.update and s.selected_tag and args.visible ~= false then
        awesome.emit_signal("tag_previewz::update", s.selected_tag)
      end
      local target_state = not tag_preview_box.visible
      if args.visible ~= nil then target_state = args.visible end
      tag_preview_box.x = s.geometry.x + widget_x
      tag_preview_box.y = s.geometry.y + widget_y
      tag_preview_box.visible = target_state
    end)
end

return {enable = enable}
