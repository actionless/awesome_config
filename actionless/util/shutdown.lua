local awful_spawn = require("awful.spawn")
local gears_timer = require("gears.timer")
local naughty = require("naughty")

--local nlog = require("actionless.util.debug").naughty_log
local naughty_log = require("actionless.util.debug").naughty_log


local module = {
  kill_classes = {
    "Spotify",
  }
}


local kill_timer
local _confirm_force_shutdown = false
local _notification_remains

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
  retries = retries or 10
  module.cancel_kill()

  -- kill (sigterm) firefox instead of closing:
  -- otherwise only the last window would be restored on start
  awful_spawn.easy_async_with_shell('while pgrep -f firefox; do kill $(pgrep -f firefox); sleep 0.1 ; done', function()

    for si=1,screen.count() do
      local s = screen[si]
      for _, c in ipairs(s.all_clients) do
        c:kill()
      end
    end

    local clients_remains = {}
    for si=1,screen.count() do
      local s = screen[si]
      for _, c in ipairs(s.all_clients) do
        table.insert(clients_remains, c)
      end
    end
    if (#clients_remains == 0) or _confirm_force_shutdown then
      module.cancel_kill()
      if callback then
        callback()
      end
    else
      if retries > 0 then
        retries = retries - 1
      else
        local message = ""
        local num_clients_remains = 0
        for _, c in ipairs(clients_remains) do
          local should_be_killed = false
          for _, killable_class in ipairs(module.kill_classes) do
            if c.class == killable_class then
              should_be_killed = true
              break
            end
          end
          if should_be_killed then
            naughty_log('Killing "'..c.class..' - '..c.name..'"...')
            awful_spawn({'kill', '-9', tostring(c.pid)})
          else
            message = message .. '\n  ' .. c.class .. ' - ' .. c.name
            num_clients_remains = num_clients_remains + 1
          end
        end
        if num_clients_remains > 0 then
          message = "There are "..tostring(num_clients_remains).." clients still running:" .. message
          if not _notification_remains then
            _notification_remains = naughty.notification{text=message, timeout=0}
          else
            _notification_remains.text = message
          end
        end
      end
      if not kill_timer then
        kill_timer = gears_timer({
          callback=function() module.kill_everybody(callback, retries) end,
          timeout=1,
          autostart=true,
          call_now=false,
        })
      end
    end

  end)
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
