local awful_spawn = require("awful.spawn")
local gears_timer = require("gears.timer")


local module = {}


local kill_timer
local _confirm_force_shutdown = false

function module.cancel_kill()
  if kill_timer then
    kill_timer:stop()
    kill_timer = nil
  end
end

function module.skip_kill()
  _confirm_force_shutdown = true
end

function module.kill_everybody(callback, retries)
  retries = retries or 0
  module.cancel_kill()

  -- kill (sigterm) firefox instead of closing:
  -- otherwise only the last window would be restored on start
  awful_spawn('killall firefox')

  for si=1,screen.count() do
    local s = screen[si]
    for _, c in ipairs(s.all_clients) do
      c:kill()
    end
  end

  local clients_remains = 0
  for si=1,screen.count() do
    local s = screen[si]
    for _, _ in ipairs(s.all_clients) do
      clients_remains = clients_remains + 1
    end
  end
  if (clients_remains == 0) or _confirm_force_shutdown then
    if callback then
      callback()
    end
  else
    if retries > 1 then
      nlog("there are "..tostring(clients_remains).." clients are still running")
    end
    if not kill_timer then
      kill_timer = gears_timer({
        callback=function() module.kill_everybody(callback) end,
        timeout=1,
        autostart=true,
        call_now=false,
      })
    end
  end
end

--local function session_logout()
--  kill_everybody()
--  --awful_spawn('mate-session-save --gui --logout-dialog')
--  awful_spawn('qdbus --literal org.gnome.SessionManager /org/gnome/SessionManager org.gnome.SessionManager.Logout 1')
--end

--local function session_poweroff()
--  kill_everybody()
--  --awful_spawn('mate-session-save --gui --shutdown-dialog')
--  awful_spawn('qdbus org.gnome.SessionManager /org/gnome/SessionManager org.gnome.SessionManager.RequestShutdown')
--end

--local function session_reboot()
--  kill_everybody()
--  --awful_spawn('mate-session-save --gui --shutdown-dialog')
--  awful_spawn('qdbus org.gnome.SessionManager /org/gnome/SessionManager org.gnome.SessionManager.RequestReboot')
--end

return module
