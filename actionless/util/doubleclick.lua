local gears_timer = require('gears.timer')


local doubleclick = {
  perform_interval=0.03,
  catch_interval=0.3,
}


local _actions = setmetatable({}, {__mode="kv"})


function doubleclick.action(action_id, single, double)
  if not double then
    single()
    return
  end

  if _actions[action_id] then
    _actions[action_id] = nil
    double()
    return
  end

  _actions[action_id] = true
  local timer
  timer = gears_timer({
    callback=function()
      if _actions[action_id] then
        _actions[action_id] = nil
        single()
      end
      timer:stop()
    end,
    timeout=doubleclick.catch_interval,
    autostart=true,
    call_now=false,
  })
end

function doubleclick.perform(button_id)
  button_id = button_id or 1

  root.fake_input("button_press" , button_id)
  root.fake_input("button_release", button_id)

  local timer
  timer = gears_timer({
    callback=function()
      root.fake_input("button_press" , button_id)
      root.fake_input("button_release", button_id)
      timer:stop()
    end,
    timeout=doubleclick.perform_interval,
    autostart=true,
    call_now=false,
  })
end



return doubleclick
