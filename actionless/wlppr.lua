local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")

local log = require("actionless.util.debug").log
local pack = require("actionless.util.table").pack

local wlppr = {}


local function set_wallpaper(source_script_name)
  local bg = (beautiful.gtk and beautiful.gtk.BG or beautiful.xrdb.background)
  awful.spawn.easy_async(
    'bash -c "\
    set -eu; \
    img=$('..os.getenv('HOME')..'/projects/tumblr/env/bin/python '
      ..os.getenv('HOME')..'/projects/tumblr/' ..
      source_script_name ..
    '); \
    (killall gifview || true) ; \
    grep -E "\\.gif\\$" <<< ${img} && (\
      xwinwrap -ov -fs -- gifview --bg \\"'..bg..'\\" --animate -w WID $(\
        test -f ${img}.orig && echo ${img}.orig || echo ${img}\
      ) & \
    ) || nitrogen --save --set-color=\\"'..bg..'\\" --set-tiled ${img}"',
    function(stderr, stdout, _reason, _code)
      print(' \n')
      print(stdout)
      print(stderr)
      print(' \n')
    end
  )
end


function wlppr.cycle()
  set_wallpaper('save_random_image.py')
end

function wlppr.cycle_best()
  set_wallpaper('get_best.py')
end

function wlppr.load_new()
  awful.spawn.easy_async(
    ''..os.getenv('HOME')..'/projects/tumblr/env/bin/python '..os.getenv('HOME')..'/projects/tumblr/load_images.py',
    function(stderr, stdout, _reason, _code)
      print(' \n')
      print(stdout)
      print(stderr)
      print(' \n')
    end
  )
end

function wlppr.open()
  awful.spawn.easy_async(
    'bash -c "viewnior $('..
      os.getenv('HOME')..
      '/projects/tumblr/env/bin/python '..
      os.getenv('HOME')..'/projects/tumblr/get_last_path.py)"',
    function(...)
      if ... then
        log(pack(...))
      end
    end
  )
end

function wlppr.save()
  awful.spawn.easy_async(
    'bash -c "cp $('..os.getenv('HOME')..'/projects/tumblr/env/bin/python '..
      os.getenv('HOME')..'/projects/tumblr/get_last_path.py)* '..
      os.getenv('HOME')..'/projects/tumblr/image_log/best/"',
    function(stderr, stdout, _reason, _code)
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
    'bash -c "cp $('..os.getenv('HOME')..'/projects/tumblr/env/bin/python '..
      os.getenv('HOME')..'/projects/tumblr/get_last_path.py)* \\"'..
      os.getenv('HOME')..'/projects/tumblr/image_log/the very best/\\""',
    function(stderr, stdout, _reason, _code)
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
    'bash -c "mv $('..os.getenv('HOME')..'/projects/tumblr/env/bin/python '..
      os.getenv('HOME')..'/projects/tumblr/get_last_path.py)* \"'..
      os.getenv('HOME')..'/projects/tumblr/image_log/dump/\""',
    function(stderr, stdout, _reason, _code)
      print(stdout)
      print(stderr)
      naughty.notify({
        text = 'dumped'..stderr..stdout,
      })
    end
  )
end

return wlppr
