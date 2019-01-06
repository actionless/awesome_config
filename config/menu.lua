local awful = require("awful")
local awesome_menubar = require("menubar")
local beautiful = require("beautiful")

local menugen = require("actionless.util.menugen")
local wlppr = require("actionless.wlppr")

local menus = {}

-- Menu
-- Create a laucher widget and a main menu
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
      { "ghostwriter", "ghostwriter" },
      { "retext", "retext" },
      { "vnote", "vnote" },
    }},
    { "Terminals", {
      { "XTerm", "xterm" },
      { "URxvt", "urxvt" },
      { "st", "st" },
      { "xst", "xst" },
    }},
  }

  local myawesomemenu = {
    { "manual", awesome_menubar.utils.terminal .. " -e man awesome" },
    { "edit config", context.cmds.editor_cmd .. " " .. awesome.conffile },
    { "restart", awesome.restart },
    { "quit", function() awesome.quit() end},
    { "quit2 (argb)", function() awesome.quit(2) end},
    { "quit3 (openbox)", function() awesome.quit(3) end},
    { "poweroff", "poweroff" },
  }

  local menu_content = {
    { "freedesktop loading...", nil, nil },
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
    { "open terminal", awesome_menubar.utils.terminal }
  }


  function context.menu.mainmenu_show(nomouse)
    local function show_menu()
      local args = {}
      if nomouse then args.coords = {x=0,y=0} end
      context.menu.mainmenu:show(args)
    end
    if not context.menu.mainmenu then
      context.menu.mainmenu = awful.menu({
        items =menu_content,
      })
      show_menu()
      menugen.build_menu(function(menulist)
        context.menu.mainmenu:delete(1)
        context.menu.mainmenu:add(
          {"freedesktop", menulist, beautiful.awesome_icon}, 1
        )
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

end

return menus
