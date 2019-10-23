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

local MODIFIERS = {
  Shift={"Shift_L", "Shift_R"},
  Control={"Control_L", "Control_R"},
  Mod1={"Alt_L",},
  Mod4={"Super_L", "Super_R"},
}

function keyboard.release_modifiers()
  for _, a_modifier in ipairs(awesome._active_modifiers) do
    for _, x_modifier in ipairs(MODIFIERS[a_modifier]) do
      root.fake_input('key_release', x_modifier)
    end
  end
end

return keyboard
