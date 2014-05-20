local awful = require("awful")
local capi = { screen = screen }
local menubar = require("menubar")

local helpers	= require("actionless.helpers")
local beautiful	= helpers.beautiful

local menus = {}


function menus.init()

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
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
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
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
