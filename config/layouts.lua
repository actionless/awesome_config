local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local capi = { screen = screen }
local lcars_layout = require("actionless.lcars_layout")

local layouts = {}


function layouts.init(context)

  -- Table of layouts to cover with awful.layout.inc, order matters.
  context.layouts = {
    awful.layout.suit.tile,
    lcars_layout.top,
    awful.layout.suit.corner.nw,
    awful.layout.suit.floating,
    awful.layout.suit.fair,
    awful.layout.suit.spiral,
  }
  awful.layout.layouts = context.layouts
  -- }}}

  -- {{{ Wallpaper
  if beautiful.wallpaper then
    local wallpaper_layout = beautiful.wallpaper_layout or "tiled"
    for s = 1, capi.screen.count() do
      gears.wallpaper[wallpaper_layout](beautiful.wallpaper, s)
    end
  elseif beautiful.wallpaper_cmd then
      awful.util.spawn_with_shell(beautiful.wallpaper_cmd)
  end
  -- }}}

  -- {{{ Tags
  -- Define a tag table which hold all screen tags.
  context.tags = {}
  for s = 1, capi.screen.count() do
    -- Each screen has its own tag table.
    context.tags[s] = awful.tag(
      { '1:bs', '2:web', '3:ww', '4:im', '5:mm',
         6, '7:sp', 8, '9:sd', '10:nl', '11', '12' },
      s,
      {
        awful.layout.layouts[1],
        awful.layout.layouts[1],
        awful.layout.layouts[1],
        awful.layout.layouts[1],
        awful.layout.layouts[1],
        awful.layout.layouts[1],
        awful.layout.layouts[1],
        awful.layout.layouts[1],
        awful.layout.layouts[1],
        awful.layout.layouts[4],
        awful.layout.layouts[1],
        awful.layout.layouts[1],
      }
    )
    local tags = awful.tag.gettags(s)

    awful.tag.incmwfact(0.20, tags[1])
    awful.tag.incmwfact(0.20, tags[2])
    awful.tag.incmwfact(0.05, tags[7])

    for _, tag_number in pairs({1,3,5,7,9}) do
      awful.tag.setmfpol("mwfact", tags[tag_number])
    end

    --for _, t in ipairs(tags) do
      --awful.tag.setproperty(t, 'left_panel_visible', false)
    --end

  end
  -- }}}

end
return layouts
