local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local awful = require("awful")

local capi = {
  screen = screen,
  client = client,
}

local helpers = require("actionless.helpers")
local widgets = require("actionless.widgets")
local common = widgets.common
local make_separator = require("actionless.widgets.common").make_separator


local toolbar = {}


function toolbar.init(awesome_context)
  local loaded_widgets = awesome_context.widgets

  -- Separators
  local sep = common.constraint({ width=dpi(2), })
  local separator  = make_separator(' ')
  local iseparator  = make_separator(' ', {bg=beautiful.panel_widget_bg})
  local sep_info   = make_separator('sq', {fg=beautiful.panel_info})
  local sep_media  = make_separator('sq', {fg=beautiful.panel_media})

  awesome_context.topwibox_layout_fallback = {}
  -- Create a wibox for each screen and add it
  local mywibox = {}
  for s = 1, capi.screen.count() do

    local wheel_binding = awful.util.table.join(
      awful.button({		}, 5, function(t)
        helpers.tag_view_noempty(1, s)
      end),
      awful.button({		}, 4, function(t)
        helpers.tag_view_noempty(-1, s)
      end)
    )


    -- LEFT side
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:buttons(wheel_binding)

    --left_layout:add(make_separator('arrl', {fg=beautiful.panel_widget_bg}))
    --left_layout:add(loaded_widgets.screen[s].taglist)
    --left_layout:add(make_separator('arrr', {fg=beautiful.panel_widget_bg}))
    left_layout:add(loaded_widgets.screen[s].manage_client)
    left_layout:add(sep)
    left_layout:add(loaded_widgets.screen[s].promptbox)
    left_layout:add(sep)
    left_layout:add(sep)
    left_layout:add(loaded_widgets.kbd)
    left_layout:add(sep)
    --left_layout:add(common.constraint({
      --widget=loaded_widgets.screen[s].tasklist,
      --width=(screen[s].workarea.width / 3),
    --}))
    left_layout:add(loaded_widgets.screen[s].tasklist)
    left_layout:add(separator)


    -- CENTER
    local center_layout = wibox.layout.fixed.horizontal()
    center_layout:buttons(wheel_binding)

    center_layout:add(make_separator('arrl', {fg=beautiful.panel_widget_bg}))
    center_layout:add(loaded_widgets.screen[s].taglist)
    center_layout:add(make_separator('arrr', {fg=beautiful.panel_widget_bg}))


    -- RIGHT side
    local right_layout = wibox.layout.align.horizontal()
    --

    local right_layout_left = wibox.layout.fixed.horizontal()
    if beautiful.panel_tasklist then
      right_layout_left:add(make_separator('arrr', {fg=beautiful.panel_tasklist}))
    end
    right_layout_left:add(separator)
    right_layout_left:add(loaded_widgets.music)
    --right_layout_left:add(separator)

    local right_layout_right = wibox.layout.fixed.horizontal()
    right_layout_right:add(make_separator('arrl', {fg=beautiful.panel_media}))
    --right_layout_right:add(separator)
    right_layout_right:add(
      common.constraint({
        widget=loaded_widgets.volume,
        --width=dpi(80),
        width=dpi(120),
      })
    )
    right_layout_right:add(separator)

    right_layout_right:add(make_separator('arrl', {fg=beautiful.panel_widget_bg}))
    --right_layout_right:add(iseparator)
    right_layout_right:add(iseparator)
    right_layout_right:add(loaded_widgets.mem)
    right_layout_right:add(iseparator)
    right_layout_right:add(iseparator)
    right_layout_right:add(loaded_widgets.cpu)
    right_layout_right:add(iseparator)
    if loaded_widgets.temp then
      right_layout_right:add(loaded_widgets.temp)
    end
    if loaded_widgets.bat then
      right_layout_right:add(loaded_widgets.bat)
    end
    --right_layout_right:add(iseparator)
    right_layout_right:add(make_separator('arrr', {fg=beautiful.panel_widget_bg}))
    right_layout_right:add(separator)

    right_layout_right:add(separator)

    ----!--right_layout_right:add(make_separator('arrl', {fg=beautiful.panel_widget_bg}))
    right_layout_right:add(separator)
    right_layout_right:add(loaded_widgets.textclock)
    right_layout_right:add(separator)
    right_layout_right:add(separator)
    right_layout_right:add(loaded_widgets.screen[s].layoutbox)
    right_layout_right:add(separator)
    ----!--right_layout_right:add(make_separator('arrr', {fg=beautiful.panel_widget_bg_disabled}))
    right_layout_right:add(sep)

    if s == 1 then
      right_layout_right:add(loaded_widgets.systray_toggle)
    else
      right_layout_right:add(separator)
    end


    --right_layout:set_expand('none')
    right_layout:set_middle(
      wibox.widget.background(
        right_layout_left--, '#ff0000'
      )
    )
    right_layout:set_left(
      wibox.widget.background(
        wibox.layout.fixed.horizontal()--, '#00ff00'
      )
    )
    right_layout:set_right(
      wibox.widget.background(
        right_layout_right--, '#0000ff'
      )
    )


    -- TOOLBAR
    local layout = wibox.layout.align.horizontal()
    layout:set_expand('outside')
    layout:set_left(left_layout)
    layout:set_middle(center_layout)
    --layout:set_right(right_layout)
    layout:set_right(
      wibox.widget.background(
        right_layout--,'#ffff00'
      )
    )

    -- background image:
    --if beautiful.panel_bg_image then
      --local layout_bg = wibox.widget.background()
      --layout_bg:set_bgimage(beautiful.panel_bg_image)
      --layout_bg:set_widget(layout)
      --layout = layout_bg
    --end

    -- bottom panel padding:
    if beautiful.panel_padding_bottom then
      local const = wibox.layout.constraint()
      const:set_strategy("exact")
      const:set_height(beautiful.panel_padding_bottom)
      local margined_layout = wibox.layout.align.vertical()
      margined_layout:set_middle(layout)
      margined_layout:set_bottom(const)
      layout = margined_layout
    end

    awesome_context.topwibox_layout_fallback[s] = layout  -- this one!

    awesome_context.topwibox[s]:set_widget(
      awesome_context.topwibox_layout_fallback[s]
    )
  end

end
return toolbar
