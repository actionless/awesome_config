local awful = require("awful")
local awesome = awesome
local menubar = require("menubar")
local beautiful = require("beautiful")
local capi = { screen = screen }

local get_current_screen = require("actionless.helpers").get_current_screen

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
  width = capi.screen[get_current_screen()].workarea.width,
  x = 0,
  y = capi.screen[get_current_screen()].workarea.height - 18
}

end
return menus
