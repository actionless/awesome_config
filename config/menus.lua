local awful = require("awful")
local awesome = awesome
--local menubar = require("menubar")
local menubar = require("actionless.menubar")
local beautiful = require("beautiful")
local capi = { screen = screen }

local get_current_screen = require("actionless.helpers").get_current_screen
local menugen = require("utils.menugen")

local menus = {}


function menus.init(context)

  local applications_menu = {
    { "Graphics", {
      { "Viewnior", "viewnior" },
      { "Nomacs",   "nomacs" },
      { "GIMP",     "gimp" },
    }},
    { "Multimedia", {
      { "Clementine", "clementine" },
      { "mpv", "mpv" },
    }},
    { "Text", {
      { "mEdit", "medit" },
      { "Geany", "geany" },
    }},
    { "terminal", "xterm" }
  }

  -- {{{ Menu
  -- Create a laucher widget and a main menu
  local myawesomemenu = {
    { "manual", context.cmds.terminal .. " -e man awesome" },
    { "edit config", context.cmds.editor_cmd .. " " .. awesome.conffile },
    { "restart", awesome.restart },
    { "quit", awesome.quit }
  }

  function context.menu.mainmenu_show()
    if not context.menu.mainmenu then
      context.menu.mainmenu = awful.menu({
        items = {
          { "freedesktop", menugen.build_menu(), beautiful.awesome_icon },
          { "awesome", myawesomemenu, beautiful.awesome_icon },
          { "applications", applications_menu, beautiful.applications_icon },
          { "kill compositor", "killall compton" },
          { "start compositor", context.cmds.compositor },
          { "open terminal", context.cmds.terminal }
        },
      })
    end
    context.menu.mainmenu:show()
  end
  function context.menu.mainmenu_toggle()
    if not context.menu.mainmenu then
      return context.menu.mainmenu_show()
    else
      return context.menu.mainmenu:toggle()
    end
  end
  -- }}}
  --

  menubar.utils.terminal = context.cmds.terminal
  -- Menubar configuration
  context.menu.menubar = menubar()
  context.menu.menubar.geometry = {
    height = beautiful.panel_height,
    width = capi.screen[get_current_screen()].workarea.width,
    x = 0,
    y = capi.screen[get_current_screen()].workarea.height - beautiful.panel_height
  }
  -- D-Menubar configuration
  context.menu.dmenubar = menubar()
  context.menu.dmenubar.cache_entries = false
  context.menu.dmenubar.menu_cache_path = awful.util.getdir("cache") .. "/history"
  context.menu.dmenubar.geometry = {
    height = beautiful.panel_height,
    width = capi.screen[get_current_screen()].workarea.width,
    x = 0,
    y = capi.screen[get_current_screen()].workarea.height - beautiful.panel_height
  }
  context.menu.dmenubar.menu_gen = require("actionless.menubar.dmenugen")
  -- }}}

end

return menus
