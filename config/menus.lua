local awful = require("awful")
local capi = { screen = screen }
local menubar = require("menubar")
local beautiful = require("beautiful")

local menus = {}


function menus.init(status)

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", status.cmds.terminal .. " -e man awesome" },
   { "edit config", status.cmds.editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({items = {
    { "awesome", myawesomemenu, beautiful.awesome_icon },
    { "kill compositor", "killall compton" },
    { "start compositor", compositor },
    { "open terminal", terminal }
}})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                   menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = status.cmds.terminal
-- }}}


menubar.geometry = {
   height = 18,
   width = capi.screen[1].workarea.width,
   x = 0,
   y = capi.screen[1].workarea.height - 18
}

--require("freedesktop/freedesktop")


end
return menus
