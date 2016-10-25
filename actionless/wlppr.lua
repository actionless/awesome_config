local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")

local wlppr = {}


function wlppr.load_new()
  awful.spawn.easy_async(
    '/home/lie/projects/tumblr/env/bin/python /home/lie/projects/tumblr/load_images.py',
    function(stderr, stdout, reason, code)
      print(' \n')
      print(stdout)
      print(stderr)
      print(' \n')
    end
  )
end

function wlppr.cycle()
  awful.spawn.easy_async(
    'bash -c "nitrogen --set-color='..(beautiful.gtk and beautiful.gtk.BG or beautiful.xrdb.background)..' --set-tiled $(/home/lie/projects/tumblr/env/bin/python /home/lie/projects/tumblr/save_random_image.py)"',
    function(stderr, stdout, reason, code)
      print(' \n')
      print(stdout)
      print(stderr)
      print(' \n')
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
    function(stderr, stdout, reason, code)
      print(stdout)
      print(stderr)
    end
  )
end

function wlppr.save()
  awful.spawn.easy_async(
    'bash -c "cp $(/home/lie/projects/tumblr/env/bin/python /home/lie/projects/tumblr/get_last_path.py)* /home/lie/projects/tumblr/image_log/best/"',
    function(stderr, stdout, reason, code)
      print(stdout)
      print(stderr)
      naughty.notify({
        text = 'saved'..stderr..stdout,
      })
    end
  )
end

function wlppr.save_best()
  awful.spawn.easy_async(
    'bash -c "cp $(/home/lie/projects/tumblr/env/bin/python /home/lie/projects/tumblr/get_last_path.py)* \\"/home/lie/projects/tumblr/image_log/the very best/\\""',
    function(stderr, stdout, reason, code)
      print(stdout)
      print(stderr)
      naughty.notify({
        text = 'saved to best'..stderr..stdout,
      })
    end
  )
end

function wlppr.dump()
  awful.spawn.easy_async(
    'bash -c "mv $(/home/lie/projects/tumblr/env/bin/python /home/lie/projects/tumblr/get_last_path.py)* \"/home/lie/projects/tumblr/image_log/dump/\""',
    function(stderr, stdout, reason, code)
      print(stdout)
      print(stderr)
      naughty.notify({
        text = 'dumped'..stderr..stdout,
      })
    end
  )
end

return wlppr
