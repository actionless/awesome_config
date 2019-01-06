local awful = require("awful")
local beautiful = require("beautiful")

local menubar = require("actionless.menubar")

local menubars = {}


-- Menubar configuration
function menubars.init(context)

  -- @TODO: for some reason this is crashing
  --context.menu.menubar = awesome_menubar.get()
  context.menu.menubar = menubar.create()

  -- D-Menubar configuration
  menubar.geometry = {
    height = beautiful.panel_height,
    width = screen[awful.screen.focused()].workarea.width,
    x = 0,
    y = screen[awful.screen.focused()].workarea.height - beautiful.panel_height
  }

  local dmenubar = menubar.create({
    term_prefix = context.cmds.tmux_run,
  })
  dmenubar.cache_entries = false
  dmenubar.menu_cache_path = awful.util.getdir("cache") .. "/history"
  dmenubar.menu_gen = require("actionless.menubar.dmenugen")

  context.menu.dmenubar = dmenubar

end

return menubars
