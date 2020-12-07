--[[
Licensed under GNU General Public License v2
* (c) 2020, Yauheni Kirylau
--]]

local wibox = require('wibox')
local awful = require('awful')
local gears = require('gears')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi

local common = require("actionless.widgets.common")
local db = require("actionless.util.db")


local DB_ID = 'notifications_storage'
local DB_ID_READ_COUNT = 'notifications_storage_read_count'


local naughty_sidebar = {}

local function widget_factory(args)
  args	 = args or {}
  args.orientation = args.orientation or "horizontal"
  if beautiful.panel_widget_spacing  then
    args.margin = {
      left=beautiful.panel_widget_spacing,
      right=beautiful.panel_widget_spacing,
    }
    if beautiful.panel_widget_spacing then
      args.margin_left = beautiful.panel_widget_spacing - beautiful.panel_padding_bottom
      args.margin_right = beautiful.panel_padding_bottom
    end
  end
  args.panel_shape = true
  args.fg = args.fg or beautiful.notification_counter_fg
  args.bg = args.bg or beautiful.notification_counter_bg
  args.hide_without_notifications = (args.hide_without_notifications == nil) and true or false

  naughty_sidebar.widget = common.decorated(args)
  naughty_sidebar.saved_notifications = db.get_or_set(DB_ID, {})
  naughty_sidebar.prev_count = db.get_or_set(DB_ID_READ_COUNT, 0)
  naughty_sidebar.scroll_offset = 0
  naughty_sidebar._custom_widgets = args.custom_widgets or {}


  function naughty_sidebar:widget_action_button(text, callback, widget_args)
    local bg_color = beautiful.notification_bg or beautiful.bg_normal
    local fg_color = beautiful.notification_fg or beautiful.fg_normal
    widget_args = widget_args or {}
    local label = {
      markup = text,
      font = beautiful.notification_font or "Sans 8",
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
    local widget = common.set_panel_shape(wibox.widget{
      {
        {
          label,
          layout = wibox.layout.fixed.vertical
        },
        margins = beautiful.notification_sidebar_button_padding or dpi(5),
        layout = wibox.container.margin,
      },
      bg = bg_color,
      fg = fg_color,
      layout = wibox.container.background,
    })
    widget:buttons(awful.util.table.join(
      awful.button({ }, 1, callback)
    ))
    widget:connect_signal("mouse::enter", function()
      widget.bg = beautiful.bg_focus
      widget.fg = beautiful.fg_focus
    end)
    widget:connect_signal("mouse::leave", function()
      widget.bg = bg_color
      widget.fg = fg_color
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
    if (num_notifications > 0) or (not args.hide_without_notifications) then
      local unread_count = #self.saved_notifications - self.prev_count
      if unread_count > 0 then
        self.widget:set_warning()
      else
        self.widget:set_normal()
      end
      self.widget:show()
    else
      self.widget:hide()
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
    local bg_color = beautiful.notification_bg or beautiful.bg_normal
    local fg_color = beautiful.notification_fg or beautiful.fg_normal
    local panel_padding = beautiful.notification_sidebar_padding or dpi(10)
    local actions = wibox.layout.fixed.vertical()
    actions.spacing = math.ceil(panel_padding/2)
    local widget = wibox.widget{
      {
        {
          wibox.widget.textbox(notification.title),
          {
            markup = notification.message,
            font = beautiful.notification_font or "Sans 8",
            widget = wibox.widget.textbox,
          },
          actions,
          layout = wibox.layout.fixed.vertical
        },
        margins = panel_padding,
        layout = wibox.container.margin,
      },
      bg = bg_color,
      fg = fg_color,
      shape_clip = true,
      shape = function(c, w, h)
        return gears.shape.rounded_rect(c, w, h, beautiful.notification_border_radius or dpi(1))
      end,
      shape_border_width = beautiful.notification_border_width or dpi(1),
      shape_border_color = beautiful.notification_border_color or beautiful.border_normal,
      layout = wibox.container.background,
    }
    if unread then
      widget.border_color = beautiful.warning or beautiful.bg_focus
      --widget.border_width = widget.border_width * 2
      --widget.border_color = beautiful.error or beautiful.bg_focus
    end
    widget.lie_idx = idx
    local function default_action()
      notification.args.run(notification)
    end
    if notification.args.run then
      actions:add(common.constraint({height=actions.spacing}))
      actions:add(self:widget_action_button('Open', default_action))
    end
    for _, action in pairs(notification.actions or {}) do
      actions:add(self:widget_action_button(action:get_name(), function()
        action:invoke(notification)
      end))
    end
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
    local fg = beautiful.notification_sidebar_fg or beautiful.panel_fg or beautiful.fg_normal
    return wibox.widget{
      nil,
      {
        {
          text=text,
          widget=wibox.widget.textbox
        },
        fg=fg,
        layout = wibox.container.background,
      },
      nil,
      expand='outside',
      layout=wibox.layout.align.horizontal,
    }
  end

  function naughty_sidebar:refresh_notifications()
    local layout = wibox.layout.fixed.vertical()
    local margin = wibox.container.margin()
    margin.margins = beautiful.notification_sidebar_margin or dpi(10)
    layout.spacing = beautiful.notification_sidebar_spacing or dpi(10)
    for _, widget in ipairs(naughty_sidebar._custom_widgets) do
      layout:add(widget)
    end
    if #self.saved_notifications > 0 then
      layout:add(self:widget_action_button(
        '  X  Clear Notifications  ',
        function()
          self:remove_all_notifications()
        end,
        {align='middle'}
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
    self.sidebar.bg = beautiful.notification_sidebar_bg or beautiful.panel_bg or beautiful.bg_normal

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
      local width = (
        beautiful.notification_sidebar_width or
        beautiful.notification_max_width or
        dpi(300)
      )
      local workarea = awful.screen.focused().workarea
      self.sidebar = wibox({
        width = width,
        height = workarea.height,
        x = workarea.width - width,
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

  return setmetatable(naughty_sidebar, { __index = naughty_sidebar.widget })
end

return setmetatable(naughty_sidebar, { __call = function(_, ...)
  return widget_factory(...)
end })
