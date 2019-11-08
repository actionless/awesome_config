local awful_menu = require("awful.menu")
local awful_spawn = require("awful.spawn")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local awesome_menubar = require("menubar")
local beautiful = require("beautiful")
local gfs = require("gears.filesystem")


local menugen = require("actionless.util.menugen")
local wlppr = require("actionless.wlppr")


local ICON_SIZES = {
  'scalable',
  '256x256',
  '128x128',
  '64x64',
  '32x32',
  '24x24',
  '22x22',
  'symbolic',
}
local FORMATS = {
  '.svg', '.png', '-symbolic.svg',
}
local ICON_THEMES = {
  beautiful.icon_theme,
  'gnome',
  'Adwaita',
  'hicolor',
  --'locolor',
}


local menus = {}


local function get_icon(category, name)
  if category == 'apps' or category == 'categories' then
    local awesome_found = awesome_menubar.utils.lookup_icon(name)
    if awesome_found then return awesome_found end
  end
  for _, icon_theme_name in ipairs(ICON_THEMES) do
    for _, icon_root in ipairs({
      os.getenv('HOME') .. '/.icons/',
      '/usr/share/icons/',
    }) do
      for _, icon_size in ipairs(ICON_SIZES) do
        for _, extension in ipairs(FORMATS) do
          for _, path in ipairs({
            icon_root .. icon_theme_name .. "/" .. icon_size .. "/" .. category .. "/" .. name .. extension,
            icon_root .. icon_theme_name .. "/" .. category .. "/" .. icon_size .. "/" .. name .. extension,
          }) do
            if gfs.file_readable(path) then
              --log("R:"..path)
              return path
            end
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
    { "manual page", term .. "man awesome" },
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

  local function app(display_name, name, icon_name)
    name = name or display_name
    icon_name = icon_name or name
    return { display_name, name, awesome_menubar.utils.lookup_icon(icon_name) }
  end

  local function category(display_name, content, icon_name)
    return { display_name, content, get_icon('categories', 'applications-'..icon_name) }
  end

  local applications_menu = {

    category("Development", {
      app("Meld", "meld"),
      app("PTIPython", term .. "ptipython", "ipython"),
    }, "development"),

    category("Graphics", {
      app("gcolor3", "gcolor3", "nl.hjdskes.gcolor3"),
      app("GIMP", "gimp"),
      app("Nomacs", "nomacs"),
      app("Viewnior", "viewnior"),
    }, "graphics"),

    category("Multimedia", {
      app("Clementine", "clementine"),
      app("GRadio", "gradio"),
      app("mpv", "mpv"),
    }, "multimedia"),

    category("Productivity", {
      app("Go For It!", "com.github.jmoerman.go-for-it"),
      --app("GNOME To Do", "gnome-todo"),
      app("QOwnNotes", "QOwnNotes"),
      --app("vnote", "vnote"),  -- replace to qOwnNotes or mindforger?
    }, "office"),

    category("Settings", {
      app("dconf Editor", "dconf-editor"),
    }, "system"),

    {"Terminals", {
      app("st", "st", 'terminal'),
      app("tmux in xst", "xst-tmux", 'terminator'),
      app("URxvt", "urxvt"),
      app("xst", "xst", 'terminal'),
      app("XTerm", "xterm"),
    }, get_icon("apps", "terminal")},

    category("Text", {
      --app("Geany", "geany"),
      app("ghostwriter", "ghostwriter"),  -- or retext?
      app("Oni", "oni"),
      app("retext", "retext"),
      app("xed", "xed", "accessories-text-editor"),
      app("marker", "marker", "com.github.fabiocolacio.marker"),
    }, "education-language"),

  }

  local menu_content = {
    {
      "freedesktop loading...", nil,
      get_icon('status', 'image-loading')
    },
    {
      "open terminal", "bash -c 'xst-tmux || "..awesome_menubar.utils.terminal.."'",
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
        get_icon('status', 'user-trash-full')
      }},
      get_icon('apps', 'preferences-desktop-wallpaper')
    },
    {
      "jack",
      {{
        "start", os.getenv("HOME").."/scripts/jack_start.sh",
        get_icon('devices', 'audio-speakers')
      }, {
        "stop", os.getenv("HOME").."/scripts/jack_stop.sh",
        get_icon('actions', 'stop')
      }},
      --get_icon('devices', 'audio-input-microphone')
      get_icon('apps', 'audio-player')
    },
    { "applications", applications_menu, get_icon('apps', 'menu-editor') },
    { "awesome", myawesomemenu, beautiful.awesome_icon },
    { "mpv-xsel",
      function() awful_spawn.with_shell('mpv "$(xsel -b)"') end,
      get_icon('apps', 'mpv')
    },
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
          { "freedesktop", menulist, get_icon('categories', 'applications-accessories') },
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
