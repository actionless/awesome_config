local awful_menu = require("awful.menu")
local awful_spawn = require("awful.spawn")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local awesome_menubar = require("menubar")
local beautiful = require("beautiful")
local gfs = require("gears.filesystem")


local menugen = require("actionless.util.menugen")
local wlppr = require("actionless.wlppr")


local ICON_SIZES = {
  ['256x256']='png',
  ['128x128']='png',
  ['scalable']='svg',
  ['32x32']='png',
}
local ICON_THEMES = {
  beautiful.icon_theme,
  'gnome',
}


local menus = {}


local function get_icon(category, name)
  for _, icon_theme_name in ipairs(ICON_THEMES) do
    for _, icon_root in ipairs({
      os.getenv('HOME') .. '/.icons/',
      '/usr/share/icons/',
    }) do
      for icon_size, extension in pairs(ICON_SIZES) do
        for _, path in ipairs({
          icon_root .. icon_theme_name .. "/" .. icon_size .. "/" .. category .. "/" .. name .. "." .. extension,
          icon_root .. icon_theme_name .. "/" .. category .. "/" .. icon_size .. "/" .. name .. "." .. extension,
        }) do
          if gfs.file_readable(path) then
            return path
          end
        end
      end
    end
  end
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
    --awful_spawn('mate-session-save --gui --logout-dialog')
    awful_spawn('qdbus --literal org.gnome.SessionManager /org/gnome/SessionManager org.gnome.SessionManager.Logout 1')
  end

  local function poweroff()
    kill_everybody()
    --awful_spawn('mate-session-save --gui --shutdown-dialog')
    awful_spawn('qdbus org.gnome.SessionManager /org/gnome/SessionManager org.gnome.SessionManager.RequestShutdown')
  end

  local function reboot()
    kill_everybody()
    --awful_spawn('mate-session-save --gui --shutdown-dialog')
    awful_spawn('qdbus org.gnome.SessionManager /org/gnome/SessionManager org.gnome.SessionManager.RequestReboot')
  end


  local myawesomemenu = {
    { "hotkeys", function() return false, hotkeys_popup.show_help end},
    { "manual page", awesome_menubar.utils.terminal .. " -e man awesome" },
    { "edit config", context.cmds.editor_cmd .. " " .. awesome.conffile },
    { "reload", awesome.restart },

    -- Without X Session Manager:
    --{ "quit", function() awesome.quit() end},
    --{ "quit2 (toggle argb)", function() awesome.quit(2) end},
    --{ "quit3 (openbox)", function() awesome.quit(3) end},

    -- With X Session Manager:
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
      { "GIMP",     "gimp" },
      { "Nomacs",   "nomacs" },
      { "Viewnior", "viewnior" },
    }},
    { "Multimedia", {
      { "Clementine", "clementine" },
      { "GRadio", "gradio" },
      { "mpv", "mpv" },
    }},
    { "Settings", {
      { "dconf Editor", "dconf-editor" },
    }},
    { "Terminals", {
      { "st", "st" },
      { "tmux in xst", "xst-tmux" },
      { "URxvt", "urxvt" },
      { "xst", "xst" },
      { "XTerm", "xterm" },
    }},
    { "Text", {
      --{ "Geany", "geany" },
      { "ghostwriter", "ghostwriter" },  -- or retext?
      { "mEdit", "medit" },
      { "Oni", "oni" },
      { "retext", "retext" },
      --{ "vnote", "vnote" },  -- replace to mindforger?
    }},
  }

  local menu_content = {
    {
      "freedesktop loading...", nil,
      get_icon('status', 'image-loading')
    },
    {
      "open terminal", awesome_menubar.utils.terminal,
      get_icon('apps', 'terminal')
    },
    --{ "kill compositor", "killall compton" },
    --{ "start compositor", context.cmds.compositor },
    {
      "wlppr",
      {{
        "save", wlppr.save,
        get_icon('actions', 'filesave')
      }, {
        "save to best", wlppr.save_best,
        get_icon('status', 'starred')
      }, {
        "dump", wlppr.dump,
        get_icon('status', 'trashcan_full')
      }},
      get_icon('apps', 'wallpaper')
    },
    {
      "jack",
      {{
        "start", os.getenv("HOME").."/scripts/jack_start.sh",
        get_icon('status', 'audio-volume-high')
      }, {
        "stop", os.getenv("HOME").."/scripts/jack_stop.sh",
        get_icon('actions', 'stop')
      }},
      --get_icon('devices', 'audio-input-microphone')
      get_icon('apps', 'audio-player')
    },
    { "applications", applications_menu, get_icon('apps', 'menu-editor') },
    { "awesome", myawesomemenu, beautiful.awesome_icon },
  }


  function context.menu.mainmenu_show(nomouse)
    local function show_menu()
      local args = {}
      if nomouse then args.coords = {x=0,y=0} end
      context.menu.mainmenu:show(args)
    end
    if not context.menu.mainmenu then
      context.menu.mainmenu = awful_menu({
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
