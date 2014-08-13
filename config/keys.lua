
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

  hk.key({ modkey,             }, "/", "show_help"),
  hk.key({ modkey,  altkey     }, "/", "show_help"),
  hk.key({ modkey,  "Shift"    }, "/", "show_help"),
  hk.key({ modkey,  "Control"  }, "/", "show_help"),

  hk.key({ modkey,  "Control"  }, "t",
    function() status.widgets.systray_toggle.toggle() end, nil,
    "Toggle systray popup"
  ),

  hk.key({ modkey,  "Control"  }, "s",
    function() helpers.run_once("xscreensaver-command -lock") end, nil,
    "Xscreensaver lock"
  ),

  hk.key({ modkey,        }, ",",
    function() awful.tag.viewprev(helpers.get_current_screen()) end, nil,
    "Prev tag"
  ),
  hk.key({ modkey,        }, ".",
    function() awful.tag.viewnext(helpers.get_current_screen()) end, nil,
    "Next tag"
  ),
  hk.key({ modkey,        }, "Escape",
    awful.tag.history.restore, nil,
    "Cycle tag"
  ),

  -- By direction screen focus
  hk.key({ modkey,        }, "Next",
    function() awful.screen.focus_relative(1) end, nil,
    "Next screen"
  ),
  hk.key({ modkey,        }, "Prior",
    function() awful.screen.focus_relative(-1) end, nil,
    "Prev screen"
  ),

  -- By direction client focus
  hk.key({ modkey,        }, "Down",
    function()
      awful.client.focus.bydirection("down")
      if client.focus then client.focus:raise() end
    end, nil,
    "client focus"
  ),
  hk.key({ modkey        }, "Up",
    function()
      awful.client.focus.bydirection("up")
      if client.focus then client.focus:raise() end
    end, nil,
    "client focus"
  ),
  hk.key({ modkey        }, "Left",
    function()
      awful.client.focus.bydirection("left")
      if client.focus then client.focus:raise() end
    end, nil,
    "client focus"
  ),
  hk.key({ modkey        }, "Right",
    function()
      awful.client.focus.bydirection("right")
      if client.focus then client.focus:raise() end
    end, nil,
    "client focus"
  ),

  -- By direction client swap
  hk.key({ modkey,  "Shift"    }, "Down",
    function()
      awful.client.swap.bydirection("down")
      if client.swap then client.swap:raise() end
    end, nil,
    "client swap"
  ),
  hk.key({ modkey,  "Shift"    }, "Up",
    function()
      awful.client.swap.bydirection("up")
      if client.swap then client.swap:raise() end
    end, nil,
    "client swap"
  ),
  hk.key({ modkey,  "Shift"    }, "Left",
    function()
      awful.client.swap.bydirection("left")
      if client.swap then client.swap:raise() end
    end, nil,
    "client swap"
  ),
  hk.key({ modkey,  "Shift"    }, "Right",
    function()
      awful.client.swap.bydirection("right")
      if client.swap then client.swap:raise() end
    end, nil,
    "client swap"
  ),

  -- Client resize
  hk.key({ modkey, "Control"  }, "Right",  
    function () awful.tag.incmwfact( 0.05) end, nil,
    "client resize"
  ),
  hk.key({ modkey,  "Control"  }, "Left",
    function () awful.tag.incmwfact(-0.05) end, nil,
    "client resize"
  ),
  hk.key({ modkey, "Control"  }, "Down",
    function () awful.client.incwfact(-0.05) end, nil,
    "client resize"
  ),
  hk.key({ modkey, "Control"  }, "Up",
    function () awful.client.incwfact( 0.05) end, nil,
    "client resize"
  ),

  -- Layout tuning
  awful.key({ modkey, altkey }, "Down",
    function () awful.tag.incnmaster(-1) end),
  awful.key({ modkey, altkey }, "Up",
    function () awful.tag.incnmaster( 1) end),
  awful.key({ modkey, altkey }, "Left",
    function () awful.tag.incncol(-1) end),
  awful.key({ modkey, altkey }, "Right",
    function () awful.tag.incncol( 1) end),

  -- By direction client focus (VIM style)
  awful.key({ modkey }, "j",
    function()
      awful.client.focus.bydirection("down")
      if client.focus then client.focus:raise() end
    end),
  awful.key({ modkey }, "k",
    function()
      awful.client.focus.bydirection("up")
      if client.focus then client.focus:raise() end
    end),
  awful.key({ modkey }, "h",
    function()
      awful.client.focus.bydirection("left")
      if client.focus then client.focus:raise() end
    end),
  awful.key({ modkey }, "l",
    function()
      awful.client.focus.bydirection("right")
      if client.focus then client.focus:raise() end
    end),

  -- By direction client swap (VIM style)
  awful.key({ modkey, "Shift" }, "j",
    function()
      awful.client.swap.bydirection("down")
      if client.swap then client.swap:raise() end
    end),
  awful.key({ modkey, "Shift" }, "k",
    function()
      awful.client.swap.bydirection("up")
      if client.swap then client.swap:raise() end
    end),
  awful.key({ modkey, "Shift" }, "h",
    function()
      awful.client.swap.bydirection("left")
      if client.swap then client.swap:raise() end
    end),
  awful.key({ modkey, "Shift" }, "l",
    function()
      awful.client.swap.bydirection("right")
      if client.swap then client.swap:raise() end
    end),

  -- Client resize (VIM style)
  awful.key({ modkey, "Control" }, "l",
    function () awful.tag.incmwfact( 0.05) end),
  awful.key({ modkey,  "Control" }, "h",
    function () awful.tag.incmwfact(-0.05) end),
  awful.key({ modkey, "Control" }, "j",
    function () awful.client.incwfact(-0.05) end),
  awful.key({ modkey, "Control" }, "k",
    function () awful.client.incwfact( 0.05) end),

  -- Layout tuning (VIM style)
  awful.key({ modkey, altkey }, "j",
    function () awful.tag.incnmaster(-1) end),
  awful.key({ modkey, altkey }, "k",
    function () awful.tag.incnmaster( 1) end),
  awful.key({ modkey, altkey }, "h",
    function () awful.tag.incncol(-1) end),
  awful.key({ modkey, altkey }, "l",
    function () awful.tag.incncol( 1) end),


  -- Menus
  awful.key({ modkey,       }, "w",
          function () status.menu.mainmenu:show() end),
  awful.key({ modkey,       }, "i",
          function ()
            status.menu.instance = menu_addon.clients_on_tag({
              theme = {width=capi.screen[helpers.get_current_screen()].workarea.width},
              coords = {x=0, y=18}})
          end),
  awful.key({ modkey,       }, "p",
          function ()
            local log = require('naughty').notify
            log({text="DEBUG"})
            status.menu.instance = awful.menu.clients({
              theme = {width=capi.screen[helpers.get_current_screen()].workarea.width},
              coords = {x=0, y=18}})
          end),
  awful.key({ modkey, "Control"}, "p",
    function() menubar.show() end),
  --awful.key({ modkey,        }, "space",
  --  function() menubar.show() end),
  awful.key({ modkey,        }, "space",
    function() awful.util.spawn_with_shell(cmd.dmenu) end),

  -- Layout manipulation
  awful.key({ modkey, "Control"  }, "n",
          function()
    c=awful.client.restore()
                if c then
                  -- @TODO:
                  -- it's a workaround for some strange upstream issue
                  client.focus = c
                end
          end),

  awful.key({ modkey,        }, "u",
    awful.client.urgent.jumpto),
  awful.key({ modkey,        }, "Tab",
    function ()
      awful.client.focus.history.previous()
      if client.focus then
        client.focus:raise()
      end
    end),

  awful.key({ altkey,        }, "space",
    function () awful.layout.inc(status.layouts, 1) end),
  awful.key({ altkey, "Shift"    }, "space",
    function () awful.layout.inc(status.layouts, -1) end),


  -- Prompt
  awful.key({ modkey }, "r",
    function () status.widgets.uniq[helpers.get_current_screen()].promptbox:run() end),
  awful.key({ modkey }, "x",
    function ()
      awful.prompt.run({ prompt = "Run Lua code: " },
      status.widgets.promptbox[helpers.get_current_screen()].widget,
      awful.util.eval, nil,
      awful.util.getdir("cache") .. "/history_eval")
    end),

  -- ALSA volume control
  awful.key({}, "#123", function () status.widgets.volume.up() end),
  awful.key({}, "#122", function () status.widgets.volume.down() end),
  awful.key({}, "#121", function () status.widgets.volume.toggle() end),
  awful.key({}, "#198", function () status.widgets.volume.toggle_mic() end),

  -- MPD control
  awful.key({}, "#150", function () status.widgets.music.prev_song() end),
  awful.key({}, "#148", function () status.widgets.music.next_song() end),
  awful.key({}, "#172", function () status.widgets.music.toggle() end),

  -- Copy to clipboard
  awful.key({ modkey }, "c",
    function () os.execute("xsel -p -o | xsel -i -b") end),

  -- Standard program
  awful.key({ modkey,        }, "Return",
    function () awful.util.spawn(cmd.tmux) end),
  awful.key({ modkey,        }, "s",
    function () awful.util.spawn(cmd.file_manager) end),
  awful.key({ modkey, "Control"  }, "c",
    function () awful.util.spawn_with_shell(cmd.chromium) end),
  awful.key({ modkey, "Control"  }, "g",
    function () awful.util.spawn_with_shell(cmd.chrome) end),
  awful.key({ modkey, "Control"  }, "f",
    function () awful.util.spawn_with_shell(cmd.firefox) end),

  awful.key({ modkey, "Control"  }, "r",
    awesome.restart),
  awful.key({ modkey, "Shift"    }, "q",
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
for screen = 1, 2 do
  for i = 1, 12 do

  if screen == 1 then
    -- num keys:
    diff = 9
  elseif screen == 2 then
    -- f-keys:
    if i>10 then
      diff = 84
    else
      diff = 66
    end
  end

  globalkeys = awful.util.table.join(globalkeys,
    -- View tag only.
    awful.key({ modkey }, "#" .. i + diff,
      function ()
        local tag = awful.tag.gettags(screen)[i]
        if tag then awful.tag.viewonly(tag) end
        end),
    -- Toggle tag.
    awful.key({ modkey, "Control" }, "#" .. i + diff,
      function ()
        local tag = awful.tag.gettags(screen)[i]
        if tag then awful.tag.viewtoggle(tag) end
      end),
    -- Move client to tag.
    awful.key({ modkey, "Shift" }, "#" .. i + diff,
      function ()
        if client.focus then
          local tag = awful.tag.gettags(screen)[i]
          if tag then awful.client.movetotag(tag) end
         end
      end),
    -- Toggle tag.
    awful.key({ modkey, "Control", "Shift" }, "#" .. i + diff,
      function ()
        if client.focus then
          local tag = awful.tag.gettags(screen)[i]
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
