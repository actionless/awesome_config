local awful = require("awful")
local beautiful = require("beautiful")
local hkng = require("awful.hotkeys_popup")
local client = client
local capi = {
  screen = screen,
  client = client,
  root = root,
  awesome = awesome,
}
local awesome_menubar = require("menubar")

local tag_helpers = require("actionless.util.tag")
local run_once = require("actionless.util.spawn").run_once
local menu_addon = require("actionless.menu_addon")
local persistent = require("actionless.persistent")
local tmux_swap_bydirection = require("actionless.util.tmux").swap_bydirection
local wlppr = require("actionless.wlppr")


local keys = {}
function keys.init(awesome_context)


  local modkey = awesome_context.modkey
  local altkey = awesome_context.altkey

  local shell_commands = awesome_context.cmds

  local revelation = require("third_party.revelation")
  revelation.fg = beautiful.revelation_fg
  revelation.border_color = beautiful.revelation_border_color
  revelation.bg = beautiful.revelation_bg
  revelation.font = beautiful.revelation_font
  revelation.init()


  -- {{{ Client mouse bindings
  awful.layout.suit.floating.resize_jump_to_corner = false
  awful.layout.suit.tile.resize_jump_to_corner = false

  awesome_context.clientbuttons = awful.util.table.join(
    awful.button({ }, 1,
      function (c)
        if c.focusable then
          client.focus = c;
          c:raise();
        end
      end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, function(c)
      awful.mouse.resize(c, nil, {jump_to_corner=false})
    end),
    awful.button({ modkey, "Control" }, 1, function(c)
      awful.mouse.resize(c, nil, {jump_to_corner=false})
    end)
  )
  -- }}}


  -- {{{ Root mouse bindings
  capi.root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () awesome_context.menu.mainmenu_toggle() end),
    awful.button({ }, 4, function()
      tag_helpers.view_noempty(-1)
    end),
    awful.button({ }, 5, function()
      tag_helpers.view_noempty(1)
    end)
  ))
  -- }}}


  -- {{{ Menu keybindings
  awful.menu.menu_keys.back = { "Left", "h" }
  awful.menu.menu_keys.down = { "Down", "j" }
  awful.menu.menu_keys.up = { "Up", "k" }
  awful.menu.menu_keys.enter = { "Right", "l" }
  awful.menu.menu_keys.close = { "Escape", '#133', 'q' }
  -- }}}


  -- {{{ Hotkeys group names
  local TAG_COLOR = "tag"
  local CLIENT_FOCUS = "client: focus"
  local CLIENT_MOVE = "client: move"
  local UTILS = "menu"
  local AWESOME_COLOR = "awesome"
  local CLIENT_MANIPULATION = "client"
  local LAYOUT_MANIPULATION = "layout"
  local LCARS = "LCARS"
  local LAUNCHER = "launcher"
  local MUSIC = "music"
  local PROGRAMS = "programs"
  local SCREENSHOT = "screenshot"
  -- }}}

  local bind_key = function(mod, key, press, description, group)
    return awful.key.new(mod, key, press, nil, {description=description, group=group})
  end


  -- {{{ Root keybindings
  local globalkeys = awful.util.table.join(

    awful.key({modkey}, "/", function()
      hkng.show_help()
    end, nil, {
      description = "show help", group=AWESOME_COLOR
    }),

    -- bind_key({ modkey,  }, "Control", "show_help"), -- show hotkey on hold
    bind_key({ modkey,  "Control"  }, "w",
      function() wlppr.cycle() end,
      "cycle", "wallpaper"
    ),
    bind_key({ modkey,  "Control" }, "b",
      function() wlppr.cycle_best() end,
      "cycle best", "wallpaper"
    ),
    bind_key({ modkey,  "Control" }, "y",
      function() wlppr.save() end,
      "save", "wallpaper"
    ),
    bind_key({ modkey,  "Control" }, "o",
      function() wlppr.open() end,
      "open in viewer", "wallpaper"
    ),
    bind_key({ modkey,  }, "'",
      function() wlppr.cycle() end,
      "cycle (TMP)", "wallpaper"
    ),

    bind_key({ modkey,  altkey  }, "t",
      function() awesome_context.widgets.systray_toggle.toggle() end,
      "toggle systray popup", AWESOME_COLOR
    ),

    bind_key({ modkey,  "Control"  }, "s",
      function() run_once("xscreensaver-command -lock") end,
      "xscreensaver lock", AWESOME_COLOR
    ),
    bind_key({ modkey,  "Control"  }, "d",
      function() awful.spawn.with_shell("sleep 1 && xset dpms force off") end,
      "turn off display", AWESOME_COLOR
    ),
    bind_key({ modkey,  }, "o",
      function() awful.spawn.with_shell(os.getenv('HOME').."/.screenlayout/cycle.sh") end,
      "rotate display", AWESOME_COLOR
    ),


    bind_key({ modkey,        }, ",",
      function()
        tag_helpers.view_noempty(-1)
      end,
      "prev tag", TAG_COLOR
    ),
    bind_key({ modkey,        }, ".",
      function()
        tag_helpers.view_noempty(1)
      end,
      "next tag", TAG_COLOR
    ),
    bind_key({ modkey,        }, "Escape",
      awful.tag.history.restore,
      "cycle tags", TAG_COLOR
    ),
    bind_key({ modkey, altkey }, "r",
      function ()
        local s = awful.screen.focused()
        local tag = s.selected_tag
        if not tag then return end
        local tag_id = tag.index
        awful.prompt.run(
          { prompt = "new tag name: ",
            text = tag_id .. ":" ,
            textbox = awesome_context.widgets.screen[s.index].promptbox.widget,
            exe_callback = function(new_name)
              if not new_name or #new_name == 0 then return end
              tag.name = new_name
            end
          })
      end,
      "Rename tag", TAG_COLOR
    ),

    -- By direction screen focus
    bind_key({ modkey,        }, "Next",
      function() awful.screen.focus_relative(1) end,
      "next screen", TAG_COLOR
    ),
    bind_key({ modkey,        }, "Prior",
      function() awful.screen.focus_relative(-1) end,
      "prev screen", TAG_COLOR
    ),

    -- By direction client focus
    bind_key({ modkey,        }, "Down",
      function()
        awful.client.focus.global_bydirection("down")
        if client.focus then client.focus:raise() end
      end,
      "client focus", CLIENT_FOCUS
    ),
    bind_key({ modkey        }, "Up",
      function()
        awful.client.focus.global_bydirection("up")
        if client.focus then client.focus:raise() end
      end,
      "client focus", CLIENT_FOCUS
    ),
    bind_key({ modkey        }, "Left",
      function()
        awful.client.focus.global_bydirection("left")
        if client.focus then client.focus:raise() end
      end,
      "client focus", CLIENT_FOCUS
    ),
    bind_key({ modkey        }, "Right",
      function()
        awful.client.focus.global_bydirection("right")
        if client.focus then client.focus:raise() end
      end,
      "client focus", CLIENT_FOCUS
    ),


    bind_key({ modkey }, "j",
      function()
        awful.client.focus.global_bydirection("down")
        if client.focus then client.focus:raise() end
      end,
      "client focus (vim style)", CLIENT_FOCUS
    ),
    bind_key({ modkey }, "k",
      function()
        awful.client.focus.global_bydirection("up")
        if client.focus then client.focus:raise() end
      end,
      "client focus (vim style)", CLIENT_FOCUS
    ),
    bind_key({ modkey }, "h",
      function()
        awful.client.focus.global_bydirection("left")
        if client.focus then client.focus:raise() end
      end,
      "client focus (vim style)", CLIENT_FOCUS
    ),
    bind_key({ modkey }, "l",
      function()
        awful.client.focus.global_bydirection("right")
        if client.focus then client.focus:raise() end
      end,
      "client focus (vim style)", CLIENT_FOCUS
    ),


    -- Menus
    bind_key({ modkey,       }, "w",
      function () awesome_context.menu.mainmenu_show(true) end,
      "aWesome menu", UTILS
    ),
    bind_key({ modkey,       }, "i",
      function ()
        awesome_context.menu.instance = menu_addon.clients_on_tag({
          theme = {width=capi.screen[awful.screen.focused()].workarea.width},
          coords = {x=0, y=18}
        })
      end,
      "clients on current tag menu", UTILS
    ),
    bind_key({ modkey,       }, "p",
      function ()
        awesome_context.menu.instance = awful.menu.clients({
          theme = {width=capi.screen[awful.screen.focused()].workarea.width},
          coords = {x=0, y=18}
        })
      end,
      "all clients menu", UTILS
    ),
    bind_key({ modkey, "Control"}, "p",
      --function() awesome_context.menu.menubar:show() end,
      function() awesome_menubar.show() end,
      "applications menu", LAUNCHER
    ),
    bind_key({ modkey,        }, "space",
      --function() awful.spawn.with_shell(shell_commands.dmenu) end,
      function() awesome_context.menu.dmenubar:show() end,
      "app launcher", LAUNCHER
    ),

    bind_key({ modkey, "Control"  }, "n",
      function()
        local c = awful.client.restore()
        if c then client.focus = c end
      end,
      "de-iconify client", CLIENT_MANIPULATION
    ),

    bind_key({ modkey,        }, "u",
      awful.client.urgent.jumpto,
      "jump to urgent client", CLIENT_FOCUS
    ),
    bind_key({ modkey,        }, "Tab",
      function ()
        awful.client.focus.history.previous()
        if client.focus then
          client.focus:raise()
        end
      end,
      "cycle clients", CLIENT_FOCUS
    ),

    bind_key({ modkey, altkey }, "space",
      function ()
        local s = awful.screen.focused().index
        awesome_context.widgets.screen[s].layoutbox.menu:toggle({coords={
          y=0, x=capi.screen[s].geometry.width - beautiful.menu_width
        }})
        --awful.layout.inc(1)
      end,
      "choose layout", LAYOUT_MANIPULATION
    ),
    --bind_key({ modkey, "Control" }, "space",
      --function () awful.layout.inc(-1) end,
      --"prev layout", LAYOUT_MANIPULATION
    --),

    -- Layout tuning
    bind_key({ modkey, altkey }, "Down",
      function ()
        awful.tag.incnmaster(-1)
      end,
      "master-", LAYOUT_MANIPULATION
    ),
    bind_key({ modkey, altkey }, "Up",
      function () awful.tag.incnmaster( 1) end,
      "master+", LAYOUT_MANIPULATION
    ),
    bind_key({ modkey, altkey }, "Left",
      function () awful.tag.incncol(-1) end,
      "columns-", LAYOUT_MANIPULATION
    ),
    bind_key({ modkey, altkey }, "Right",
      function () awful.tag.incncol( 1) end,
      "columns+", LAYOUT_MANIPULATION
    ),

    -- Layout tuning (VIM style)
    bind_key({ modkey, altkey }, "j",
      function () awful.tag.incnmaster(-1) end,
      "master-", LAYOUT_MANIPULATION
    ),
    bind_key({ modkey, altkey }, "k",
      function () awful.tag.incnmaster( 1) end,
      "master+", LAYOUT_MANIPULATION
    ),
    bind_key({ modkey, altkey }, "h",
      function () awful.tag.incncol(-1) end,
      "columns-", LAYOUT_MANIPULATION
    ),
    bind_key({ modkey, altkey }, "l",
      function () awful.tag.incncol( 1) end,
      "columns+", LAYOUT_MANIPULATION
    ),

    bind_key({ modkey, altkey }, "e",
      function ()
        tag_helpers.togglemfpol()
      end,
      "toggle expand master", LAYOUT_MANIPULATION
    ),
    bind_key({ modkey, altkey }, "g",
      function ()
        tag_helpers.toggle_gap()
      end,
      "toggle useless gap", LAYOUT_MANIPULATION
    ),

    -- Prompt
    bind_key({ modkey }, "r",
      function ()
        awesome_context.widgets.screen[awful.screen.focused().index].promptbox:run()
      end,
      "run command", LAUNCHER
    ),
    bind_key({ modkey }, "x",
      function ()
        awful.prompt.run {
          prompt       = "Run Lua code: ",
          textbox = awesome_context.widgets.screen[awful.screen.focused().index].promptbox.widget,
          exe_callback = awful.util.eval,
          history_path = awful.util.get_cache_dir() .. "/history_eval"
        }
      end,
      "execute lua code", LAUNCHER
    ),

    -- ALSA volume control
    awful.key({}, "#123", function ()
        awesome_context.widgets.volume.Up()
    end),
    awful.key({}, "#122", function ()
        awesome_context.widgets.volume.Down()
    end),
    awful.key({}, "#121", function ()
        awesome_context.widgets.volume.ToggleMute()
    end),
    awful.key({}, "#78", function ()  -- scroll lock
        awesome_context.widgets.volume.ToggleMute()
          if awesome_context.widgets.volume.pulse.Mute then
            awful.spawn.spawn('xset led named "Scroll Lock"')
          else
            awful.spawn.spawn('xset -led named "Scroll Lock"')
          end
    end),
    awful.key({}, "#198", function () awesome_context.widgets.volume.toggle_mic() end),

    -- Music player control
    bind_key({modkey, altkey}, ",",
      function () awesome_context.widgets.music.prev_song() end,
      "prev song", MUSIC),
    bind_key({modkey, altkey}, ".",
      function () awesome_context.widgets.music.next_song() end,
      "next song", MUSIC),
    bind_key({modkey, altkey}, "/",
      function () awesome_context.widgets.music.toggle() end,
      "Pause", MUSIC),

    awful.key({}, "#150", function () awesome_context.widgets.music.prev_song() end),
    awful.key({}, "#148", function () awesome_context.widgets.music.next_song() end),
    -- lenovo keyboard
    awful.key({}, "#173", function () awesome_context.widgets.music.prev_song() end),
    awful.key({}, "#171", function () awesome_context.widgets.music.next_song() end),
    awful.key({}, "#172", function () awesome_context.widgets.music.toggle() end),
    -- lcars keyboard
    awful.key({}, "#180", function () awesome_context.widgets.music.toggle() end),
    awful.key({}, "#163", function () awesome_context.widgets.music.next_song() end),

    bind_key({ modkey }, "c",
      function () os.execute("xsel -p -o | xsel -i -b") end,
      "copy to clipboard", AWESOME_COLOR
    ),

    -- Standard program
    bind_key({ modkey,        }, "Return",
      function () awful.spawn.spawn(shell_commands.tmux) end,
      "terminal", PROGRAMS
    ),
    bind_key({ modkey, altkey }, "Return",
      function ()
        awful.spawn.spawn(shell_commands.tmux_light)
      end,
      "reversed terminal", PROGRAMS
    ),
    bind_key({ modkey,        }, "s",
      function () awful.spawn.spawn(shell_commands.file_manager) end,
      "file manager", PROGRAMS
    ),

    bind_key({ modkey, "Control"  }, "r",
      function()
        awful.spawn.easy_async('bash -c "xrdb -merge $HOME/.Xresources ; pgrep "^st\\$" | xargs kill -s USR1"',
        function()
          awful.util.restart()
        end)
      end,
      "reload awesome wm", AWESOME_COLOR
    ),
    bind_key({ modkey, "Control"    }, "q",
      capi.awesome.quit,
      "quit awesome wm", AWESOME_COLOR
    ),

    -- Scrot stuff
    bind_key({ "Control"      }, "Print",
      function ()
        awful.spawn.with_shell(
        "scrot -ub '%Y-%m-%d--%s_$wx$h_scrot.png' -e " .. shell_commands.scrot_preview_cmd)
      end,
      "screenshot focused", SCREENSHOT
    ),
    bind_key({ altkey        }, "Print",
      function ()
        awful.spawn.with_shell(
        "scrot -s '%Y-%m-%d--%s_$wx$h_scrot.png' -e " .. shell_commands.scrot_preview_cmd)
      end,
      "screenshot selected", SCREENSHOT
    ),
    bind_key({  }, "Print",
      function ()
        awful.spawn.with_shell(
        "scrot '%Y-%m-%d--%s_$wx$h_scrot.png' -e " .. shell_commands.scrot_preview_cmd)
      end,
      "screenshot all", SCREENSHOT
    ),
    bind_key({ "Shift" }, "Print",
      function ()
        awful.spawn.with_shell(
        "scrot '%Y-%m-%d--%s_$wx$h_scrot.png'")
      end,
      "screenshot all", SCREENSHOT
    ),

    bind_key({modkey}, "a",
      revelation,
      "Revelation", AWESOME_COLOR
    ),

    bind_key({modkey, altkey}, "p",
      function()
        local t = awful.screen.focused().selected_tag
        if awful.tag.getproperty(t, 'layout').name == 'lcars' then
          return nlog("fuck you")
        end
        local visible = awful.tag.getproperty(t, 'left_panel_visible')
        awful.tag.setproperty(t, 'left_panel_visible', not visible)
      end,
      "toggle sidebox", LCARS
    ),
    bind_key({modkey, "Control", "Shift"}, "p",
      function()
        local selected_tag = awful.screen.focused().selected_tag
        local visible = awful.tag.getproperty(selected_tag, 'left_panel_visible')
        for s in capi.screen do
          for _, t in ipairs(s.tags) do
            awful.tag.setproperty(t, 'left_panel_visible', not visible)
          end
        end
      end,
      "toggle sidebox (all tags)", LCARS
    ),
    bind_key({modkey, altkey, "Control"}, "p",
      function()
        if persistent.lcarslist.get() then
          persistent.lcarslist.set(false)
        else
          persistent.lcarslist.set(true)
        end
        awful.util.restart()
      end,
      "toggle lcarslist", LCARS
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
        bind_key({ modkey }, "#" .. i + diff,
          function ()
            local tag = capi.screen[scr].tags[i]
            if tag then tag:view_only() end
          end,
          i==1 and "go to tag " .. i .. "(screen #" .. scr .. ")",
          TAG_COLOR
        ),
        bind_key({ modkey, "Control" }, "#" .. i + diff,
          function ()
            local tag = capi.screen[scr].tags[i]
            if tag then awful.tag.viewtoggle(tag) end
          end,
          i==1 and "toggle tag " .. i .. "(screen #" .. scr .. ")",
          TAG_COLOR
        ),
        bind_key({ modkey, "Shift" }, "#" .. i + diff,
          function ()
            if client.focus then
              local tag = capi.screen[scr].tags[i]
              if tag then client.focus:move_to_tag(tag) end
             end
          end,
          i==1 and "move client to tag " .. i .. "(screen #" .. scr .. ")",
          CLIENT_MOVE
        ),
        bind_key({ modkey, "Control", "Shift" }, "#" .. i + diff,
          function ()
            if client.focus then
              local tag = capi.screen[scr].tags[i]
              if tag then
                client.focus:toggle_tag(tag)
              end
            end
          end,
          i==1 and "toggle client on tag " .. i .. "(screen #" .. scr .. ")",
          CLIENT_MANIPULATION
        )
      )

    end
  end

  -- Set keys
  capi.root.keys(globalkeys)
  -- }}}


  -- {{{ Resize, move, swap helpers
  local RESIZE_STEP = beautiful.xresources.apply_dpi(15)


  local function client_floats(c)
    local l = awful.layout.get(c.screen)
    if awful.layout.getname(l) == 'floating' or c.floating then
      return true
    end
    return false
  end

  local function get_swap_or_move_function(direction)
    return function (c)
      if client_floats(c) then
        local g = c:geometry()
        if direction == "down" then
          g.y = g.y + RESIZE_STEP
        elseif direction == "up" then
          g.y = g.y - RESIZE_STEP
        elseif direction == "left" then
          g.x = g.x - RESIZE_STEP
        elseif direction == "right" then
          g.x = g.x + RESIZE_STEP
        end
        c:geometry(g)
      else
        awful.client.swap.global_bydirection(direction)
        if client.swap then client.swap:raise() end
      end
    end
  end

  local function get_resize_function(direction)
    return function (c)
      if client_floats(c) then
        local g = c:geometry()
        if direction == "down" then
          g.height = g.height + RESIZE_STEP
        elseif direction == "up" then
          g.height = g.height - RESIZE_STEP
        elseif direction == "left" then
          g.width = g.width - RESIZE_STEP
        elseif direction == "right" then
          g.width = g.width + RESIZE_STEP
        end
        c:geometry(g)
      else
        if direction == "down" then
          awful.client.incwfact(-0.05)
        elseif direction == "up" then
          awful.client.incwfact( 0.05)
        elseif direction == "left" then
          awful.tag.incmwfact(-0.05)
        elseif direction == "right" then
          awful.tag.incmwfact( 0.05)
        end
      end
    end
  end
  -- }}}


  -- {{{ Client keybindings
  awesome_context.clientkeys = awful.util.table.join(

    bind_key({ modkey, "Control", altkey     }, "Left",
      function (c)
        return tmux_swap_bydirection("left", c)
      end,
      "move tmux window", CLIENT_MANIPULATION
    ),
    bind_key({ modkey, "Control", altkey     }, "Down",
      function (c)
        return tmux_swap_bydirection("down", c)
      end,
      "move tmux window", CLIENT_MANIPULATION
    ),
    bind_key({ modkey, "Control", altkey     }, "Up",
      function (c)
        return tmux_swap_bydirection("up", c)
      end,
      "move tmux window", CLIENT_MANIPULATION
    ),
    bind_key({ modkey, "Control", altkey     }, "Right",
      function (c)
        return tmux_swap_bydirection("right", c)
      end,
      "move tmux window", CLIENT_MANIPULATION
    ),

    bind_key({ modkey, "Control", altkey     }, "h",
      function (c)
        return tmux_swap_bydirection("left", c)
      end,
      "move tmux window (vim style)", CLIENT_MANIPULATION
    ),
    bind_key({ modkey, "Control", altkey     }, "j",
      function (c)
        return tmux_swap_bydirection("down", c)
      end,
      "move tmux window (vim style)", CLIENT_MANIPULATION
    ),
    bind_key({ modkey, "Control", altkey     }, "k",
      function (c)
        return tmux_swap_bydirection("up", c)
      end,
      "move tmux window (vim style)", CLIENT_MANIPULATION
    ),
    bind_key({ modkey, "Control", altkey     }, "l",
      function (c)
        return tmux_swap_bydirection("right", c)
      end,
      "move tmux window (vim style)", CLIENT_MANIPULATION
    ),

    bind_key({ modkey,  "Shift"    }, "Down",
      get_swap_or_move_function("down"),
      "swap/move", CLIENT_MOVE
    ),
    bind_key({ modkey,  "Shift"    }, "Up",
      get_swap_or_move_function("up"),
      "swap/move", CLIENT_MOVE
    ),
    bind_key({ modkey,  "Shift"    }, "Left",
      get_swap_or_move_function("left"),
      "swap/move", CLIENT_MOVE
    ),
    bind_key({ modkey,  "Shift"    }, "Right",
      get_swap_or_move_function("right"),
      "swap/move", CLIENT_MOVE
    ),

    bind_key({ modkey, "Shift" }, "j",
      get_swap_or_move_function("down"),
      "swap/move (vim style)", CLIENT_MOVE
    ),
    bind_key({ modkey, "Shift" }, "k",
      get_swap_or_move_function("up"),
      "swap/move (vim style)", CLIENT_MOVE
    ),
    bind_key({ modkey, "Shift" }, "h",
      get_swap_or_move_function("left"),
      "swap/move (vim style)", CLIENT_MOVE
    ),
    bind_key({ modkey, "Shift" }, "l",
      get_swap_or_move_function("right"),
      "swap/move (vim style)", CLIENT_MOVE
    ),

    -- Client resize
    bind_key({ modkey, "Control"  }, "Right",
      get_resize_function("right"),
      "master size+", LAYOUT_MANIPULATION
    ),
    bind_key({ modkey,  "Control"  }, "Left",
      get_resize_function("left"),
      "master size-", LAYOUT_MANIPULATION
    ),
    bind_key({ modkey, "Control"  }, "Down",
      get_resize_function("down"),
      "column size-", LAYOUT_MANIPULATION
    ),
    bind_key({ modkey, "Control"  }, "Up",
      get_resize_function("up"),
      "column size+", LAYOUT_MANIPULATION
    ),

    -- Client resize (VIM style)
    bind_key({ modkey, "Control" }, "l",
      get_resize_function("right"),
      "master size+", LAYOUT_MANIPULATION
    ),
    bind_key({ modkey,  "Control" }, "h",
      get_resize_function("left"),
      "master size-", LAYOUT_MANIPULATION
    ),
    bind_key({ modkey, "Control" }, "j",
      get_resize_function("down"),
      "column size-", LAYOUT_MANIPULATION
    ),

    bind_key({ modkey, "Control" }, "k",
      get_resize_function("up"),
      "column size+", LAYOUT_MANIPULATION
    ),

    bind_key({ modkey,        }, "f",
      function (c) c.fullscreen = not c.fullscreen end,
      "toggle client fullscreen", CLIENT_MANIPULATION
    ),
    bind_key({ modkey,        }, "q",
      function (c) c:kill() end,
      "quit app", CLIENT_MANIPULATION
    ),
    bind_key({ modkey, "Shift"  }, "f",
      awful.client.floating.toggle,
      "toggle client float", CLIENT_MANIPULATION
    ),
    bind_key({ modkey, "Shift"  }, "s",
      function(c)
        c.sticky = not c.sticky
      end,
      "toggle client sticky (on all tags)", CLIENT_MANIPULATION
    ),
    bind_key({ modkey, "Shift"  }, "Return",
      function (c) c:swap(awful.client.getmaster()) end,
      "put client on master", CLIENT_MOVE
    ),
    --bind_key({ modkey,        }, "o",
      --function(c) c:move_to_screen() end,
      --"move client to other screen", CLIENT_MOVE
    --),
    bind_key({ modkey,        }, "t",
      function (c) c.ontop = not c.ontop end,
      "toggle client on top", CLIENT_MANIPULATION
    ),
    bind_key({ modkey, "Shift"    }, "t",
      function(c)
       awesome_context.widgets.screen[c.screen.index].manage_client.toggle()
      end,
      "toggle titlebars", AWESOME_COLOR
    ),
    bind_key({ modkey,        }, "n",
      function (c) c.minimized = true end,
      "iconify client", CLIENT_MANIPULATION
    ),
    bind_key({ modkey,        }, "m",
      function (c)
        c.maximized = not c.maximized
        if not c.maximized then
          c.maximized_horizontal = c.maximized
          c.maximized_vertical   = c.maximized
        end
        c:raise()
      end,
      "maximize client", CLIENT_MANIPULATION
    )
  )
  -- }}}


end
return keys

-- vim: fdm=marker:foldenable
