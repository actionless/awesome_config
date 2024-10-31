local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local lcars_layout = require("actionless.lcars_layout")
local persistent = require("actionless.persistent")
local tag_helpers = require("actionless.util.tag")

local layouts = {}


function layouts.init(context)

  if context.DEVEL_DYNAMIC_LAYOUTS then
    require("awful.layout.dynamic")
  end

  gears.timer.delayed_call(function()
    persistent.init_tag_signals()  -- init signals to autotimally save tags' properties
  end)

  -- Table of layouts to cover with awful.layout.inc, order matters.
  tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
      awful.layout.suit.tile,
      awful.layout.suit.tile.left,
      persistent.lcarslist.get() and lcars_layout.top or awful.layout.suit.tile.bottom,
      awful.layout.suit.corner.nw,
      awful.layout.suit.floating,
      awful.layout.suit.fair,
      awful.layout.suit.fair.horizontal,
      awful.layout.suit.spiral,
    })
  end)
  -- }}}

  -- {{{ Wallpaper
  if beautiful.wallpaper then
    local function set_wallpaper(s)
      if type(beautiful.wallpaper) == "string" then
        local wallpaper_layout = beautiful.wallpaper_layout or "tiled"
        gears.wallpaper[wallpaper_layout](beautiful.wallpaper, s)
      else
        gears.wallpaper.set(beautiful.wallpaper(s), s)
      end
    end
    awful.screen.connect_for_each_screen(set_wallpaper)
    screen.connect_signal("property::geometry", set_wallpaper)
  elseif beautiful.wallpaper_cmd then
    gears.timer.delayed_call(function()
      awful.spawn.with_shell(beautiful.wallpaper_cmd)
    end)
  end
  -- }}}

  -- {{{ Tags
  -- Define a tag table which hold all screen tags.
  awful.screen.connect_for_each_screen(function(s)

    local max_tag = 12
    if screen.count() == 1 then
      max_tag = 24
    end

    local enabled_layouts = {}
    for i, id in pairs(persistent.tag.get_all_layouts(s, {
      1, 1, 1, 1, 1, 1,
      1, 1, 1, 4, 1, 1,
    })) do
      enabled_layouts[i] = awful.layout.layouts[id]
    end

    local tag_names = persistent.tag.get_all_names(s, {
      '1:bs', '2:web', '3:ww', '4:im', '5:mm', '6',
      '7:sp', '8',     '9:sd', '-:nl', '=',    'F1',
    })

    local num_tags = #tag_names
    for i = 1, max_tag - num_tags do
      local tag_idx = tag_helpers.tag_idx_to_key(max_tag - num_tags + i)
      table.insert(enabled_layouts, awful.layout.layouts[1])
      table.insert(tag_names, tostring(tag_idx))
    end

    local tags = awful.tag(tag_names, s, enabled_layouts)

    for tag_number, mwfact in pairs(persistent.tag.get_all_mwfact(s, {
    --1     2     3      4     5     6
      0.60, 0.75, 0.50,  0.50, 0.50, 0.50,
    --7     8     9      10    11    12
      0.50, 0.50, 0.50,  0.50, 0.50, 0.50
    })) do
        tags[tag_number].master_width_factor = mwfact
    end

    for tag_number, mfpol in pairs(persistent.tag.get_all_mfpol(s, {
    --1                      2                      3
      "master_width_factor", "expand",              "master_width_factor",
    --4                      5                      6
      "expand",              "master_width_factor", "expand",
    --7                      8                      9
      "expand",              "expand",              "master_width_factor",
    --10                     11                     12
      "expand",              "expand",              "expand"
    })) do
        tags[tag_number].master_fill_policy = mfpol
    end

    local u = beautiful.useless_gap
    for tag_number, gap in pairs(persistent.tag.get_all_uselessgaps(s, {
    --1                      2                      3
      u,	             u,	                    u,
    --4                      5                      6
      u,	             u,	                    u,
    --7                      8                      9
      u,	             u,	                    u,
    --10                     11                     12
      u,	             u,	                    u,
    })) do
        tags[tag_number].gap = gap
    end

    for tag_number, master_count in pairs(persistent.tag.get_all_mastercounts(s, {
    --1                      2                      3
      1,                     1,                     1,
    --4                      5                      6
      1,                     1,                     1,
    --7                      8                      9
      1,                     1,                     1,
    --10                     11                     12
      1,                     1,                     1,
    })) do
        tags[tag_number].master_count = master_count
    end

    for tag_number, column_count in pairs(persistent.tag.get_all_columncounts(s, {
    --1                      2                      3
      1,                     1,                     1,
    --4                      5                      6
      1,                     1,                     1,
    --7                      8                      9
      1,                     1,                     1,
    --10                     11                     12
      1,                     1,                     1,
    })) do
        tags[tag_number].column_count = column_count
    end


  end)
  -- }}}

end
return layouts
