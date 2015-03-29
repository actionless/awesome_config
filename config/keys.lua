
local awful = require("awful")
local beautiful = require("beautiful")
local menubar = require("menubar")
local client = client
local capi = {
  screen = screen,
  client = client,
  root = root,
  awesome = awesome,
}

local helpers = require("actionless.helpers")
local titlebar = require("actionless.titlebar")
local menu_addon = require("actionless.menu_addon")
local floats = require("actionless.helpers").client_floats
local hk = require("actionless.hotkeys")


local revelation = require("third_party.revelation")
revelation.init()


local keys = {}
function keys.init(awesome_context)

local modkey = awesome_context.modkey
local altkey = awesome_context.altkey
local cmd = awesome_context.cmds

local RESIZE_STEP = 15

local TO_DEFINE_COLOR = "wip"

local TAG_COLOR = "tag"
local CLIENT_COLOR = "client_focus"
local UTILS = "menu"
local IMPORTANT_COLOR = "important"
local CLIENT_MANIPULATION = "client"
local LAYOUT_MANIPULATION = "layout"

hk.add_groups({
  [TAG_COLOR]={name="tags",color=beautiful.color["6"]},
  [CLIENT_COLOR]={name="client focus",color=beautiful.color["3"]},
  [UTILS]={name="utils",color=beautiful.color["5"]},
  [IMPORTANT_COLOR]={name="important",color=beautiful.color["9"]},
  [CLIENT_MANIPULATION]={name="client",color=beautiful.color["10"]},
  [LAYOUT_MANIPULATION]={name="layout",color=beautiful.color["12"]},
  [TO_DEFINE_COLOR]={name="wip",color=beautiful.color["7"]},
})


-- {{{ Mouse bindings
capi.root.buttons(awful.util.table.join(
  awful.button({ }, 3, function () awesome_context.menu.mainmenu:toggle() end),
  awful.button({ }, 5, awful.tag.viewnext),
  awful.button({ }, 4, awful.tag.viewprev)
))
-- }}}

awful.menu.menu_keys.back = { "Left", "h" }
awful.menu.menu_keys.down = { "Down", "j" }
awful.menu.menu_keys.up = { "Up", "k" }
awful.menu.menu_keys.enter = { "Right", "l" }
awful.menu.menu_keys.close = { "Escape", '#133', 'q' }


--local HELPKEY = "Print"
local HELPKEY = "#108"

-- {{{ Key bindings
local globalkeys = awful.util.table.join(

  hk.on({  }, HELPKEY, "show_help"),
  hk.on({ "Shift" }, HELPKEY, "show_help"),
  hk.on({ "Control" }, HELPKEY, "show_help"),
  hk.on({ altkey }, HELPKEY, "show_help"),
  hk.on({ modkey, }, HELPKEY, "show_help"),
  hk.on({ modkey, altkey }, HELPKEY, "show_help"),
  hk.on({ modkey, altkey, "Shift" }, HELPKEY, "show_help"),
  hk.on({ modkey, altkey, "Control" }, HELPKEY, "show_help"),
  hk.on({ modkey, "Shift"    }, HELPKEY, "show_help"),
  hk.on({ modkey, "Control"  }, HELPKEY, "show_help"),
  hk.on({ modkey, "Shift", "Control" }, HELPKEY, "show_help"),

  -- hk.on({ modkey,  }, "Control", "show_help"), -- show hotkey on hold

  hk.on({ modkey,  "Control"  }, "t",
    function() awesome_context.widgets.systray_toggle.toggle() end,
    "toggle sysTray popup", UTILS
  ),

  hk.on({ modkey,  "Control"  }, "s",
    function() helpers.run_once("xscreensaver-command -lock") end,
    "xscreensaver lock", UTILS
  ),

  hk.on({ modkey,        }, ",",
    function() awful.tag.viewprev(helpers.get_current_screen()) end,
    "prev tag", TAG_COLOR
  ),
  hk.on({ modkey,        }, ".",
    function() awful.tag.viewnext(helpers.get_current_screen()) end,
    "next tag", TAG_COLOR
  ),
  hk.on({ modkey,        }, "Escape",
    awful.tag.history.restore,
    "cycle tags", TAG_COLOR
  ),
  hk.on({ modkey, altkey }, "r",
    function ()
      local tag = awful.tag.selected(helpers.get_current_screen())
      if tag then
        awful.prompt.run(
          { prompt = "new tag name: ",
            text = awful.tag.getidx(tag) .. ":" },
          awesome_context.widgets.screen[helpers.get_current_screen()].promptbox.widget,
          function(new_name)
            if not new_name or #new_name == 0 then
              return
            else
               tag.name = new_name
            end
          end)
      end
    end,
    "Rename tag", TAG_COLOR
  ),

  -- By direction screen focus
  hk.on({ modkey,        }, "Next",
    function() awful.screen.focus_relative(1) end,
    "next screen", TAG_COLOR
  ),
  hk.on({ modkey,        }, "Prior",
    function() awful.screen.focus_relative(-1) end,
    "prev screen", TAG_COLOR
  ),

  -- By direction client focus
  hk.on({ modkey,        }, "Down",
    function()
      awful.client.focus.bydirection("down")
      if client.focus then client.focus:raise() end
    end,
    "client focus", CLIENT_COLOR
  ),
  hk.on({ modkey        }, "Up",
    function()
      awful.client.focus.bydirection("up")
      if client.focus then client.focus:raise() end
    end,
    "client focus", CLIENT_COLOR
  ),
  hk.on({ modkey        }, "Left",
    function()
      awful.client.focus.bydirection("left")
      if client.focus then client.focus:raise() end
    end,
    "client focus", CLIENT_COLOR
  ),
  hk.on({ modkey        }, "Right",
    function()
      awful.client.focus.bydirection("right")
      if client.focus then client.focus:raise() end
    end,
    "client focus", CLIENT_COLOR
  ),


  -- By direction client focus (VIM style)
  hk.on({ modkey }, "j",
    function()
      awful.client.focus.bydirection("down")
      if client.focus then client.focus:raise() end
    end,
    "client focus", CLIENT_COLOR
  ),
  hk.on({ modkey }, "k",
    function()
      awful.client.focus.bydirection("up")
      if client.focus then client.focus:raise() end
    end,
    "client focus", CLIENT_COLOR
  ),
  hk.on({ modkey }, "h",
    function()
      awful.client.focus.bydirection("left")
      if client.focus then client.focus:raise() end
    end,
    "client focus", CLIENT_COLOR
  ),
  hk.on({ modkey }, "l",
    function()
      awful.client.focus.bydirection("right")
      if client.focus then client.focus:raise() end
    end,
    "client focus", CLIENT_COLOR
  ),


  -- Menus
  hk.on({ modkey,       }, "w",
    function () awesome_context.menu.mainmenu_show() end,
    "aWesome menu", UTILS
  ),
  hk.on({ modkey,       }, "i",
    function ()
      awesome_context.menu.instance = menu_addon.clients_on_tag({
        theme = {width=capi.screen[helpers.get_current_screen()].workarea.width},
        coords = {x=0, y=18}
      })
    end,
    "clients on current tag menu", UTILS
  ),
  hk.on({ modkey,       }, "p",
    function ()
      awesome_context.menu.instance = awful.menu.clients({
        theme = {width=capi.screen[helpers.get_current_screen()].workarea.width},
        coords = {x=0, y=18}
      })
    end,
    "all clients menu", UTILS
  ),
  hk.on({ modkey, "Control"}, "p",
    function() menubar.show() end,
    "applications menu", UTILS
  ),
  hk.on({ modkey,        }, "space",
    function() awful.util.spawn_with_shell(cmd.dmenu) end,
    "app launcher", UTILS
  ),

  hk.on({ modkey, "Control"  }, "n",
    function()
      local c = awful.client.restore()
      -- @TODO: it's a workaround for some strange upstream issue
      if c then client.focus = c end
    end,
    "de-iconify client", TAG_COLOR
  ),

  hk.on({ modkey,        }, "u",
    awful.client.urgent.jumpto,
    "jump to Urgent client", IMPORTANT_COLOR
  ),
  hk.on({ modkey,        }, "Tab",
    function ()
      awful.client.focus.history.previous()
      if client.focus then
        client.focus:raise()
      end
    end,
    "cycle clients", CLIENT_COLOR
  ),

  hk.on({ modkey, altkey }, "space",
    function () awful.layout.inc(1) end,
    "next layout", LAYOUT_MANIPULATION
  ),
  hk.on({ modkey, "Control" }, "space",
    function () awful.layout.inc(-1) end,
    "prev layout", LAYOUT_MANIPULATION
  ),

  -- Layout tuning
  hk.on({ modkey, altkey }, "Down",
    function ()
      awful.tag.incnmaster(-1)
    end,
    "master-", LAYOUT_MANIPULATION
  ),
  hk.on({ modkey, altkey }, "Up",
    function () awful.tag.incnmaster( 1) end,
    "master+", LAYOUT_MANIPULATION
  ),
  hk.on({ modkey, altkey }, "Left",
    function () awful.tag.incncol(-1) end,
    "columns-", LAYOUT_MANIPULATION
  ),
  hk.on({ modkey, altkey }, "Right",
    function () awful.tag.incncol( 1) end,
    "columns+", LAYOUT_MANIPULATION
  ),

  -- Layout tuning (VIM style)
  hk.on({ modkey, altkey }, "j",
    function () awful.tag.incnmaster(-1) end,
    "master-", LAYOUT_MANIPULATION
  ),
  hk.on({ modkey, altkey }, "k",
    function () awful.tag.incnmaster( 1) end,
    "master+", LAYOUT_MANIPULATION
  ),
  hk.on({ modkey, altkey }, "h",
    function () awful.tag.incncol(-1) end,
    "columns-", LAYOUT_MANIPULATION
  ),
  hk.on({ modkey, altkey }, "l",
    function () awful.tag.incncol( 1) end,
    "columns+", LAYOUT_MANIPULATION
  ),


  -- Prompt
  hk.on({ modkey }, "r",
    function () awesome_context.widgets.screen[helpers.get_current_screen()].promptbox:run() end,
    "Run command...", UTILS
  ),
  hk.on({ modkey }, "x",
    function ()
      awful.prompt.run({ prompt = "Run Lua code: " },
      awesome_context.widgets.screen[helpers.get_current_screen()].promptbox.widget,
      awful.util.eval, nil,
      awful.util.getdir("cache") .. "/history_eval")
    end,
    "eXecute lua code...", UTILS
  ),

  -- ALSA volume control
  awful.key({}, "#123", function ()
    if awesome_context.volume_widget ~= "apw" then
      awesome_context.widgets.volume.up()
    else
      awesome_context.widgets.volume.Up()
    end
  end),
  awful.key({}, "#122", function ()
    if awesome_context.volume_widget ~= "apw" then
      awesome_context.widgets.volume.down()
    else
      awesome_context.widgets.volume.Down()
    end
  end),
  awful.key({}, "#121", function ()
    if awesome_context.volume_widget ~= "apw" then
      awesome_context.widgets.volume.toggle()
    else
      awesome_context.widgets.volume.ToggleMute()
    end
  end),
  awful.key({}, "#198", function () awesome_context.widgets.volume.toggle_mic() end),

  -- Music player control
  hk.on({modkey, altkey}, ",",
    function () awesome_context.widgets.music.prev_song() end,
    "prev song", UTILS),
  hk.on({modkey, altkey}, ".",
    function () awesome_context.widgets.music.next_song() end,
    "next song", UTILS),
  hk.on({modkey, altkey}, "/",
    function () awesome_context.widgets.music.toggle() end,
    "Pause", UTILS),

  awful.key({}, "#150", function () awesome_context.widgets.music.prev_song() end),
  awful.key({}, "#148", function () awesome_context.widgets.music.next_song() end),
  awful.key({}, "#172", function () awesome_context.widgets.music.toggle() end),

  hk.on({ modkey }, "c",
    function () os.execute("xsel -p -o | xsel -i -b") end,
    "copy to clipboard", UTILS
  ),

  -- Standard program
  hk.on({ modkey,        }, "Return",
    function () awful.util.spawn(cmd.tmux) end,
    "terminal", IMPORTANT_COLOR
  ),
  hk.on({ modkey, altkey }, "Return",
    function () awful.util.spawn(cmd.tmux_light) end,
    "terminal", IMPORTANT_COLOR
  ),
  hk.on({ modkey,        }, "s",
    function () awful.util.spawn(cmd.file_manager) end,
    "file manager", UTILS
  ),

  hk.on({ modkey, "Control"  }, "r",
    capi.awesome.restart,
    "Reload awesome wm", IMPORTANT_COLOR
  ),
  hk.on({ modkey, "Control"    }, "q",
    capi.awesome.quit,
    "Quit awesome wm", IMPORTANT_COLOR
  ),

  -- Scrot stuff
  hk.on({ "Control"      }, "Print",
    function ()
      awful.util.spawn_with_shell(
      "scrot -ub '%Y-%m-%d--%s_$wx$h_scrot.png' -e " .. cmd.scrot_preview_cmd)
    end,
    "screenshot focused", TO_DEFINE_COLOR
  ),
  hk.on({ altkey        }, "Print",
    function ()
      awful.util.spawn_with_shell(
      "scrot -s '%Y-%m-%d--%s_$wx$h_scrot.png' -e " .. cmd.scrot_preview_cmd)
    end,
    "screenshot selected", TO_DEFINE_COLOR
  ),
  hk.on({  }, "Print",
    function ()
      awful.util.spawn_with_shell(
      "scrot '%Y-%m-%d--%s_$wx$h_scrot.png' -e " .. cmd.scrot_preview_cmd)
    end,
    "screenshot all", TO_DEFINE_COLOR
  ),

  hk.on({modkey}, "a",
    revelation,
    "Revelation", UTILS
  )

)

awesome_context.clientkeys = awful.util.table.join(

  -- By direction client swap/move
  hk.on({ modkey,  "Shift"    }, "Down",
    function (c)
      if floats(c) then
        local g = c:geometry()
        g.y = g.y + RESIZE_STEP
        c:geometry(g)
      else
        awful.client.swap.bydirection("down")
        if client.swap then client.swap:raise() end
      end
    end,
    "client swap", CLIENT_MANIPULATION
  ),
  hk.on({ modkey,  "Shift"    }, "Up",
    function (c)
      if floats(c) then
        local g = c:geometry()
        g.y = g.y - RESIZE_STEP
        c:geometry(g)
      else
        awful.client.swap.bydirection("up")
        if client.swap then client.swap:raise() end
      end
    end,
    "client swap", CLIENT_MANIPULATION
  ),
  hk.on({ modkey,  "Shift"    }, "Left",
    function (c)
      if floats(c) then
        local g = c:geometry()
        g.x = g.x - RESIZE_STEP
        c:geometry(g)
      else
        awful.client.swap.bydirection("left")
        if client.swap then client.swap:raise() end
      end
    end,
    "client swap", CLIENT_MANIPULATION
  ),
  hk.on({ modkey,  "Shift"    }, "Right",
    function (c)
      if floats(c) then
        local g = c:geometry()
        g.x = g.x + RESIZE_STEP
        c:geometry(g)
      else
        awful.client.swap.bydirection("right")
        if client.swap then client.swap:raise() end
      end
    end,
    "client swap", CLIENT_MANIPULATION
  ),

  -- By direction client swap (VIM style)
  hk.on({ modkey, "Shift" }, "j",
    function (c)
      if floats(c) then
        local g = c:geometry()
        g.y = g.y + RESIZE_STEP
        c:geometry(g)
      else
        awful.client.swap.bydirection("down")
        if client.swap then client.swap:raise() end
      end
    end,
    "client swap", CLIENT_MANIPULATION
  ),
  hk.on({ modkey, "Shift" }, "k",
    function (c)
      if floats(c) then
        local g = c:geometry()
        g.y = g.y - RESIZE_STEP
        c:geometry(g)
      else
        awful.client.swap.bydirection("up")
        if client.swap then client.swap:raise() end
      end
    end,
    "client swap", CLIENT_MANIPULATION
  ),
  hk.on({ modkey, "Shift" }, "h",
    function (c)
      if floats(c) then
        local g = c:geometry()
        g.x = g.x - RESIZE_STEP
        c:geometry(g)
      else
        awful.client.swap.bydirection("left")
        if client.swap then client.swap:raise() end
      end
    end,
    "client swap", CLIENT_MANIPULATION
  ),
  hk.on({ modkey, "Shift" }, "l",
    function (c)
      if floats(c) then
        local g = c:geometry()
        g.x = g.x + RESIZE_STEP
        c:geometry(g)
      else
        awful.client.swap.bydirection("right")
        if client.swap then client.swap:raise() end
      end
    end,
    "client swap", CLIENT_MANIPULATION
  ),

  -- Client resize
  hk.on({ modkey, "Control"  }, "Right",
    function (c)
      if floats(c) then
        local g = c:geometry()
        g.width = g.width + RESIZE_STEP
        c:geometry(g)
      else
        awful.tag.incmwfact( 0.05)
      end
    end,
    "master size+", LAYOUT_MANIPULATION
  ),
  hk.on({ modkey,  "Control"  }, "Left",
    function (c)
      if floats(c) then
        local g = c:geometry()
        g.width = g.width - RESIZE_STEP
        c:geometry(g)
      else
        awful.tag.incmwfact(-0.05)
      end
    end,
    "master size-", LAYOUT_MANIPULATION
  ),
  hk.on({ modkey, "Control"  }, "Down",
    function (c)
      if floats(c) then
        local g = c:geometry()
        g.height = g.height + RESIZE_STEP
        c:geometry(g)
      else
        awful.client.incwfact(-0.05)
      end
    end,
    "column size-", LAYOUT_MANIPULATION
  ),
  hk.on({ modkey, "Control"  }, "Up",
    function (c)
      if floats(c) then
        local g = c:geometry()
        g.height = g.height - RESIZE_STEP
        c:geometry(g)
      else
        awful.client.incwfact( 0.05)
      end
    end,
    "column size+", LAYOUT_MANIPULATION
  ),

  -- Client resize (VIM style)
  hk.on({ modkey, "Control" }, "l",
    function (c)
      if floats(c) then
        local g = c:geometry()
        g.width = g.width + RESIZE_STEP
        c:geometry(g)
      else
        awful.tag.incmwfact( 0.05)
      end
    end,
    "master size+", LAYOUT_MANIPULATION
  ),
  hk.on({ modkey,  "Control" }, "h",
    function (c)
      if floats(c) then
        local g = c:geometry()
        g.width = g.width - RESIZE_STEP
        c:geometry(g)
      else
        awful.tag.incmwfact(-0.05)
      end
    end,
    "master size-", LAYOUT_MANIPULATION
  ),
  hk.on({ modkey, "Control" }, "j",
    function (c)
      if floats(c) then
        local g = c:geometry()
        g.height = g.height + RESIZE_STEP
        c:geometry(g)
      else
        awful.client.incwfact(-0.05)
      end
    end,
    "column size-", LAYOUT_MANIPULATION
  ),

  hk.on({ modkey, "Control" }, "k",
    function (c)
      if floats(c) then
        local g = c:geometry()
        g.height = g.height - RESIZE_STEP
        c:geometry(g)
      else
        awful.client.incwfact( 0.05)
      end
    end,
    "column size+", LAYOUT_MANIPULATION
  ),


  hk.on({ modkey,        }, "f",
    function (c) c.fullscreen = not c.fullscreen end,
    "toggle client Fullscreen", CLIENT_MANIPULATION
  ),
  hk.on({ modkey,        }, "q",
    function (c) c:kill() end,
    "Quit app", IMPORTANT_COLOR
  ),
  hk.on({ modkey, "Shift"  }, "f",
    awful.client.floating.toggle,
    "toggle client Float", CLIENT_MANIPULATION
  ),
  hk.on({ modkey, "Shift"  }, "Return",
    function (c) c:swap(awful.client.getmaster()) end,
    "put client on master", CLIENT_MANIPULATION
  ),
  hk.on({ modkey,        }, "o",
    awful.client.movetoscreen,
    "move client to Other screen", CLIENT_MANIPULATION
  ),
  hk.on({ modkey,        }, "t",
    function (c) c.ontop = not c.ontop end,
    "toggle client on Top", CLIENT_MANIPULATION
  ),
  hk.on({ modkey, "Shift"    }, "t",
    function(c)
      titlebar.titlebar_toggle(c)
      --awful.titlebar.toggle(
      --  c, beautiful.titlebar_position or 'top')
    end,
    "toggle Titlebar", CLIENT_MANIPULATION
  ),
  hk.on({ modkey,        }, "n",
    function (c) c.minimized = true end,
    "icoNify client", CLIENT_MANIPULATION
  ),
  hk.on({ modkey,        }, "m",
    function (c)
      c.maximized_horizontal = not c.maximized_horizontal
      c.maximized_vertical   = not c.maximized_vertical
    end,
    "Maximize client", CLIENT_MANIPULATION
  )
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
    hk.on({ modkey }, "#" .. i + diff,
      function ()
        local tag = awful.tag.gettags(scr)[i]
        if tag then awful.tag.viewonly(tag) end
      end,
      i==1 and "go to tag " .. i .. "\n(screen #" .. scr .. ")" or "",
      TAG_COLOR
    ),
    hk.on({ modkey, "Control" }, "#" .. i + diff,
      function ()
        local tag = awful.tag.gettags(scr)[i]
        if tag then awful.tag.viewtoggle(tag) end
      end,
      i==1 and "toggle tag " .. i .. "\n(screen #" .. scr .. ")" or "",
      TAG_COLOR
    ),
    hk.on({ modkey, "Shift" }, "#" .. i + diff,
      function ()
        if client.focus then
          local tag = awful.tag.gettags(scr)[i]
          if tag then awful.client.movetotag(tag) end
         end
      end,
      i==1 and "move client to tag " .. i .. "\n(screen #" .. scr .. ")" or "",
      CLIENT_MANIPULATION
    ),
    hk.on({ modkey, "Control", "Shift" }, "#" .. i + diff,
      function ()
        if client.focus then
          local tag = awful.tag.gettags(scr)[i]
          if tag then awful.client.toggletag(tag) end
        end

      end,
      i==1 and "toggle client to tag " .. i .. "\n(screen #" .. scr .. ")" or "",
      CLIENT_MANIPULATION
    )
  )
  end
end

-- Set keys
capi.root.keys(globalkeys)
-- }}}


end
return keys
