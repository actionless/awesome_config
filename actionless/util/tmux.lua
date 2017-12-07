local awful = require("awful")
local naughty = require("naughty")
local gears_geometry = require("gears.geometry")


local tmux = {}

function tmux.swap_bydirection(dir, c, stacked)
  local tmux_session_pattern = "%[(%d+)%]"
  local focused_client = c or client.focus
  if not focused_client then return end
  local visible_clients = awful.client.visible(focused_client.screen, stacked)
  local client_geometries = {}
  for i, cl in ipairs(visible_clients) do
    if cl.name:match(tmux_session_pattern) then
      client_geometries[i] = cl:geometry()
    end
  end

  local target_client_id = gears_geometry.rectangle.get_in_direction(
    dir, client_geometries, focused_client:geometry()
  )

  if not target_client_id then
    return naughty.notify({text="no tmux window in '"..dir.."' direction"})
  end

  local source_tmux_session = focused_client.name:match(tmux_session_pattern)
  local target_tmux_session = visible_clients[target_client_id].name:match(tmux_session_pattern)
  awful.spawn.with_shell(string.format(
    "tmux move-window -s %d: -t %d:",
    source_tmux_session, target_tmux_session
  ))
  client.focus = visible_clients[target_client_id]
end

return tmux
