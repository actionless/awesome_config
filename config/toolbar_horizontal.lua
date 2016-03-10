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

  awesome_context.topwibox_layout_fallback = {}
  -- Create a wibox for each screen and add it
  for s = 1, capi.screen.count() do

    local wheel_binding = awful.util.table.join(
      awful.button({		}, 5, function(_)
        helpers.tag_view_noempty(1, s)
      end),
      awful.button({		}, 4, function(_)
        helpers.tag_view_noempty(-1, s)
      end)
    )


    -- LEFT side
    local left_layout = wibox.layout.fixed.horizontal(
      loaded_widgets.screen[s].manage_client,
      sep,
      loaded_widgets.screen[s].promptbox,
      sep,
      sep,
      loaded_widgets.kbd,
      sep,
      loaded_widgets.screen[s].tasklist,
      separator
    )
    left_layout:buttons(wheel_binding)


    -- CENTER
    local center_layout = wibox.layout.fixed.horizontal(
      make_separator('arrl', {fg=beautiful.panel_widget_bg}),
      loaded_widgets.screen[s].taglist,
      make_separator('arrr', {fg=beautiful.panel_widget_bg})
    )
    center_layout:buttons(wheel_binding)


    -- RIGHT side
    --

    local right_layout_left = wibox.layout.fixed.horizontal(
      beautiful.panel_tasklist and make_separator('arrr', {fg=beautiful.panel_tasklist}),
      loaded_widgets.music
    )

    local volume_widget_left_separator = make_separator('arrl', {fg=beautiful.apw_fg_color})
    local volume_widget_right_separator = make_separator('arrr', {fg=beautiful.apw_bg_color})
    local volume_layout = wibox.layout.fixed.horizontal(
      volume_widget_left_separator,
      common.constraint({
        widget=loaded_widgets.volume,
        width=dpi(120),
      }),
      volume_widget_right_separator
    )
    volume_layout:buttons(awful.util.table.join(
      awful.button({		}, 1, function(_)
        if loaded_widgets.volume.pulse.Mute then
          volume_widget_left_separator:set_fg(beautiful.apw_fg_color)
          volume_widget_right_separator:set_fg(beautiful.apw_bg_color)
        else
          volume_widget_left_separator:set_fg(beautiful.apw_mute_fg_color)
          volume_widget_right_separator:set_fg(beautiful.apw_mute_bg_color)
        end
      end)
    ))

    local right_layout_right = wibox.layout.fixed.horizontal(
      volume_layout,
      separator,
      make_separator('arrl', {fg=beautiful.panel_widget_bg}),
      iseparator,
      loaded_widgets.mem,
      iseparator,
      iseparator,
      loaded_widgets.cpu,
      iseparator
    )
    if loaded_widgets.temp then
      right_layout_right:add(loaded_widgets.temp)
    end
    if loaded_widgets.bat then
      right_layout_right:add(loaded_widgets.bat)
    end
    right_layout_right:add(
      make_separator('arrr', {fg=beautiful.panel_widget_bg}),
      make_separator('   '),
      loaded_widgets.textclock,
      make_separator('  '),
      loaded_widgets.screen[s].layoutbox,
      separator,
      sep,
      s==1 and loaded_widgets.systray_toggle or separator
    )

    local right_layout = wibox.layout.align.horizontal(
        wibox.layout.fixed.horizontal(),
        right_layout_left,
        right_layout_right
    )
    --right_layout:set_expand('none')


    -- TOOLBAR
    local layout = wibox.layout.align.horizontal(
      left_layout,
      center_layout,
      right_layout
    )
    layout:set_expand('outside')

    -- background image:
    --if beautiful.panel_bg_image then
      --local layout_bg = wibox.widget.background()
      --layout_bg:set_bgimage(beautiful.panel_bg_image)
      --layout_bg:set_widget(layout)
      --layout = layout_bg
    --end

    -- panel bottom padding:
    if beautiful.panel_padding_bottom then
      local const = wibox.layout.constraint()
      const:set_strategy("exact")
      const:set_height(beautiful.panel_padding_bottom)
      layout = wibox.layout.align.vertical(
        nil,
        layout,
        const
      )
    end

    awesome_context.topwibox_layout_fallback[s] = layout  -- this one!

    awesome_context.topwibox[s]:set_widget(
      awesome_context.topwibox_layout_fallback[s]
    )
  end

end
return toolbar
