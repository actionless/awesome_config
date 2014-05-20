local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local capi = { screen = screen }


local layouts = {}


function layouts.init()
-- Table of layouts to cover with awful.layout.inc, order matters.
my_layouts = {
  awful.layout.suit.tile,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.floating,
  awful.layout.suit.fair,
  awful.layout.suit.fair.horizontal,
  awful.layout.suit.spiral
}
awful.layout.layouts = my_layouts
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
  for s = 1, capi.screen.count() do
    gears.wallpaper.tiled(beautiful.wallpaper, s)
  end
else if beautiful.wallpaper_cmd then
  run_once(beautiful.wallpaper_cmd)
end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, capi.screen.count() do
  -- Each screen has its own tag table.
  tags[s] = awful.tag({ '1:bs', '2:web', '3:ww', '4:im', '5:mm', 6, 7, 8, '9:sd', '0:nl' }, s, awful.layout.layouts[1])
end
-- }}}

end
return layouts

