local naughty = require('naughty')
local awful_spawn = require('awful.spawn')

local kbd = require('actionless.keyboard')


local mpv = {}

function mpv.play_browser_url()
  kbd.chain_with_interval{
    function()
      kbd.release_modifiers()
      -- focus on address bar:
      root.fake_input('key_press'  , 'Control_L')
      root.fake_input('key_press'  , 'l')
      root.fake_input('key_release', 'l')
    end, function()
      kbd.release_modifiers()
      -- copy address to clipboard:
      root.fake_input('key_press'  , 'Control_L')
      root.fake_input('key_press'  , 'c')
      root.fake_input('key_release', 'c')
      kbd.release_modifiers()
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
        --awful_spawn.with_line_callback(
          --{'mpv', filepath},
          --{stderr=function() end}
        --)
        awful_spawn(
          {'mpv', filepath}
        )
      end
    end
  }
end

return mpv
