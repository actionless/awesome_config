local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local capi = { screen = screen }
local lain = require("lain")

local layouts = {}


function layouts.init(context)

  -- Table of layouts to cover with awful.layout.inc, order matters.
  if beautiful.hidpi then
    context.layouts = {
      --awful.layout.suit.tile,
      lain.layout.centerwork,
      lain.layout.uselesstile,
      awful.layout.suit.tile.bottom,
      awful.layout.suit.floating,
      awful.layout.suit.fair,
      awful.layout.suit.fair.horizontal,
      awful.layout.suit.spiral
    }
  else
    context.layouts = {
      awful.layout.suit.tile,
      awful.layout.suit.tile.bottom,
      awful.layout.suit.floating,
      awful.layout.suit.fair,
      awful.layout.suit.fair.horizontal,
      awful.layout.suit.spiral
    }
  end
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
      { '1:bs', '2:web', '3:ww', '4:im', '5:mm', 6, 7, 8, '9:sd', '10:nl', '11', '12' },
      s,
      {
        awful.layout.layouts[1],
        awful.layout.layouts[2],
        awful.layout.layouts[1],
        awful.layout.layouts[1],
        awful.layout.layouts[1],
        awful.layout.layouts[1],
        awful.layout.layouts[1],
        awful.layout.layouts[1],
        awful.layout.layouts[1],
        awful.layout.layouts[3],
        awful.layout.layouts[1],
        awful.layout.layouts[1],
      }
    )
    awful.tag.incmwfact(0.20, awful.tag.gettags(s)[2])
  end
  -- }}}

end
return layouts
