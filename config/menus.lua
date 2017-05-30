local awful = require("awful")
local awesome = awesome
--local menubar = require("menubar")
local menubar = require("actionless.menubar")
local beautiful = require("beautiful")
local capi = { screen = screen }

local menugen = require("utils.menugen")
local wlppr = require("actionless.wlppr")

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
    { "quit", function() awesome.quit() end},
    { "quit2 (argb)", function() awesome.quit(2) end},
    { "quit3 (openbox)", function() awesome.quit(3) end},
    { "poweroff", "poweroff" },
  }

  function context.menu.mainmenu_show(nomouse)
    local function show_menu()
      local args = {}
      if nomouse then args.coords = {x=0,y=0} end
      context.menu.mainmenu:show(args)
    end
    if not context.menu.mainmenu then
      menugen.build_menu(function(menulist)
        context.menu.mainmenu = awful.menu({
          items = {
            { "wlppr",
              {{
                "save", wlppr.save,
                beautiful.widget_ac_charging_low
              }, {
                "save to best", wlppr.save_best,
                beautiful.widget_ac_charging
              }, {
                "dump", wlppr.dump,
                beautiful.widget_music_stop
              }},
              beautiful.widget_hdd
            },
            { "freedesktop", menulist, beautiful.awesome_icon },
            { "awesome", myawesomemenu, beautiful.awesome_icon },
            { "jack",
              {{
                "start", os.getenv("HOME").."/scripts/jack_start.sh",
                beautiful.widget_music_pause
              }, {
                "stop", os.getenv("HOME").."/scripts/jack_stop.sh",
                beautiful.widget_music_stop
              }},
              beautiful.widget_vol
            },
            { "applications", applications_menu, beautiful.applications_icon },
            --{ "kill compositor", "killall compton" },
            --{ "start compositor", context.cmds.compositor },
            { "open terminal", context.cmds.terminal }
          },
        })
        show_menu()
      end)
    else
      show_menu()
    end
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
  menubar.geometry = {
    height = beautiful.panel_height,
    width = capi.screen[awful.screen.focused()].workarea.width,
    x = 0,
    y = capi.screen[awful.screen.focused()].workarea.height - beautiful.panel_height
  }
  -- Menubar configuration
  context.menu.menubar = menubar.create()
  -- D-Menubar configuration
  context.menu.dmenubar = menubar.create({
    term_prefix = context.cmds.tmux_run,
  })
  context.menu.dmenubar.cache_entries = false
  context.menu.dmenubar.menu_cache_path = awful.util.getdir("cache") .. "/history"
  context.menu.dmenubar.menu_gen = require("actionless.menubar.dmenugen")
  -- }}}

end

return menus
