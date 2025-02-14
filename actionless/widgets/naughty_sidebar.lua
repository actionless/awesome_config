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

local common = require("actionless.widgets.common")
local db = require("actionless.util.db")
local log = require("actionless.util.debug").log
local pack = require("actionless.util.table").pack


local DB_ID = 'notifications_storage'
local DB_ID_READ_COUNT = 'notifications_storage_read_count'

local _DUAL_KAWASE_FIXED_IN_PICOM = true


local SCROLL_UP = 4
local SCROLL_DOWN = 5
local MOUSE_LEFT = 1
local MOUSE_RIGHT = 3


local naughty_sidebar
naughty_sidebar = {
  theme = {
    num_buttons = 2,
  },
  sidebar = {},

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
      local screen_idx_str = tostring(awful.screen.focused().index)
      if (
        n.app_name ~= '' and
        naughty_sidebar.sidebar[screen_idx_str] and
        naughty_sidebar.sidebar[screen_idx_str].visible
      ) then
        return
      end
      if n.args.urgency == 'critical' then
        n.bg = beautiful.notification_bg_critical or beautiful.bg_urgent
        n.fg = beautiful.notification_fg_critical or beautiful.fg_urgent
      end

      local widget_template = wibox.widget{
        {
            {
                {
                    {
                        naughty.widget.icon,
                        {
                            {
                                font = beautiful.notification_font,
                                widget = wibox.widget.textbox,
                                id = 'title',
                            },
                            naughty.widget.message,
                            layout  = wibox.layout.fixed.vertical,
                            id = 'title_and_message_layout',
                        },
                        fill_space = true,
                        layout     = wibox.layout.fixed.horizontal,
                        id = 'icon_and_text_layout',
                    },
                    naughty.list.actions,
                    spacing = notification_args.run and dpi(10) or 0,
                    layout  = wibox.layout.fixed.vertical,
                },
                margins = beautiful.notification_margin,
                widget  = wibox.container.margin,
            },
            id     = "background_role",
            widget = naughty.container.background,
        },
        strategy = "max",
        width    = beautiful.notification_max_width or beautiful.xresources.apply_dpi(500),
        widget   = wibox.container.constraint,
      }
      local function title_changed_callback()
        widget_template:get_children_by_id('title')[1].markup = '<b>'..gears.string.xml_escape(n.title)..'</b>'
        widget_template:get_children_by_id('title_and_message_layout')[1].spacing =
          (n.title ~= '' and n.message ~= '') and dpi(4) or 0
        widget_template:get_children_by_id('icon_and_text_layout')[1].spacing =
           n.icon and dpi(4) or 0
      end
      n:connect_signal("property::title", title_changed_callback)
      n:connect_signal("property::message", title_changed_callback)
      n:connect_signal("property::icon", title_changed_callback)
      title_changed_callback()

      local box = naughty.layout.box{
        notification = n,
        -- workaround for https://github.com/awesomeWM/awesome/issues/3081 :
        shape = function(cr,w,h)
          gears.shape.rounded_rect(
            cr, w, h, (beautiful.notification_border_radius or 0)+(beautiful.notification_border_width or 0)+1
          )
        end,
        -- @TODO: merge widget template with the sidebar widget template:
        widget_template = widget_template,
      }
      if notification_args.run then
        local buttons = box:buttons()
        buttons = awful.util.table.join(buttons,
          awful.button({}, MOUSE_LEFT,
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
  set_theme('sidebar_border_width',
    beautiful.notification_sidebar_border_width,
    beautiful.panel_border_width,
    0
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
  set_theme('internal_corner_radius',
    beautiful.notification_sidebar_internal_corner_radius,
    --dpi(30)
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
  --set_theme('close_button_opacity',
  --  beautiful.notification_close_button_opacity,
  --  0.4
  --)
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
    (beautiful.basic_panel_height or dpi(18)) + (naughty_sidebar.theme.button_padding or 0)
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

  naughty_sidebar.callback_on_open = args.callback_on_open
  naughty_sidebar.callback_on_close = args.callback_on_close


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
      awful.button({ }, MOUSE_LEFT, nil, callback)
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
      if args.hide_without_notifications then
        self.widget:show()
      else
        naughty_sidebar.widget:set_image(beautiful.widget_notifications)
      end
    else
      if args.hide_without_notifications then
        self.widget:hide()
      else
        naughty_sidebar.widget:set_image(beautiful.widget_notifications_empty)
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
    self.prev_count = 0
    self:write_notifications_to_db()
    self:toggle_sidebox()
    self:update_counter()
  end

  function naughty_sidebar:widget_notification(notification, idx, unread, s)
    local height = 0
    notification.args = notification.args or {}
    local actions = wibox.layout.fixed.vertical()
    actions.spacing = gears.math.round(naughty_sidebar.theme.notification_padding * 0.75)

    local close_button_imagebox = wibox.widget.imagebox(beautiful.titlebar_close_button_normal)

    local close_button = wibox.widget{
      --{
        {
          nil,
          --wibox.widget.textbox('x'),
          close_button_imagebox,
          nil,
          expand='outside',
          layout = wibox.layout.align.horizontal,
        },
        height = naughty_sidebar.theme.close_button_size,
        width = naughty_sidebar.theme.close_button_size,
        strategy = 'exact',
        layout = wibox.container.constraint,
      --},
      --layout = wibox.container.background,
      --shape_clip = true,
      --shape = function(c, w, h)
      --  return gears.shape.partially_rounded_rect(c, w, h,
      --    false, true, false, true, beautiful.panel_widget_border_radius
      --  )
      --end,
      --shape_border_width = naughty_sidebar.theme.close_button_border_width,
      --shape_border_color = naughty_sidebar.theme.close_button_border_color,
      --opacity = naughty_sidebar.theme.close_button_opacity,
    }

    local title_margin_top = naughty_sidebar.theme.notification_padding
    local title_margin_bottom = gears.math.round(naughty_sidebar.theme.notification_padding / 2.5)
    local message_margin_top = naughty_sidebar.theme.close_button_margin
    local message_margin_bottom = naughty_sidebar.theme.notification_padding
    local widget = wibox.widget{
      {
        {
          -- TITLE:
          {

            {
              nil,
              {
                {
                  markup = '<b>'..gears.string.xml_escape(notification.title)..'</b>',
                  font = naughty_sidebar.theme.font,
                  widget = wibox.widget.textbox,
                  id = 'title'
                },
                margins = {
                  top = title_margin_top,
                  bottom = title_margin_bottom,
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
              markup = gears.string.xml_escape(notification.message),
              font = naughty_sidebar.theme.font,
              widget = wibox.widget.textbox,
              id = 'message',
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
          top = message_margin_top,
          right = naughty_sidebar.theme.close_button_margin,
          bottom = message_margin_bottom,
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
    height = (
      height +
      title_margin_top +
      pack(
        widget:get_children_by_id('title')[1]:get_preferred_size(s)
      )[2] +
      title_margin_bottom +
      message_margin_top +
      pack(
        widget:get_children_by_id('message')[1]:get_preferred_size(s)
      )[2] +
      message_margin_bottom
    )

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
    local separator_before_actions_height = naughty_sidebar.theme.notification_padding * 0.25
    local separator_before_actions = common.constraint{height=separator_before_actions_height}
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
        height = height + actions.spacing
      end
    end
    if num_buttons > 0 and num_buttons < naughty_sidebar.theme.num_buttons then
      actions:add(separator_before_actions)
      actions:add(buttons_row)
      height = height + actions.spacing * 2 + separator_before_actions_height
    end

    close_button:connect_signal("mouse::enter", function()
      --close_button.opacity = 1
      --close_button.bg = naughty_sidebar.theme.button_bg_hover
      --close_button.fg = naughty_sidebar.theme.button_fg_hover

      close_button_imagebox:set_image(beautiful.titlebar_close_button_focus)
    end)
    close_button:connect_signal("mouse::leave", function()
      --close_button.opacity = naughty_sidebar.theme.close_button_opacity
      --close_button.bg = naughty_sidebar.theme.notification_bg
      --close_button.fg = naughty_sidebar.theme.notification_fg

      close_button_imagebox:set_image(beautiful.titlebar_close_button_normal)
    end)
    close_button:buttons(awful.util.table.join(
      awful.button({ }, MOUSE_LEFT, nil, function()
        self:remove_notification(widget.lie_idx)
      end)
    ))
    widget:buttons(awful.util.table.join(
      awful.button({ }, MOUSE_LEFT, function()
        if notification.args.run then
          default_action()
        end
      end),
      awful.button({ }, MOUSE_RIGHT, function()
        self:remove_notification(widget.lie_idx)
      end)
    ))
    widget.lie_height = height
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
    local bg_color = widget_description.bg or naughty_sidebar.theme.custom_widget_bg
    local widget_inner = wibox.container.background(
      widget_description.widget, bg_color
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
        bg_color
      )
    )
    layout:add(widget)
  end

  function naughty_sidebar:_render_notifications(margins, s)
    local layout = wibox.layout.fixed.vertical()
    layout.spacing = naughty_sidebar.theme.spacing

    local spacing = naughty_sidebar.theme.notification_padding
    local create_buttons_row = function()
      local row = wibox.layout.flex.horizontal()
      row.spacing = spacing
      row.max_widget_size = gears.math.round(
        (
          naughty_sidebar.theme.width -
          margins.left - margins.right -
          spacing * (naughty_sidebar.theme.num_buttons - 1)
        ) / naughty_sidebar.theme.num_buttons
      )
      return row
    end
    local row = create_buttons_row()
    row:add(
        self:widget_action_button(
          'X  Clear All  ',
          function()
            self:remove_all_notifications()
          end,
          {align='middle'}
        )
    )
    row:add(
        self:widget_action_button(
          '★ Clear Unread',
          function()
            self:remove_unread()
          end,
          {align='middle'}
        )
    )
    layout:add(row)
    local unread_count = #self.saved_notifications - self.prev_count
    if self.scroll_offset > 0 then
        --text='^^^',
      layout:add(self:widget_panel_label('↑ ↑'))
    end

    local workarea = awful.screen.focused().workarea
    local layout_spacing = naughty_sidebar.theme.spacing
    local shown_height = 0
    for idx, n in ipairs(naughty_sidebar.saved_notifications) do
      if (
          idx > self.scroll_offset
      ) and (
          shown_height < workarea.height
      )then
        local notification = self:widget_notification(n, idx, idx<=unread_count, s)
        layout:add(notification)
        shown_height = shown_height + layout_spacing + notification.lie_height
      end
    end

    layout:buttons(awful.util.table.join(
      awful.button({ }, SCROLL_UP, function()
        self.scroll_offset = math.max(
          self.scroll_offset - 1, 0
        )
        self:refresh_notifications()
      end),
      awful.button({ }, SCROLL_DOWN, function()
        self.scroll_offset = math.min(
          self.scroll_offset + 1, #self.saved_notifications - 1
        )
        self:refresh_notifications()
      end)
    ))

    return layout
  end

  function naughty_sidebar:refresh_notifications()
    local left_border = naughty_sidebar.theme.sidebar_border_width
    local internal_corner_radius = naughty_sidebar.theme.internal_corner_radius

    local margins = {
      --left=math.max(0, naughty_sidebar.theme.spacing-left_border),
      left=naughty_sidebar.theme.spacing,
      --right=naughty_sidebar.theme.spacing,
      right=math.max(0, naughty_sidebar.theme.spacing-left_border),
      top=naughty_sidebar.theme.spacing,
      bottom=naughty_sidebar.theme.spacing,
    }

    local layout = wibox.layout.fixed.vertical()
    layout.spacing = naughty_sidebar.theme.spacing
    local margin_inner = wibox.widget{
      layout = wibox.container.margin,
      margins = margins,
    }

    local margin_outer = wibox.widget{
        {
          {
            bg=naughty_sidebar.theme.sidebar_bg,
            shape = _DUAL_KAWASE_FIXED_IN_PICOM and function(cr, w, h)
              cr:move_to(0, 0)
              cr:curve_to(
                0, 0,
                internal_corner_radius, 0,
                internal_corner_radius, internal_corner_radius
              )
              cr:line_to(internal_corner_radius, h)
              cr:line_to(w, h)
              cr:line_to(w, internal_corner_radius)
              cr:curve_to(
                w, internal_corner_radius,
                w+left_border, 0-left_border,
                0, 0
              )
              cr:close_path()
              return cr
            end,
            layout = wibox.container.background,
          },
          width=(_DUAL_KAWASE_FIXED_IN_PICOM and internal_corner_radius or 0)+left_border,
          strategy = 'exact',
          layout = wibox.container.constraint,
        },
        margin_inner,
        layout = wibox.layout.fixed.horizontal,
    }

    for _, widget_description in ipairs(naughty_sidebar._custom_widgets) do
      add_custom_widget(layout, widget_description)
    end

    if #self.saved_notifications > 0 then
      layout:add(
        self:_render_notifications(margins)
      )
    else
      layout:add(self:widget_panel_label('No notifications'))
    end
    margin_inner:set_widget(layout)
    local screen_idx_str = tostring(awful.screen.focused().index)
    self.sidebar[screen_idx_str].bg = naughty_sidebar.theme.sidebar_bg

    self.sidebar[screen_idx_str]:set_widget(margin_outer)
    self.sidebar[screen_idx_str].lie_layout = layout
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
    local internal_corner_radius = naughty_sidebar.theme.internal_corner_radius
    local focused_screen = awful.screen.focused()
    local screen_idx_str = tostring(focused_screen.index)
    if not self.sidebar[screen_idx_str] then
      local workarea = focused_screen.workarea
      local screen_geo = focused_screen.geometry
      self.sidebar[screen_idx_str] = wibox({
        width = naughty_sidebar.theme.width,
        height = workarea.height,
        x = screen_geo.width - naughty_sidebar.theme.width + workarea.x,
        y = workarea.y,
        ontop = true,
        type='dock',
        shape = _DUAL_KAWASE_FIXED_IN_PICOM and function(cr, w, h)
          cr:move_to(0, 0)
          cr:curve_to(
            0, 0,
            internal_corner_radius, 0,
            internal_corner_radius, internal_corner_radius
          )
          cr:line_to(internal_corner_radius, h)
          cr:line_to(w, h)
          cr:line_to(w, 0)
          cr:close_path()
          return cr
        end,
      })
    end
    if self.sidebar[screen_idx_str].visible then
      self.sidebar[screen_idx_str].visible = false
      self:mark_all_as_read()
      self.widget.lie_background.border_color = beautiful.panel_widget_border_color
      self.widget:set_normal()
      if self.callback_on_close then
        self.callback_on_close()
      end
    else
      self:refresh_notifications()
      self.sidebar[screen_idx_str].visible = true
      self.widget.lie_background.border_color = '#00000000'
      self.widget:set_bg('#00000000')
      self.widget:set_fg(beautiful.panel_fg)
      if self.callback_on_open then
        self.callback_on_open()
      end
    end
    self.widget.lie_background:emit_signal("widget::redraw_needed")
  end

  function naughty_sidebar:remove_or_mark_as_read()
    local screen_idx_str = tostring(awful.screen.focused().index)
    if naughty_sidebar.sidebar[screen_idx_str] and naughty_sidebar.sidebar[screen_idx_str].visible then
      naughty_sidebar:remove_unread()
      naughty_sidebar.sidebar[screen_idx_str].visible = false
    else
      naughty_sidebar:mark_all_as_read()
      naughty_sidebar:update_counter()
    end
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
    local screen_idx_str = tostring(awful.screen.focused().index)
    if self.sidebar[screen_idx_str] and self.sidebar[screen_idx_str].visible then
      self:refresh_notifications()
    end
  end


  naughty_sidebar.widget:buttons(awful.util.table.join(
    awful.button({ }, MOUSE_LEFT, function()
      naughty_sidebar:toggle_sidebox()
    end),
    awful.button({ }, MOUSE_RIGHT, function()
      naughty_sidebar:remove_or_mark_as_read()
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
