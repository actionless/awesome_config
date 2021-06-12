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


local function create_box(
    client_geo, client_icon, client_name, geo, img, buttons,
    client_bg, client_fg, client_opacity, client_border_color, client_border_width, client_radius,
    settings
)
    local img_box
    if img then
      img_box = wibox.widget {
          image = gears.surface.load(img),
          resize = true,
          opacity = client_opacity,
          forced_height = math.floor(client_geo.height * settings.scale),
          forced_width = math.floor(client_geo.width * settings.scale),
          widget = wibox.widget.imagebox
      }
    elseif client_icon then
      img_box = wibox.widget {
          image = gears.surface.load(client_icon),
          resize = true,
          forced_height = settings.icon_size,
          forced_width = settings.icon_size,
          widget = wibox.widget.imagebox,
          valign = "center",
      }
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
                          h_string.max_length(client_name, 80, true)
                        )
                      ),
                      layout = wibox.layout.fixed.horizontal,
                      spacing = settings.margin * 2,
                      fill_space = false,
                    },
                    margins = settings.margin * 3,
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
        forced_height = math.floor(client_geo.height * settings.scale),
        forced_width = math.floor(client_geo.width * settings.scale),
        bg = client_bg,
        fg = client_fg,
        border_color = client_border_color,
        border_width = client_border_width,
        shape = rounded_rect(client_radius),
        widget = wibox.container.background
    }

    client_box.point = {
        x = math.floor((client_geo.x - geo.x) * settings.scale),
        y = math.floor((client_geo.y - geo.y) * settings.scale)
    }
    client_box:buttons(buttons)
    return client_box
end


local function create_client_box(tag_preview_box, c, t, s, geo, settings)
    local client_name = c.name
    local client_icon = c.icon or settings.default_client_icon
    local client_geo = {
      height = c.height,
      width = c.width,
      x = c.x,
      y = c.y
    }

    local buttons = awful.util.table.join({
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
    })

    local img
    if settings.tag_preview_image then
        if c.prev_content or t.selected then
        local content
        if t.selected then
            content = gears.surface(c.content)
        else
            content = gears.surface(c.prev_content)
        end

          local cr = cairo.Context(content)
          local x, y, w, h = cr:clip_extents()
          img = cairo.ImageSurface.create(
              cairo.Format.ARGB32, w - x, h - y
          )
          cr = cairo.Context(img)
          cr:set_source_surface(content, 0, 0)
          cr.operator = cairo.Operator.SOURCE
          cr:paint()
      end
    end

    local client_box = create_box(
        client_geo, client_icon, client_name, geo, img, buttons,
        settings.client_bg, settings.client_fg, settings.client_opacity, settings.client_border_color,
        settings.client_border_width, settings.client_radius,
        settings
    )
    return client_box
end


local function create_tag_box(tag_preview_box, t, s, geo, settings)
    local tag_buttons = awful.util.table.join({
      awful.button({}, 1, function()
        if not tag_preview_box.visible then return end
        awesome.emit_signal(
          "tag_previewz::visibility::toggle",
          s, { visible = false }
        )
        t:view_only()
      end)
    })
    local tag_geo = {
      x = 10, y = 10, height = 250, width = 400,
    }
    local this_tag_bg = settings.tag_bg
    local this_tag_fg = settings.tag_fg
    for _, each_selected_tag in ipairs(s.selected_tags) do
      if t == each_selected_tag then
        this_tag_bg = settings.tag_bg_focus
        this_tag_fg = settings.tag_fg_focus
        break
      end
    end
    local tag_box = create_box(
        tag_geo, nil, t.name, geo, nil, tag_buttons,
        this_tag_bg, this_tag_fg, settings.tag_opacity, settings.tag_border_color,
        settings.tag_border_width, settings.tag_radius,
        settings
    )
    return tag_box
end


local function draw_widget(tag_preview_box, s, geo, settings)

    local client_lists = {}
    for _, t in ipairs(s.tags) do
      local client_list = wibox.layout.manual()
      table.insert(client_lists, client_list)
      client_list.forced_height = geo.height
      client_list.forced_width = geo.width
      for _, c in ipairs(t:clients()) do
        if not c.hidden and not c.minimized then
            client_list:add(create_client_box(
              tag_preview_box, c, t, s, geo, settings
            ))
        end
      end
      client_list:add(create_tag_box(
        tag_preview_box, t, s, geo, settings
      ))
    end

    local all_widths = 0
    local previews_v = wibox.layout.fixed.vertical()
    previews_v.fill_space = false
    previews_v.spacing = settings.margin * 2
    local previews_h = wibox.layout.fixed.horizontal()
    previews_h.fill_space = false
    previews_h.spacing = settings.margin * 2
    previews_v:add(previews_h)
    for tag_idx, client_list in ipairs(client_lists) do
      if geo.width * settings.scale * tag_idx > (geo.width + all_widths) then
        previews_h = wibox.layout.fixed.horizontal()
        previews_h.fill_space = false
        previews_h.spacing = settings.margin * 2
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
                            bg = settings.screen_bg,
                            widget = wibox.container.background
                        },
                        layout = wibox.container.constraint,
                        height = geo.height * settings.scale,
                        width = geo.width * settings.scale,
                        strategy = "exact",
                      },
                      layout = wibox.layout.align.horizontal
                  },
                  layout = wibox.layout.align.vertical
              },
              margins = settings.margin,
              widget = wibox.container.margin
          },
          bg = settings.widget_bg,
          border_width = settings.widget_border_width,
          border_color = settings.widget_border_color,
          shape = rounded_rect(settings.screen_radius),
          widget = wibox.container.background
      })
    end
    tag_preview_box:set_widget(previews_v)
end


local function get_settings(opts)
  local settings = {
    tag_preview_image = false,
    --tag_preview_image = true,
    --widget_x = dpi(20),
    --widget_y = dpi(20),
    widget_x = dpi(0),
    --widget_y = beautiful.panel_height or dpi(0),
    widget_y = dpi(0),
    margin = beautiful.tag_preview_widget_margin or dpi(1),
    screen_radius = (
      beautiful.tag_preview_widget_border_radius or
      (beautiful.client_border_radius or dpi(0))*2.7
    ),
    client_radius = beautiful.tag_preview_client_border_radius or beautiful.client_border_radius or dpi(0),
    client_opacity = beautiful.tag_preview_client_opacity or 0.5,  -- ???
    client_bg = beautiful.tag_preview_client_bg or "#60006088",
    client_border_color = beautiful.tag_preview_client_border_color or
                              "#ffffff88",
    client_border_width = beautiful.tag_preview_client_border_width or
                              dpi(3),
    widget_bg = beautiful.tag_preview_widget_bg or "#00000013",  -- ???
    widget_border_color = beautiful.tag_preview_widget_border_color or "#ffffff22",
    widget_border_width = beautiful.tag_preview_widget_border_width or dpi(0),

    scale = 0.1963,
    --scale = 0.2,
    work_area = false,
    padding = false,

    icon_size = 32 or dpi(24),
    default_client_icon = get_icon('apps', 'terminal'),

    screen_bg = beautiful.tag_preview_screen_bg or "#60600023",
    tag_bg = beautiful.tag_preview_tag_bg or "#00606088",
    tag_bg_focus = beautiful.tag_preview_tag_bg_focus or beautiful.taglist_bg_focus or "#00606088",
  }
  settings.client_fg = settings.client_border_color

  settings.tag_opacity = settings.client_opacity
  settings.tag_radius = settings.client_radius
  settings.tag_border_width = settings.client_border_width
  settings.tag_border_color = settings.client_border_color
  settings.tag_fg = settings.tag_border_color

  if opts then
    settings.tag_preview_image = opts.show_client_content or settings.tag_preview_image
    settings.widget_x = opts.x or settings.widget_x
    settings.widget_y = opts.y or settings.widget_y
    settings.scale = opts.scale or settings.scale
    settings.work_area = opts.honor_workarea or settings.work_area
    settings.padding = opts.honor_padding or settings.padding
  end

  return settings
end


local enable = function(opts)

    local tag_preview_box = wibox({
        visible = false,
        ontop = true,
        --input_passthrough = true,
        bg = "#00000000"
    })

    local settings = get_settings(opts)

    if settings.tag_preview_image then
      tag.connect_signal("property::selected", function(t)
          for _, c in ipairs(t:clients()) do
              c.prev_content = gears.surface.duplicate_surface(c.content)
          end
      end)
    end

    awesome.connect_signal("tag_previewz::update", function(t)
        local geo = t.screen:get_bounding_geometry{
            honor_padding = settings.padding,
            honor_workarea = settings.work_area
        }

        tag_preview_box.width = geo.width
        tag_preview_box.height = geo.height

        draw_widget(
          tag_preview_box, t.screen, geo, settings
        )
    end)

    awesome.connect_signal("tag_previewz::visibility::toggle", function(s, args)
      s = s or awful.screen.focused()
      args = args or {}
      if args.update and s.selected_tag and args.visible ~= false then
        awesome.emit_signal("tag_previewz::update", s.selected_tag)
      end
      local target_state = not tag_preview_box.visible
      if args.visible ~= nil then target_state = args.visible end
      tag_preview_box.x = s.geometry.x + settings.widget_x
      tag_preview_box.y = s.geometry.y + settings.widget_y
      tag_preview_box.visible = target_state
    end)
end

return {enable = enable}
