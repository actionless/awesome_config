local gears_timer = require('gears.timer')

local keyboard = {}

function keyboard.chain_with_interval(funcs, interval)
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

function keyboard.release_modifiers()
  root.fake_input('key_release'  , 'Super_L')
  root.fake_input('key_release'  , 'Control_L')
  root.fake_input('key_release'  , 'Super_R')
  root.fake_input('key_release'  , 'Control_R')
end

return keyboard
