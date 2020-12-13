--[[
Licensed under GNU General Public License v2
* (c) 2020, Yauheni Kirylau
--]]

local wibox = require('wibox')
local awful = require('awful')
local gears = require('gears')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local ruled = require("ruled")
local naughty = require("naughty")

local pack = table.pack or function(...) -- luacheck: ignore 143
  return { n = select("#", ...), ... }
end

local common = require("actionless.widgets.common")
local db = require("actionless.util.db")



local DB_ID = 'notifications_storage'
local DB_ID_READ_COUNT = 'notifications_storage_read_count'


local naughty_sidebar
naughty_sidebar = {
  theme = {
    num_buttons = 2,
  },

  init_naughty = function(args)
    args = args or {}
    args.skip_rule = args.skip_rule or {app_name = {'', "xfce4-power-manager"}}

    ruled.notification.connect_signal('request::rules', function()
      ruled.notification.append_rules{
        {
          -- All notifications will match this rule.
          rule       = {},
          properties = {
            screen           = awful.screen.preferred,
            implicit_timeout = 5,
          },
        },{
          rule       = { },
          except_any = args.skip_rule,
          callback = function(notification)
            naughty_sidebar:add_notification(notification)
          end
        }
      }
    end)

    naughty.persistence_enabled = true
    naughty.connect_signal('request::preset', function(n, _, notification_args)
      n.args = notification_args
    end)
    naughty.connect_signal('request::display', function(n, _, notification_args)
      if (
        n.app_name ~= '' and
        naughty_sidebar.sidebar and
        naughty_sidebar.sidebar.visible
      ) then
        return
      end
      n:set_title('<b>'..n:get_title()..'</b>')
      local box = naughty.layout.box{
        notification = n,
        -- workaround for https://github.com/awesomeWM/awesome/issues/3081 :
        shape = function(cr,w,h)
          gears.shape.rounded_rect(
            cr, w, h, beautiful.notification_border_radius+beautiful.notification_border_width+1
          )
        end,
      }
      if notification_args.run then
        local buttons = box:buttons()
        buttons = awful.util.table.join(buttons,
          awful.button({}, 1,
          function()
            notification_args.run(n)
          end)
        )
        box:buttons(buttons)
      end
    end)
  end
}

local function init_theme(widget_args)

  local set_theme = function(key, ...)
    if widget_args[key] ~= nil then
      naughty_sidebar.theme[key] = widget_args[key]
      return
    end
    if naughty_sidebar.theme[key] ~= nil then
      return
    end
    local candidates = pack(...)
    for i=1,candidates.n do
      local candidate = candidates[i]
      if candidate ~= nil then
        naughty_sidebar.theme[key] = candidate
        return
      end
    end
  end

  set_theme('fg',
    beautiful.notification_counter_fg
  )
  set_theme('bg',
    beautiful.notification_counter_bg
  )

  set_theme('width',
    beautiful.notification_sidebar_width,
    beautiful.notification_max_width,
    dpi(300)
  )
  set_theme('font',
    beautiful.notification_font,
    "Sans 8"
  )
  set_theme('sidebar_bg',
    beautiful.notification_sidebar_bg,
    beautiful.panel_bg,
    beautiful.bg_normal
  )
  set_theme('sidebar_fg',
    beautiful.notification_sidebar_fg,
    beautiful.panel_fg,
    beautiful.fg_normal
  )
  set_theme('spacing',
    beautiful.notification_sidebar_spacing,
    dpi(10)
  )

  set_theme('notification_bg',
    beautiful.notification_bg,
    beautiful.bg_normal
  )
  set_theme('notification_fg',
    beautiful.notification_fg,
    beautiful.fg_normal
  )
  set_theme('notification_padding',
    beautiful.notification_sidebar_padding,
    dpi(7)
  )
  set_theme('notification_border_radius',
    beautiful.notification_sidebar_notification_border_radius,
    beautiful.notification_border_radius,
    0
  )
  set_theme('notification_border_width',
    beautiful.notification_border_width,
    0
  )
  set_theme('notification_border_color',
    beautiful.notification_border_color,
    beautiful.border_normal
  )
  set_theme('notification_border_color_unread',
    beautiful.warning,
    beautiful.bg_focus
  )

  set_theme('close_button_size',
    beautiful.notification_close_button_size,
    dpi(20)
  )
  set_theme('close_button_margin',
    beautiful.notification_close_button_margin,
    dpi(1)
  )
  set_theme('close_button_opacity',
    beautiful.notification_close_button_opacity,
    0.4
  )
  set_theme('close_button_border_width',
    beautiful.notification_close_button_border_width,
    beautiful.panel_widget_border_width,
    0
  )
  set_theme('close_button_border_color',
    beautiful.notification_close_button_border_color,
    beautiful.panel_widget_border_color,
    beautiful.border_normal
  )

  set_theme('button_padding',
    beautiful.notification_button_padding,
    dpi(5)
  )
  set_theme('button_bg_hover',
    beautiful.bg_focus
  )
  set_theme('button_fg_hover',
    beautiful.fg_focus
  )

  set_theme('custom_widget_height',
    (beautiful.basic_panel_height or dpi(18)) + naughty_sidebar.theme.button_padding
  )
  set_theme('custom_widget_bg',
    beautiful.panel_widget_bg,
    beautiful.bg_normal
  )
end

local function widget_factory(args)
  args	 = args or {}
  args.orientation = args.orientation or "horizontal"
  if (beautiful.panel_widget_spacing ~= nil) and (beautiful.panel_padding_bottom ~= nil) then
    args.padding = {
      left=gears.math.round(beautiful.panel_widget_spacing/2),
      right=math.max(0, gears.math.round(beautiful.panel_widget_spacing/2 + beautiful.panel_padding_bottom - 1)),
    }
    args.margin = {
      left = math.max(0, beautiful.panel_widget_spacing - beautiful.panel_padding_bottom),
      right = beautiful.panel_padding_bottom,
    }
  end
  args.panel_widget_shape = true
  naughty_sidebar.widget = common.decorated(args)

  init_theme(args)

  args.hide_without_notifications = (args.hide_without_notifications == nil) and true or args.hide_without_notifications

  naughty_sidebar.saved_notifications = db.get_or_set(DB_ID, {})
  naughty_sidebar.prev_count = db.get_or_set(DB_ID_READ_COUNT, 0)
  naughty_sidebar.scroll_offset = 0
  naughty_sidebar._custom_widgets = args.custom_widgets or {}


  function naughty_sidebar:widget_action_button(text, callback, widget_args)
    widget_args = widget_args or {}

    local label = {
      markup = text,
      font = naughty_sidebar.theme.font,
      widget = wibox.widget.textbox,
    }
    if widget_args.align == 'middle' then
      label = {
        nil,
        label,
        nil,
        expand='outside',
        layout = wibox.layout.align.horizontal,
      }
    end
    local widget = common.set_panel_widget_shape(wibox.widget{
      {
        --{
          label,
          --layout = wibox.layout.fixed.vertical,
        --},
        margins = naughty_sidebar.theme.button_padding,
        layout = wibox.container.margin,
      },
      bg = naughty_sidebar.theme.notification_bg,
      fg = naughty_sidebar.theme.notification_fg,
      layout = wibox.container.background,
    })
    widget:buttons(awful.util.table.join(
      awful.button({ }, 1, callback)
    ))
    widget:connect_signal("mouse::enter", function()
      widget.bg = naughty_sidebar.theme.button_bg_hover
      widget.fg = naughty_sidebar.theme.button_fg_hover
    end)
    widget:connect_signal("mouse::leave", function()
      widget.bg = naughty_sidebar.theme.notification_bg
      widget.fg = naughty_sidebar.theme.notification_fg
    end)
    return widget
  end

  function naughty_sidebar:write_notifications_to_db()
    local mini_notifications = {}
    for _, notification in ipairs(self.saved_notifications) do
      local mini_notification = {}
      for _, key in ipairs{'title', 'message', 'icon'} do
        mini_notification[key] = notification[key]
      end
      table.insert(mini_notifications, mini_notification)
    end
    db.set(DB_ID, mini_notifications)
  end

  function naughty_sidebar:update_counter()
    local num_notifications = #naughty_sidebar.saved_notifications
    self.widget:set_text((num_notifications==0) and '' or num_notifications)
    if num_notifications > 0 then
      local unread_count = #self.saved_notifications - self.prev_count
      if unread_count > 0 then
        self.widget:set_warning()
      else
        self.widget:set_normal()
      end
      self.widget:show()
    else
      if args.hide_without_notifications then
        self.widget:hide()
      --else
      --  @TODO: set icon for no notifications
      end
    end
  end

  function naughty_sidebar:remove_notification(idx)
    table.remove(self.saved_notifications, idx)
    self:write_notifications_to_db()
    self:update_counter()
    if #self.saved_notifications > 0 then
      self:refresh_notifications()
    else
      self:toggle_sidebox()
    end
  end

  function naughty_sidebar:remove_all_notifications()
    self.saved_notifications = {}
    self:write_notifications_to_db()
    self:toggle_sidebox()
    self:update_counter()
  end

  function naughty_sidebar:widget_notification(notification, idx, unread)
    notification.args = notification.args or {}
    local actions = wibox.layout.fixed.vertical()
    actions.spacing = gears.math.round(naughty_sidebar.theme.notification_padding * 0.75)

    local close_button = wibox.widget{
      {
        {
          nil,
          wibox.widget.textbox('x'),
          nil,
          expand='outside',
          layout = wibox.layout.align.horizontal,
        },
        height = naughty_sidebar.theme.close_button_size,
        width = naughty_sidebar.theme.close_button_size,
        strategy = 'exact',
        layout = wibox.container.constraint,
      },
      layout = wibox.container.background,
      shape_clip = true,
      shape = function(c, w, h)
        return gears.shape.partially_rounded_rect(c, w, h,
          false, false, false, true, beautiful.panel_widget_border_radius
        )
      end,
      shape_border_width = naughty_sidebar.theme.close_button_border_width,
      shape_border_color = naughty_sidebar.theme.close_button_border_color,
      opacity = naughty_sidebar.theme.close_button_opacity,
    }

    local widget = wibox.widget{
      {
        {
          -- TITLE:
          {

            {
              nil,
              {
                wibox.widget.textbox(notification.title),
                margins = {
                  top = naughty_sidebar.theme.notification_padding,
                  bottom = gears.math.round(naughty_sidebar.theme.notification_padding / 2.5),
                  right = (
                    naughty_sidebar.theme.close_button_size +
                    naughty_sidebar.theme.close_button_margin * 2
                  ),
                },
                layout = wibox.container.margin,
              },
              nil,
              layout = wibox.layout.align.vertical
            },

            nil,

            {
              nil,
              nil,
              {
                {
                  close_button,
                  margins = {
                    bottom = naughty_sidebar.theme.close_button_margin,
                    left = naughty_sidebar.theme.close_button_margin,
                  },
                  layout = wibox.container.margin,
                },
                layout = wibox.layout.fixed.vertical,
              },
              expand='none',
              layout = wibox.layout.align.horizontal
            },

            expand='outside',
            layout = wibox.layout.align.horizontal
          },
          --/ end TITLE

          -- MESSAGE:
          {
            {
              markup = notification.message,
              font = naughty_sidebar.theme.font,
              widget = wibox.widget.textbox,
            },
            margins = {
              right = naughty_sidebar.theme.notification_padding,
            },
            layout = wibox.container.margin,
          },
          --/ end MESSAGE

          actions,
          layout = wibox.layout.fixed.vertical
        },
        margins = {
          top = naughty_sidebar.theme.close_button_margin,
          right = naughty_sidebar.theme.close_button_margin,
          bottom = naughty_sidebar.theme.notification_padding,
          left = naughty_sidebar.theme.notification_padding,
        },
        layout = wibox.container.margin,
      },
      bg = naughty_sidebar.theme.notification_bg,
      fg = naughty_sidebar.theme.notification_fg,
      shape_clip = true,
      shape = function(c, w, h)
        return gears.shape.rounded_rect(c, w, h, naughty_sidebar.theme.notification_border_radius)
      end,
      shape_border_width = naughty_sidebar.theme.notification_border_width,
      shape_border_color = naughty_sidebar.theme.notification_border_color,
      layout = wibox.container.background,
    }

    if unread then
      widget.border_color = naughty_sidebar.theme.notification_border_color_unread
    end
    widget.lie_idx = idx
    local function default_action()
      notification.args.run(notification)
    end

    local create_buttons_row = function()
      local row = wibox.layout.flex.horizontal()
      row.spacing = actions.spacing
      row.max_widget_size = gears.math.round(
        (
          naughty_sidebar.theme.width -
          naughty_sidebar.theme.spacing * 2 -
          naughty_sidebar.theme.notification_padding * 2 -
          actions.spacing * (naughty_sidebar.theme.num_buttons - 1)
        ) / naughty_sidebar.theme.num_buttons
      )
      return row
    end
    local separator_before_actions = common.constraint{height=naughty_sidebar.theme.notification_padding * 0.25}
    local buttons_row = create_buttons_row()
    local num_buttons = 0
    if notification.args.run then
      buttons_row:add(self:widget_action_button('Open', default_action))
      num_buttons = num_buttons + 1
    end
    for _, action in pairs(notification.actions or {}) do
      buttons_row:add(self:widget_action_button(action:get_name(), function()
        action:invoke(notification)
      end))
      num_buttons = num_buttons + 1
      if num_buttons % naughty_sidebar.theme.num_buttons == 0 then
        if num_buttons == naughty_sidebar.theme.num_buttons then
          actions:add(separator_before_actions)
        end
        actions:add(buttons_row)
        buttons_row = create_buttons_row()
      end
    end
    if num_buttons > 0 and num_buttons < naughty_sidebar.theme.num_buttons then
      actions:add(separator_before_actions)
      actions:add(buttons_row)
    end

    close_button:connect_signal("mouse::enter", function()
      close_button.opacity = 1
      close_button.bg = naughty_sidebar.theme.button_bg_hover
      close_button.fg = naughty_sidebar.theme.button_fg_hover
    end)
    close_button:connect_signal("mouse::leave", function()
      close_button.opacity = naughty_sidebar.theme.close_button_opacity
      close_button.bg = naughty_sidebar.theme.notification_bg
      close_button.fg = naughty_sidebar.theme.notification_fg
    end)
    close_button:buttons(awful.util.table.join(
      awful.button({ }, 1, nil, function()
        self:remove_notification(widget.lie_idx)
      end)
    ))
    widget:buttons(awful.util.table.join(
      awful.button({ }, 1, function()
        if notification.args.run then
          default_action()
        end
      end),
      awful.button({ }, 3, function()
        self:remove_notification(widget.lie_idx)
      end)
    ))
    return widget
  end

  function naughty_sidebar:widget_panel_label(text)
    return wibox.widget{
      nil,
      {
        {
          text=text,
          widget=wibox.widget.textbox
        },
        fg=naughty_sidebar.theme.sidebar_fg,
        layout = wibox.container.background,
      },
      nil,
      expand='outside',
      layout=wibox.layout.align.horizontal,
    }
  end

  local function add_custom_widget(layout, widget_description)
    if not (widget_description and widget_description.widget) then
      return
    end
    local widget_inner = wibox.container.background(
      widget_description.widget, naughty_sidebar.theme.custom_widget_bg
    )
    widget_inner.forced_height = widget_description.height or (
      naughty_sidebar.theme.custom_widget_height - naughty_sidebar.theme.button_padding*2
    )
    widget_inner.forced_width = widget_description.width or (
      naughty_sidebar.theme.width -
      naughty_sidebar.theme.spacing * 2 -
      naughty_sidebar.theme.button_padding * 2
    )
    local widget = common.panel_widget_shape(
      wibox.container.margin(
        widget_inner,
        naughty_sidebar.theme.button_padding, naughty_sidebar.theme.button_padding,
        naughty_sidebar.theme.button_padding, naughty_sidebar.theme.button_padding,
        naughty_sidebar.theme.custom_widget_bg
      )
    )
    layout:add(widget)
  end

  function naughty_sidebar:refresh_notifications()
    local layout = wibox.layout.fixed.vertical()
    layout.spacing = naughty_sidebar.theme.spacing
    local margin = wibox.container.margin()
    margin.margins = naughty_sidebar.theme.spacing

    for _, widget_description in ipairs(naughty_sidebar._custom_widgets) do
      add_custom_widget(layout, widget_description)
    end

    if #self.saved_notifications > 0 then
      layout:add(self:widget_action_button(
        '  X  Clear Notifications  ',
        function()
          self:remove_all_notifications()
        end,
        {align='middle', full_width=true}
      ))
      local unread_count = #self.saved_notifications - self.prev_count
      if self.scroll_offset > 0 then
          --text='^^^',
        layout:add(self:widget_panel_label('↑ ↑'))
      end
      for idx, n in ipairs(naughty_sidebar.saved_notifications) do
        if idx > self.scroll_offset then
          layout:add(
            self:widget_notification(n, idx, idx<=unread_count)
          )
        end
      end
    else
      layout:add(self:widget_panel_label('No notifications'))
    end
    margin:set_widget(layout)
    self.sidebar.bg = naughty_sidebar.theme.sidebar_bg

    self.sidebar:set_widget(margin)
    self.sidebar.lie_layout = layout
  end

  function naughty_sidebar:mark_all_as_read()
    self.prev_count = #self.saved_notifications
    db.set(DB_ID_READ_COUNT, self.prev_count)
  end

  function naughty_sidebar:remove_unread()
    self.scroll_offset = 0
    self:refresh_notifications()
    local num_notifications = #self.saved_notifications
    if num_notifications > 0 then
      local unread_count = #self.saved_notifications - self.prev_count
      while unread_count > 0 do
        self:remove_notification(1)
        unread_count = unread_count - 1
      end
    end
  end

  function naughty_sidebar:toggle_sidebox()
    if not self.sidebar then
      local workarea = awful.screen.focused().workarea
      self.sidebar = wibox({
        width = naughty_sidebar.theme.width,
        height = workarea.height,
        x = workarea.width - naughty_sidebar.theme.width,
        y = workarea.y,
        ontop = true,
        type='dock',
      })
      self.sidebar:buttons(awful.util.table.join(
        awful.button({ }, 4, function()
          self.scroll_offset = math.max(
            self.scroll_offset - 1, 0
          )
          self:refresh_notifications()
        end),
        awful.button({ }, 5, function()
          self.scroll_offset = math.min(
            self.scroll_offset + 1, #self.saved_notifications - 1
          )
          self:refresh_notifications()
        end)
      ))
      self:refresh_notifications()
    end
    if self.sidebar.visible then
      self.sidebar.visible = false
      self:mark_all_as_read()
    else
      self:refresh_notifications()
      self.sidebar.visible = true
    end
    self.widget:set_normal()
  end

  function naughty_sidebar:add_notification(notification)
    log{
      'notification added',
      notification.title,
      notification.message,
      notification.app_name,
    }
    table.insert(self.saved_notifications, 1, notification)
    self:write_notifications_to_db()
    self:update_counter()
    if self.sidebar and self.sidebar.visible then
      self:refresh_notifications()
    end
  end


  naughty_sidebar.widget:buttons(awful.util.table.join(
    awful.button({ }, 1, function()
      naughty_sidebar:toggle_sidebox()
    end),
    awful.button({ }, 3, function()
      if naughty_sidebar.sidebar and naughty_sidebar.sidebar.visible then
        naughty_sidebar:remove_unread()
        naughty_sidebar.sidebar.visible = false
      else
        naughty_sidebar:mark_all_as_read()
        naughty_sidebar:update_counter()
      end
    end)
  ))

  if beautiful.show_widget_icon and beautiful.widget_notifications then
    naughty_sidebar.widget:set_image(beautiful.widget_notifications)
  else
    naughty_sidebar.widget:hide()
  end
  naughty_sidebar:update_counter()

  return setmetatable(naughty_sidebar, { __index = naughty_sidebar.widget, })
end

return setmetatable(naughty_sidebar, { __call = function(_, ...)
  return widget_factory(...)
end })
