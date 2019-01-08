local awful = require("awful")
local awesome_menubar = require("menubar")
local beautiful = require("beautiful")

local menugen = require("actionless.util.menugen")
local wlppr = require("actionless.wlppr")

local menus = {}

local ICON_SIZE = 256

local function get_icon(category, name)
  return "/usr/share/icons/gnome/"..ICON_SIZE.."x"..ICON_SIZE.."/"..category.."/"..name..".png"
end

-- Menu
-- Create a laucher widget and a main menu
function menus.init(context)
  local term = awesome_menubar.utils.terminal .. " -e "

  local function kill_everybody()
    for si=1,screen.count() do
      local s = screen[si]
      for _, c in ipairs(s.all_clients) do
        c:kill()
      end
    end
  end

  local function logout()
    kill_everybody()
    --awful.spawn('mate-session-save --gui --logout-dialog')
    awful.spawn('qdbus --literal org.gnome.SessionManager /org/gnome/SessionManager org.gnome.SessionManager.Logout 1')
  end

  local function poweroff()
    kill_everybody()
    --awful.spawn('mate-session-save --gui --shutdown-dialog')
    awful.spawn('qdbus org.gnome.SessionManager /org/gnome/SessionManager org.gnome.SessionManager.RequestShutdown')
  end

  local function reboot()
    kill_everybody()
    --awful.spawn('mate-session-save --gui --shutdown-dialog')
    awful.spawn('qdbus org.gnome.SessionManager /org/gnome/SessionManager org.gnome.SessionManager.RequestReboot')
  end

  local myawesomemenu = {
    { "manual page", awesome_menubar.utils.terminal .. " -e man awesome" },
    { "edit config", context.cmds.editor_cmd .. " " .. awesome.conffile },
    { "reload", awesome.restart },
    { "quit", function() awesome.quit() end},
    { "quit2 (toggle argb)", function() awesome.quit(2) end},
    { "quit3 (openbox)", function() awesome.quit(3) end},
    { "logout", logout, get_icon('actions', 'system-log-out') },
    { "reboot", reboot, get_icon('actions', 'view-refresh') },
    { "poweroff", poweroff, get_icon('actions', 'system-shutdown') },
  }

  local applications_menu = {
    { "Development", {
      { "Meld", "meld" },
      { "PTIPython", term .. "ptipython" },
    }},
    { "Graphics", {
      { "Viewnior", "viewnior" },
      { "Nomacs",   "nomacs" },
      { "GIMP",     "gimp" },
    }},
    { "Multimedia", {
      { "Clementine", "clementine" },
      { "GRadio", "gradio" },
      { "mpv", "mpv" },
    }},
    { "Terminals", {
      { "XTerm", "xterm" },
      { "URxvt", "urxvt" },
      { "st", "st" },
      { "xst", "xst" },
    }},
    { "Text", {
      { "mEdit", "medit" },
      --{ "Geany", "geany" },
      { "ghostwriter", "ghostwriter" },  -- or retext?
      { "Oni", "oni" },
      { "retext", "retext" },
      --{ "vnote", "vnote" },  -- replace to mindforger?
    }},
  }

  local menu_content = {
    { "freedesktop loading...", nil, nil },
    { "open terminal", awesome_menubar.utils.terminal },
    --{ "kill compositor", "killall compton" },
    --{ "start compositor", context.cmds.compositor },
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
    { "awesome", myawesomemenu, beautiful.awesome_icon },
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
          { "freedesktop", menulist, get_icon('categories', 'gnome-applications') },
          1
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
