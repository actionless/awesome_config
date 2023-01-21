local awful = require("awful")

local menubar = require("actionless.menubar")

local menubars = {}


-- Menubar configuration
function menubars.init(context)

  -- @TODO: for some reason this is crashing
  --context.menu.menubar = awesome_menubar.get()
  context.menu.menubar = menubar.create()

  local dmenubar = menubar.create({
    term_prefix = context.cmds.tmux_run,
    position = 'bottom',
  })
  dmenubar.cache_entries = false
  dmenubar.menu_cache_path = awful.util.getdir("cache") .. "/history"
  dmenubar.menu_gen = require("actionless.menubar.dmenugen")
  context.menu.dmenubar = dmenubar

end

return menubars
