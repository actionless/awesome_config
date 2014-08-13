
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local menubar = require("menubar")
local capi = { screen = screen }
local client = client
local root = root
local awesome = awesome

local widgets = require("actionless.widgets")
local helpers = require("actionless.helpers")
local titlebar = require("actionless.titlebar")
local menu_addon = require("actionless.menu_addon")
local hk = require("actionless.hotkeys")


local keys = {}


function keys.init(status)

hk.init(status)

local modkey = status.modkey
local altkey = status.altkey

local cmd = status.cmds

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
  awful.button({ }, 3, function () status.menu.mainmenu:toggle() end),
  awful.button({ }, 5, awful.tag.viewnext),
  awful.button({ }, 4, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
local globalkeys = awful.util.table.join(

  hk.on({ modkey,             }, "/", "show_help"),
  hk.on({ modkey,  altkey     }, "/", "show_help"),
  hk.on({ modkey,  "Shift"    }, "/", "show_help"),
  hk.on({ modkey,  "Control"  }, "/", "show_help"),

  hk.on({ modkey,  "Control"  }, "t",
    function() status.widgets.systray_toggle.toggle() end,
    "toggle systray popup"
  ),

  hk.on({ modkey,  "Control"  }, "s",
    function() helpers.run_once("xscreensaver-command -lock") end,
    "Xscreensaver lock"
  ),

  hk.on({ modkey,        }, ",",
    function() awful.tag.viewprev(helpers.get_current_screen()) end,
    "prev tag"
  ),
  hk.on({ modkey,        }, ".",
    function() awful.tag.viewnext(helpers.get_current_screen()) end,
    "next tag"
  ),
  hk.on({ modkey,        }, "Escape",
    awful.tag.history.restore,
    "cycle tags"
  ),

  -- By direction screen focus
  hk.on({ modkey,        }, "Next",
    function() awful.screen.focus_relative(1) end,
    "next screen"
  ),
  hk.on({ modkey,        }, "Prior",
    function() awful.screen.focus_relative(-1) end,
    "prev screen"
  ),

  -- By direction client focus
  hk.on({ modkey,        }, "Down",
    function()
      awful.client.focus.bydirection("down")
      if client.focus then client.focus:raise() end
    end,
    "client focus"
  ),
  hk.on({ modkey        }, "Up",
    function()
      awful.client.focus.bydirection("up")
      if client.focus then client.focus:raise() end
    end,
    "client focus"
  ),
  hk.on({ modkey        }, "Left",
    function()
      awful.client.focus.bydirection("left")
      if client.focus then client.focus:raise() end
    end,
    "client focus"
  ),
  hk.on({ modkey        }, "Right",
    function()
      awful.client.focus.bydirection("right")
      if client.focus then client.focus:raise() end
    end,
    "client focus"
  ),

  -- By direction client swap
  hk.on({ modkey,  "Shift"    }, "Down",
    function()
      awful.client.swap.bydirection("down")
      if client.swap then client.swap:raise() end
    end,
    "client swap"
  ),
  hk.on({ modkey,  "Shift"    }, "Up",
    function()
      awful.client.swap.bydirection("up")
      if client.swap then client.swap:raise() end
    end,
    "client swap"
  ),
  hk.on({ modkey,  "Shift"    }, "Left",
    function()
      awful.client.swap.bydirection("left")
      if client.swap then client.swap:raise() end
    end,
    "client swap"
  ),
  hk.on({ modkey,  "Shift"    }, "Right",
    function()
      awful.client.swap.bydirection("right")
      if client.swap then client.swap:raise() end
    end,
    "client swap"
  ),

  -- Client resize
  hk.on({ modkey, "Control"  }, "Right",  
    function () awful.tag.incmwfact( 0.05) end,
    "master size+"
  ),
  hk.on({ modkey,  "Control"  }, "Left",
    function () awful.tag.incmwfact(-0.05) end,
    "master size-"
  ),
  hk.on({ modkey, "Control"  }, "Down",
    function () awful.client.incwfact(-0.05) end,
    "column size-"
  ),
  hk.on({ modkey, "Control"  }, "Up",
    function () awful.client.incwfact( 0.05) end,
    "column size+"
  ),

  -- Layout tuning
  hk.on({ modkey, altkey }, "Down",
    function () awful.tag.incnmaster(-1) end,
    "master-"
  ),
  hk.on({ modkey, altkey }, "Up",
    function () awful.tag.incnmaster( 1) end,
    "master+"
  ),
  hk.on({ modkey, altkey }, "Left",
    function () awful.tag.incncol(-1) end,
    "columns-"
  ),
  hk.on({ modkey, altkey }, "Right",
    function () awful.tag.incncol( 1) end,
    "columns+"
  ),

  -- By direction client focus (VIM style)
  hk.on({ modkey }, "j",
    function()
      awful.client.focus.bydirection("down")
      if client.focus then client.focus:raise() end
    end,
    "client focus"
  ),
  hk.on({ modkey }, "k",
    function()
      awful.client.focus.bydirection("up")
      if client.focus then client.focus:raise() end
    end,
    "client focus"
  ),
  hk.on({ modkey }, "h",
    function()
      awful.client.focus.bydirection("left")
      if client.focus then client.focus:raise() end
    end,
    "client focus"
  ),
  hk.on({ modkey }, "l",
    function()
      awful.client.focus.bydirection("right")
      if client.focus then client.focus:raise() end
    end,
    "client focus"
  ),

  -- By direction client swap (VIM style)
  hk.on({ modkey, "Shift" }, "j",
    function()
      awful.client.swap.bydirection("down")
      if client.swap then client.swap:raise() end
    end,
    "client swap"
  ),
  hk.on({ modkey, "Shift" }, "k",
    function()
      awful.client.swap.bydirection("up")
      if client.swap then client.swap:raise() end
    end,
    "client swap"
  ),
  hk.on({ modkey, "Shift" }, "h",
    function()
      awful.client.swap.bydirection("left")
      if client.swap then client.swap:raise() end
    end,
    "client swap"
  ),
  hk.on({ modkey, "Shift" }, "l",
    function()
      awful.client.swap.bydirection("right")
      if client.swap then client.swap:raise() end
    end,
    "client swap"
  ),

  -- Client resize (VIM style)
  hk.on({ modkey, "Control" }, "l",
    function () awful.tag.incmwfact( 0.05) end,
    "master size+"
  ),
  hk.on({ modkey,  "Control" }, "h",
    function () awful.tag.incmwfact(-0.05) end,
    "master size-"
  ),
  hk.on({ modkey, "Control" }, "j",
    function () awful.client.incwfact(-0.05) end,
    "column size-"
  ),
  hk.on({ modkey, "Control" }, "k",
    function () awful.client.incwfact( 0.05) end,
    "column size+"
  ),

  -- Layout tuning (VIM style)
  hk.on({ modkey, altkey }, "j",
    function () awful.tag.incnmaster(-1) end,
    "master-"
  ),
  hk.on({ modkey, altkey }, "k",
    function () awful.tag.incnmaster( 1) end,
    "master+"
  ),
  hk.on({ modkey, altkey }, "h",
    function () awful.tag.incncol(-1) end,
    "columns-"
  ),
  hk.on({ modkey, altkey }, "l",
    function () awful.tag.incncol( 1) end,
    "columns+"
  ),


  -- Menus
  hk.on({ modkey,       }, "w",
    function () status.menu.mainmenu:show() end,
    "awesome menu"
  ),
  hk.on({ modkey,       }, "i",
    function ()
      status.menu.instance = menu_addon.clients_on_tag({
        theme = {width=capi.screen[helpers.get_current_screen()].workarea.width},
        coords = {x=0, y=18}})
    end,
    "current clients"
  ),
  hk.on({ modkey,       }, "p",
    function ()
      local log = require('naughty').notify
      log({text="DEBUG"})
      status.menu.instance = awful.menu.clients({
        theme = {width=capi.screen[helpers.get_current_screen()].workarea.width},
        coords = {x=0, y=18}})
    end,
    "all clients"
  ),
  hk.on({ modkey, "Control"}, "p",
    function() menubar.show() end,
    "applications menu"
  ),
  hk.on({ modkey,        }, "space",
    function() awful.util.spawn_with_shell(cmd.dmenu) end,
    "app launcher"
  ),

  -- Layout manipulation
  hk.on({ modkey, "Control"  }, "n",
    function()
      c=awful.client.restore()
      if c then
        -- @TODO: it's a workaround for some strange upstream issue
        client.focus = c
      end
    end,
    "de-iconify"  
  ),

  hk.on({ modkey,        }, "u",
    awful.client.urgent.jumpto,
    "jumo to urgent"
  ),
  hk.on({ modkey,        }, "Tab",
    function ()
      awful.client.focus.history.previous()
      if client.focus then
        client.focus:raise()
      end
    end,
    "cycle clients"  
  ),

  hk.on({ altkey,        }, "space",
    function () awful.layout.inc(status.layouts, 1) end,
    "next layout"
  ),
  hk.on({ altkey, "Shift"    }, "space",
    function () awful.layout.inc(status.layouts, -1) end,
    "prev layout"
  ),


  -- Prompt
  hk.on({ modkey }, "r",
    function () status.widgets.uniq[helpers.get_current_screen()].promptbox:run() end,
    "execute command..."
  ),
  hk.on({ modkey }, "x",
    function ()
      awful.prompt.run({ prompt = "Run Lua code: " },
      status.widgets.promptbox[helpers.get_current_screen()].widget,
      awful.util.eval, nil,
      awful.util.getdir("cache") .. "/history_eval")
    end,
    "evaluate lua..."
  ),

  -- ALSA volume control
  awful.key({}, "#123", function () status.widgets.volume.up() end),
  awful.key({}, "#122", function () status.widgets.volume.down() end),
  awful.key({}, "#121", function () status.widgets.volume.toggle() end),
  awful.key({}, "#198", function () status.widgets.volume.toggle_mic() end),

  -- MPD control
  awful.key({}, "#150", function () status.widgets.music.prev_song() end),
  awful.key({}, "#148", function () status.widgets.music.next_song() end),
  awful.key({}, "#172", function () status.widgets.music.toggle() end),

  hk.on({ modkey }, "c",
    function () os.execute("xsel -p -o | xsel -i -b") end,
    "copy to clipboard"
  ),

  -- Standard program
  hk.on({ modkey,        }, "Return",
    function () awful.util.spawn(cmd.tmux) end,
    "terminal"
  ),
  hk.on({ modkey,        }, "s",
    function () awful.util.spawn(cmd.file_manager) end),
  hk.on({ modkey, "Control"  }, "c",
    function () awful.util.spawn_with_shell(cmd.chromium) end),
  hk.on({ modkey, "Control"  }, "g",
    function () awful.util.spawn_with_shell(cmd.chrome) end),
  hk.on({ modkey, "Control"  }, "f",
    function () awful.util.spawn_with_shell(cmd.firefox) end),

  hk.on({ modkey, "Control"  }, "r",
    awesome.restart),
  hk.on({ modkey, "Shift"    }, "q",
    awesome.quit),

  -- Scrot stuff
  awful.key({ "Control"      }, "Print", 
    function ()
      awful.util.spawn_with_shell(
      "scrot -ub '%Y-%m-%d--%s_$wx$h_scrot.png' -e " .. cmd.scrot_preview_cmd)
    end),
  awful.key({ altkey        }, "Print",
    function ()
      awful.util.spawn_with_shell(
      "scrot -s '%Y-%m-%d--%s_$wx$h_scrot.png' -e " .. cmd.scrot_preview_cmd)
    end),
  awful.key({            }, "Print",
    function ()
      awful.util.spawn_with_shell(
      "scrot '%Y-%m-%d--%s_$wx$h_scrot.png' -e " .. cmd.scrot_preview_cmd)
    end)

)

status.clientkeys = awful.util.table.join(
  awful.key({ modkey,        }, "f",
    function (c) c.fullscreen = not c.fullscreen end),
  awful.key({ modkey,        }, "q",
    function (c) c:kill() end),
  awful.key({ modkey, "Control"  }, "space",
    awful.client.floating.toggle),
  awful.key({ modkey, "Control"  }, "Return",
    function (c) c:swap(awful.client.getmaster()) end),
  awful.key({ modkey,        }, "o",
    awful.client.movetoscreen),
  awful.key({ modkey,        }, "t",
    function (c) c.ontop = not c.ontop end),
  awful.key({ modkey, "Shift"    }, "t",
    function(c)
                  titlebar.titlebar_toggle(c)
                  --awful.titlebar.toggle(
                  --  c, beautiful.titlebar_position or 'top')
                end),
  awful.key({ modkey,        }, "n",
    function (c) c.minimized = true end),
  awful.key({ modkey,        }, "m",
    function (c)
      c.maximized_horizontal = not c.maximized_horizontal
      c.maximized_vertical   = not c.maximized_vertical
    end)
)

local diff = nil
for scr = 1, 2 do
  for i = 1, 12 do

  if scr == 1 then
    -- num keys:
    diff = 9
  elseif scr == 2 then
    -- f-keys:
    if i>10 then
      diff = 84
    else
      diff = 66
    end
  end

  globalkeys = awful.util.table.join(globalkeys,
    -- View tag only.
    hk.on({ modkey }, "#" .. i + diff,
      function ()
        local tag = awful.tag.gettags(scr)[i]
        if tag then awful.tag.viewonly(tag) end
      end,
      "go to tag " .. i .. " (screen #" .. scr .. ")"
    ),
    -- Toggle tag.
    awful.key({ modkey, "Control" }, "#" .. i + diff,
      function ()
        local tag = awful.tag.gettags(scr)[i]
        if tag then awful.tag.viewtoggle(tag) end
      end),
    -- Move client to tag.
    awful.key({ modkey, "Shift" }, "#" .. i + diff,
      function ()
        if client.focus then
          local tag = awful.tag.gettags(scr)[i]
          if tag then awful.client.movetotag(tag) end
         end
      end),
    -- Toggle tag.
    awful.key({ modkey, "Control", "Shift" }, "#" .. i + diff,
      function ()
        if client.focus then
          local tag = awful.tag.gettags(scr)[i]
          if tag then awful.client.toggletag(tag) end
        end
      end))
  end
end

status.clientbuttons = awful.util.table.join(
    awful.button({ }, 1,
      function (c)
        client.focus = c;
        c:raise();
      end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}


end
return keys
