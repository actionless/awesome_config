local gears_timer = require('gears.timer')


local doubleclick = {
  interval=0.3
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
    timeout=doubleclick.interval,
    autostart=true,
    call_now=false,
  })
end


return doubleclick
