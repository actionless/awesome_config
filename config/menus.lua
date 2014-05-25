local awful = require("awful")
local screen = screen
local awesome = awesome
local menubar = require("menubar")
local beautiful = require("beautiful")

local menus = {}


function menus.init(status)

-- {{{ Menu
-- Create a laucher widget and a main menu
local myawesomemenu = {
  { "manual", status.cmds.terminal .. " -e man awesome" },
  { "edit config", status.cmds.editor_cmd .. " " .. awesome.conffile },
  { "restart", awesome.restart },
  { "quit", awesome.quit }
}

status.menu.mainmenu = awful.menu({items = {
  { "awesome", myawesomemenu, beautiful.awesome_icon },
  { "kill compositor", "killall compton" },
  { "start compositor", status.cmds.compositor },
  { "open terminal", status.cmds.terminal }
}})

status.widgets.launcher = awful.widget.launcher({
  image = beautiful.awesome_icon,
  menu = status.menu.mainmenu
})

-- Menubar configuration
menubar.utils.terminal = status.cmds.terminal
-- }}}


menubar.geometry = {
  height = 18,
  width = screen[1].workarea.width,
  x = 0,
  y = screen[1].workarea.height - 18
}

--require("freedesktop/freedesktop")


end
return menus
