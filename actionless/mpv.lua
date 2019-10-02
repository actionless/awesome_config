local naughty = require('naughty')
local gears_timer = require('gears.timer')
local awful_spawn = require('awful.spawn')

local function chain_with_interval(funcs, interval)
  interval = interval or 0.1
  local func_counter = 1
  local func_timer
  func_timer = gears_timer{
    timeout   = interval,
    call_now  = false,
    autostart = true,
    callback=function()
      if funcs[func_counter] then
        funcs[func_counter]()
        func_counter = func_counter + 1
      else
        func_timer:stop()
      end
    end
  }
end

local function release_modifiers()
  root.fake_input('key_release'  , 'Super_L')
  root.fake_input('key_release'  , 'Control_L')
  root.fake_input('key_release'  , 'Super_R')
  root.fake_input('key_release'  , 'Control_R')
end

local mpv = {}

function mpv.play_browser_url()
  chain_with_interval{
    function()
      release_modifiers()
      -- focus on address bar:
      root.fake_input('key_press'  , 'Control_L')
      root.fake_input('key_press'  , 'l')
      root.fake_input('key_release', 'l')
    end, function()
      release_modifiers()
      -- copy address to clipboard:
      root.fake_input('key_press'  , 'Control_L')
      root.fake_input('key_press'  , 'c')
      root.fake_input('key_release', 'c')
      release_modifiers()
    end, function()
      local filepath = selection()
      if not filepath then
        naughty.notification{
          title = 'Nothing to do',
          text = 'Clipboard is empty',
        }
      else
        log('Opening in mpv...')
        log(filepath)
        naughty.notification{
          title = 'Opening in mpv...',
          text = filepath,
        }
        awful_spawn.with_line_callback(
          {'mpv', filepath},
          {stderr=function() end}
        )
      end
    end
  }
end

return mpv
