local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local capi = { screen = screen }
local lcars_layout = require("actionless.lcars_layout")
local db = require("utils.db")

local layouts = {}


function layouts.init(context)

  -- Table of layouts to cover with awful.layout.inc, order matters.
  context.layouts = {
    awful.layout.suit.tile,
    context.lcarslist_enabled and lcars_layout.top or awful.layout.suit.tile.bottom,
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
      awful.spawn.with_shell(beautiful.wallpaper_cmd)
  end
  -- }}}

  -- {{{ Tags
  -- Define a tag table which hold all screen tags.
  context.tags = {}
  for s = 1, capi.screen.count() do

    local tag_names = db.get_or_set("tag_names_"..s, {
      '1:bs', '2:web', '3:ww', '4:im', '5:mm', 6, '7:sp', 8, '9:sd', '10:nl',
      '11', '12'
    })

    local layout_ids = db.get_or_set("tag_layout_ids_"..s, {
      1, 1, 1, 1, 1, 1, 1, 1, 1, 4, 1, 1,
    })
    local layouts = {}
    for i, id in ipairs(layout_ids) do
      layouts[i] = awful.layout.layouts[id]
    end

    -- Each screen has its own tag table.
    context.tags[s] = awful.tag( tag_names, s, layouts)
    local tags = awful.tag.gettags(s)

    awful.tag.incmwfact(0.20, tags[1])
    awful.tag.incmwfact(0.20, tags[2])

    for _, tag_number in pairs({1,3,5,9}) do
      awful.tag.setmfpol("mwfact", tags[tag_number])
    end

  end
  -- }}}

end
return layouts
