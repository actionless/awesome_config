local awful_menu = require("awful.menu")
local awful_spawn = require("awful.spawn")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local beautiful = require("beautiful")
local awesome_menubar = require("menubar")

local menugen = require("actionless.util.menugen")
--local wlppr = require("actionless.wlppr")
local shutdown = require("actionless.util.shutdown")
local menu_addon = require("actionless.menu_addon")
local get_icon = require("actionless.util.xdg").get_icon


awful_menu.entry = menu_addon.menu_entry

local menus = {}

-- Menu
-- Create a laucher widget and a main menu
function menus.init(context)
  local term = awesome_menubar.utils.terminal .. " -e "

  local _cached_menu_content
  local function get_menu_content()
    if _cached_menu_content then
      return _cached_menu_content
    end
    local myawesomemenu = {
      { "Hotkeys", function()
          return false, hotkeys_popup.show_help
        end, get_icon('devices', 'keyboard')
      },
      { "Manual Page", term .. "man awesome",
        get_icon('actions', 'help-contents')
      },
      { "Edit Config", context.cmds.editor_cmd .. " " .. awesome.conffile,
        get_icon('actions', 'document-properties')
      },
      { "Reload", awesome.restart,
        get_icon('actions', 'view-refresh')
      },
      { "Quit (Hard Reload)", function()
          awesome.quit()
        end, get_icon('actions', 'application-exit')
      },
      { "Quit(2) (Toggle ARGB)", function()
          awesome.quit(2)
        end, get_icon('actions', 'format-text-italic')
      },
      { "Quit(3) (Openbox)", function()
          awesome.quit(3)
        end, get_icon('apps', 'openbox')
      },
      { "Quit(9) (to DM)", function()
          awesome.quit(9)
        end, get_icon('actions', 'window-close')
      },
    }

    local shutdown_menu = {
      { "Hibernate",
        "xscreensaver-command -lock ; sudo systemctl hibernate",
        get_icon("apps", "system-hibernate") },
      -- Without X Session Manager:
      { "Reboot", function()
          shutdown.kill_everybody(function()
            awful_spawn("reboot")
          end)
        end, get_icon('apps', 'system-restart')
      },
      { "Poweroff", function()
          shutdown.kill_everybody(function()
            awful_spawn("poweroff")
          end)
        end, get_icon('apps', 'system-shutdown')
      },
      { "Force Shutdown", shutdown.skip_kill,
        get_icon('actions', 'edit-redo')
      },
      { "Cancel Shutdown", shutdown.cancel_kill,
        get_icon('actions', 'edit-undo')
      },
      -- With X Session Manager:
      --{ "logout", session_logout, get_icon('actions', 'system-log-out') },
      --{ "reboot", session_reboot, get_icon('actions', 'view-refresh') },
      --{ "poweroff", session_poweroff, get_icon('actions', 'system-shutdown') },
    }

    local function app(display_name, name, icon_name, fallback_icon_name)
      name = name or display_name
      icon_name = icon_name or name
      return {
        display_name, name,
        awesome_menubar.utils.lookup_icon(icon_name) or (
          fallback_icon_name and awesome_menubar.utils.lookup_icon(fallback_icon_name)
        )
      }
    end

    local function category(display_name, content, icon_name, fallback_icon_name)
      return {
        display_name, content,
        get_icon('categories', 'applications-'..icon_name) or get_icon('categories', icon_name) or (
          fallback_icon_name and awesome_menubar.utils.lookup_icon(fallback_icon_name)
        )
      }
    end

    local applications_menu = {

      category("Audio", {
        app("AudioRelay", "audiorelay"),
        app("EasyEffects", "easyeffects"),
        app("qpwgraph", nil, "org.rncbc.qpwgraph.png"),
        app("ocenaudio"),
      }, "audio-recorder", "multimedia"),

      category("Development", {
        app("Git-Cola", "git-cola"),
        app("Meld", "meld"),
        app("PTIPython", term .. "ptipython", "ipython"),
      }, "development"),

      category("Graphics", {
        app("Drawing", "drawing", "com.github.maoschanz.drawing"),
        app("GIMP", "gimp"),
        app("Gpick", "gpick"),
        app("Nomacs", "nomacs"),
        app("Viewnior", "viewnior"),
      }, "graphics"),

      category("Markdown", {
        app("abricotine"),  -- best inline
        app("ghostwriter"),  -- good inline + preview
        app("marker", "marker", "com.github.fabiocolacio.marker"),  -- classic + preview (GTK)
        app("retext"),  -- classic + preview (Qt)
      }, "education-language"),

      category("Media players", {
        app("Clementine", "clementine"),
        app("Goodvibes", "goodvibes", "io.gitlab.Goodvibes"),
        app("MPV", "mpv"),
        --app("Shortwave", "shortwave", "de.haeckerfelix.Shortwave"), -- nice but buggy
      }, "audio-player", "multimedia"),

      category("Productivity", {
        app("Go For It!", "com.github.jmoerman.go-for-it"),
        --app("Endeavour (GNOME ToDo)", "endeavour"),
        app("QOwnNotes", "QOwnNotes"),
        --app("vnote", "vnote"),  -- replace to qOwnNotes or mindforger?
      }, "office"),

      category("Settings", {
        app("dconf Editor", "dconf-editor"),
      }, "system"),

      category("Terminals", {
        app("st", "st", 'terminal'),
        app("tmux in xst", "xst-tmux", 'terminator'),
        app("URxvt", "urxvt"),
        app("xst", "xst", 'terminal'),
        app("XTerm", "xterm"),
      }, "terminal", "terminal"),

      category("Text", {
        --app("Geany", "geany"),
        app("Oni2", "Oni2", "Onivim2"),
        app("xed", "xed", "accessories-text-editor"),
      }, "office"),

      category("Video Editing", {
        app("Flowblade", "flowblade"),
        app("Kdenlive", "kdenlive"),
        app("Shotcut", "shotcut"),
      }, "video", "multimedia-video-player"),

    }

    local menu_content = {
      {
        "Freedesktop loading...", nil,
        get_icon('status', 'image-loading')
      },
      {
        "Terminal", "bash -c 'xst-tmux || "..awesome_menubar.utils.terminal.."'",
        get_icon('apps', 'terminal')
      },
      --{ "kill compositor", "killall compton" },
      --{ "start compositor", context.cmds.compositor },
      --{
      --  "Wlppr",
      --  {{
      --    "save", wlppr.save,
      --    get_icon('actions', 'filesave')
      --  }, {
      --    "save to best", wlppr.save_best,
      --    get_icon('status', 'starred')
      --  }, {
      --    "dump", wlppr.dump,
      --    get_icon('status', 'user-trash-full')
      --  }},
      --  get_icon('apps', 'preferences-desktop-wallpaper')
      --},
      --{
      --  "Jack",
      --  {{
      --    "start", os.getenv("HOME").."/scripts/jack_start.sh",
      --    get_icon('devices', 'audio-speakers')
      --  }, {
      --    "stop", os.getenv("HOME").."/scripts/jack_stop.sh",
      --    get_icon('actions', 'stop')
      --  }},
      --  --get_icon('devices', 'audio-input-microphone')
      --  get_icon('apps', 'audio-player')
      --},
      { "Applications", applications_menu, get_icon('apps', 'menu-editor') },
      { "Shutdown", shutdown_menu, get_icon('apps', 'system-shutdown') },
      { "Awesome", myawesomemenu, beautiful.awesome_icon },
      --{ "mpv-xsel",
      --  function() awful_spawn.with_shell('mpv "$(xsel -b)"') end,
      --  get_icon('apps', 'mpv')
      --},
    }

    _cached_menu_content = menu_content
    return menu_content
  end


  function context.menu.mainmenu_show(nomouse)
    local function show_menu()
      local args = {}
      if nomouse then args.coords = {x=0,y=0} end
      context.menu.mainmenu:show(args)
    end
    if context.menu.mainmenu then
      show_menu()
    else
      context.menu.mainmenu = awful_menu({
        items = get_menu_content(),
      })
      show_menu()
      menugen.build_menu(function(menulist)
        context.menu.mainmenu:delete(1)
        context.menu.mainmenu:add(
          { "Freedesktop", menulist, get_icon('categories', 'applications-accessories') },
          1
        )
      end)
    end
  end


  function context.menu.mainmenu_toggle(nomouse)
    if context.menu.mainmenu and context.menu.mainmenu.wibox.visible then
      return context.menu.mainmenu:hide()
    else
      return context.menu.mainmenu_show(nomouse)
    end
  end

end

return menus
