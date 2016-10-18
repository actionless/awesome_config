local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")


local wlppr = {}

wlppr.lock = false

function wlppr.load_new()
  if wlppr.lock then
    log("WALLPAPER LOCKED (in progress)")
    return
  end
  wlppr.lock = true
  awful.spawn.easy_async(
    '/home/lie/projects/tumblr/env/bin/python /home/lie/projects/tumblr/load_images.py',
    function(...)
      wlppr.lock = false
      log(table.pack(...))
    end
  )
end

function wlppr.cycle()
  if wlppr.lock then
    log("WALLPAPER LOCKED (in progress)")
    return
  end
  wlppr.lock = true
  awful.spawn.easy_async(
    'bash -c "nitrogen --set-color='..(beautiful.gtk and beautiful.gtk.BG or beautiful.xrdb.background)..' --set-tiled $(/home/lie/projects/tumblr/env/bin/python /home/lie/projects/tumblr/save_random_image.py)"',
    function(...)
      wlppr.lock = false
      log(table.pack(...))
    end
  )
end

function wlppr.open()
  awful.spawn.easy_async(
    'bash -c "viewnior $(/home/lie/projects/tumblr/env/bin/python /home/lie/projects/tumblr/get_last_path.py)"',
    function(...)
      log(table.pack(...))
    end
  )
end

function wlppr.cycle_best()
  awful.spawn.easy_async(
    'bash -c "nitrogen --set-color='..(beautiful.gtk and beautiful.gtk.BG or beautiful.xrdb.background)..' --set-tiled $(/home/lie/projects/tumblr/env/bin/python /home/lie/projects/tumblr/get_best.py)"',
    function(...)
      log(table.pack(...))
    end
  )
end

function wlppr.save()
  awful.spawn.easy_async(
    'bash -c "cp $(/home/lie/projects/tumblr/env/bin/python /home/lie/projects/tumblr/get_last_path.py)* /home/lie/projects/tumblr/image_log/best/"',
    function(...)
      log(table.pack(...))
      naughty.notify({
        text = 'saved',
      })
    end
  )
end

return wlppr
