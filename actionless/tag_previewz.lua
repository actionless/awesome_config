-- upstream url:
-- https://github.com/BlingCorp/bling
-- forked from:
-- https://github.com/BlingCorp/bling/blob/487cdb69a5b38b48a8a6045218cbdea313325b8a/widget/tag_preview.lua

local cairo = require("lgi").cairo

local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local awful = require("awful")
local dpi = beautiful.xresources.apply_dpi


local function ellipsize(unicode_string, max_length)
  if not unicode_string then return nil end
  local result = ''
  local counter = 1
  for uchar in string.gmatch(unicode_string, '([%z\1-\127\194-\244][\128-\191]*)') do
      counter = counter + 1
      if counter > max_length then
        result = result .. '…'
        break
      else
        result = result .. uchar
      end
  end
  return result
end


local function rounded_rect(radius)
    return function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, radius)
    end
end


local function create_box(
    client_geo, client_icon, client_name, screen_geo, img, buttons,
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
                          ellipsize(client_name, 80)
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
        x = math.floor((client_geo.x - screen_geo.x) * settings.scale),
        y = math.floor((client_geo.y - screen_geo.y) * settings.scale)
    }
    client_box:buttons(buttons)
    return client_box
end


local function get_settings(opts)
  local settings = {
    tag_preview_image = false,
    --tag_preview_image = true,
    --work_area = false,
    work_area = true,
    padding = false,

    scale = 0.1963,
    --scale = 0.2,
    icon_size = 32 or dpi(24),
    default_client_icon = beautiful.tag_preview_default_client_icon or beautiful.awesome_icon,

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
    widget_bg = beautiful.tag_preview_widget_bg or "#00000013",  -- ???
    widget_border_color = beautiful.tag_preview_widget_border_color or "#ffffff22",
    widget_border_width = beautiful.tag_preview_widget_border_width or dpi(0),

    screen_bg = beautiful.tag_preview_screen_bg or beautiful.bg_normal or "#60600023",

    client_radius = beautiful.tag_preview_client_border_radius or
      beautiful.client_border_radius or 0,
    client_border_width = beautiful.tag_preview_client_border_width or
      dpi(2),
    client_opacity = beautiful.tag_preview_client_opacity or 0.5,
    client_bg = beautiful.tag_preview_client_bg or
      beautiful.titlebar_bg_normal or "#60006088",
    client_fg = beautiful.tag_preview_client_fg or
      beautiful.titlebar_fg_normal or "#ffffff88",
    client_border_color = beautiful.tag_preview_client_border_color or
      beautiful.border_normal or "#ffffff88",
    client_bg_focus = beautiful.tag_preview_client_bg_focus or
      beautiful.titlebar_bg_focus or "#60006088",
    client_fg_focus = beautiful.tag_preview_client_fg_focus or
      beautiful.titlebar_fg_focus or "#ffffff88",
    client_border_color_focus = beautiful.tag_preview_client_border_color_focus or
      beautiful.border_focus or "#ffffff88",

    tag_opacity = beautiful.tag_preview_tag_opacity or 0.8,
    tag_bg = beautiful.tag_preview_tag_bg or
      beautiful.taglist_bg_occupied or "#00606088",
    tag_bg_focus = beautiful.tag_preview_tag_bg_focus or
      beautiful.taglist_bg_focus or "#00606088",
    tag_fg = beautiful.tag_preview_tag_fg or
      beautiful.taglist_fg_occupied or "#00606088",
    tag_fg_focus = beautiful.tag_preview_tag_fg_focus or
      beautiful.taglist_fg_focus or "#00606088",

  }

  settings.tag_radius = settings.client_radius
  settings.tag_border_width = settings.client_border_width
  settings.tag_border_color = beautiful.panel_widget_border_color or settings.client_border_color

  if opts then
    for key, value in pairs(opts) do
      if opts[key] then
        settings[key] = value
      end
    end
  end

  return settings
end


local function create_class(from_table)
  local result = {
    mt = {},
    prototype = from_table,
  }
  result.mt.__index = function (_, key)
    return result.prototype[key]
  end
  result.new = function(...)
    local instance = {}
    setmetatable(instance, result.mt)
    instance:init(...)
    return instance
  end
  return result
end


local tag_previewz = create_class{

  init = function(self, opts)
    self.tag_preview_box = wibox({
        visible = false,
        ontop = true,
        --input_passthrough = true,
        bg = "#00000000"
    })
    self.settings = get_settings(opts)
  end,


  update = function(self, s)
      local widget_honor_padding = false
      local widget_honor_work_area = false

      local screen_geo = s:get_bounding_geometry{
          honor_padding = self.settings.padding,
          honor_workarea = self.settings.work_area
      }
      local full_screen_geo = (
        self.settings.padding == widget_honor_padding and
        self.settings.work_area == widget_honor_work_area
      ) and screen_geo or s:get_bounding_geometry{
          honor_padding = widget_honor_padding,
          honor_workarea = widget_honor_work_area
      }

      self.tag_preview_box.x = full_screen_geo.x + self.settings.widget_x
      self.tag_preview_box.y = full_screen_geo.y + self.settings.widget_y
      self.tag_preview_box.width = self.settings.widget_width or full_screen_geo.width
      self.tag_preview_box.height = self.settings.widget_height or full_screen_geo.height

      self:draw_widget(
        s, screen_geo, self.settings
      )
  end,


  toggle = function(self, s, args)
    s = s or awful.screen.focused()
    args = args or {}
    if args.update and args.visible ~= false then
      self:update(s)
    end
    local target_state = not self.tag_preview_box.visible
    if args.visible ~= nil then target_state = args.visible end
    self.tag_preview_box.visible = target_state
  end,


  draw_widget = function(self, s, screen_geo, settings)
    local tag_preview_box = self.tag_preview_box
    local client_lists = {}
    for _, t in ipairs(s.tags) do
      local client_list = wibox.layout.manual()
      table.insert(client_lists, client_list)
      client_list.forced_height = screen_geo.height
      client_list.forced_width = screen_geo.width
      for _, c in ipairs(t:clients()) do
        if not c.hidden and not c.minimized then
          client_list:add(
            self:create_client_box(c, t, s, screen_geo, settings)
          )
        end
      end
      client_list:add(
        self:create_tag_box(t, s, screen_geo, settings)
      )
    end

    local used_width = 0
    local previews_v = wibox.layout.fixed.vertical()
    previews_v.fill_space = false
    previews_v.spacing = settings.margin * 2
    local previews_h = wibox.layout.fixed.horizontal()
    previews_h.fill_space = false
    previews_h.spacing = settings.margin * 2
    previews_v:add(previews_h)
    for _, client_list in ipairs(client_lists) do
      if screen_geo.width < (settings.scale * screen_geo.width + used_width) then
        previews_h = wibox.layout.fixed.horizontal()
        previews_h.fill_space = false
        previews_h.spacing = settings.margin * 2
        previews_v:add(previews_h)
        used_width = 0
      end
      used_width = used_width + screen_geo.width * settings.scale
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
                        height = screen_geo.height * settings.scale,
                        width = screen_geo.width * settings.scale,
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
  end,


  create_tag_box = function(self, t, s, screen_geo, settings)
    local tag_buttons = awful.util.table.join({
      awful.button({}, 1, function()
        if not self.tag_preview_box.visible then return end
        self:toggle(s, { visible = false })
        t:view_only()
      end)
    })
    local tag_geo = {
      x = 0 + screen_geo.x, y = 0 + screen_geo.y, height = 250, width = 400,
      --x = 0 + screen_geo.x, y = 0 + screen_geo.y, height = 200, width = 350,
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
        tag_geo, nil, t.name, screen_geo, nil, tag_buttons,
        this_tag_bg, this_tag_fg, settings.tag_opacity, settings.tag_border_color,
        settings.tag_border_width, settings.tag_radius,
        settings
    )
    return tag_box
  end,


  create_client_box = function(self, c, t, s, screen_geo, settings)
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
        if not self.tag_preview_box.visible then return end
        self:toggle(s, { visible = false })
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

    local client_radius = settings.client_radius
    local client_border_width = settings.client_border_width
    local client_border_color = settings.client_border_color
    local client_bg = settings.client_bg
    local client_fg = settings.client_fg
    local geo = client_geo
    if c.fullscreen then
      client_border_width = 0
      client_radius = 0
      geo = screen_geo
    end
    if c == client.focus then
      client_bg = settings.client_bg_focus
      client_fg = settings.client_fg_focus
      client_border_color = settings.client_border_color_focus
    end

    local client_box = create_box(
        geo, client_icon, client_name, screen_geo, img, buttons,
        client_bg, client_fg, settings.client_opacity, client_border_color,
        client_border_width, client_radius,
        settings
    )
    return client_box
  end,

}


local module = {
  saving_client_content_enabled = false,
}

function module.new(opts)
  local instance = tag_previewz.new(opts)
  if instance.settings.tag_preview_image then
    module.enable_saving_client_content()
  end
  return instance
end

function module.enable_saving_client_content()
  if not module.saving_client_content_enabled then
    module.saving_client_content_enabled = true
    tag.connect_signal("property::selected", function(t)
      for _, c in ipairs(t:clients()) do
        c.prev_content = gears.surface.duplicate_surface(c.content)
      end
    end)
  end
end

function module.enable_signals(opts)
  local instance = module.new(opts)
  if instance.settings.tag_preview_image then
    module.enable_saving_client_content()
  end
  awesome.connect_signal("tag_previewz::update", function(s)
    instance:update(s)
  end)
  awesome.connect_signal("tag_previewz::visibility::toggle", function(s, args)
    instance:toggle(s, args)
  end)
end

return module
