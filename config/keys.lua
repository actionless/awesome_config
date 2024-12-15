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
local menu_addon = require("actionless.menu_addon")
local persistent = require("actionless.persistent")
local tmux_swap_bydirection = require("actionless.util.tmux").swap_bydirection
local wlppr = require("actionless.wlppr")
local mpv = require("actionless.mpv")
local kbd_helpers = require('actionless.keyboard')
local h_table = require('actionless.util.table')
local get_icon = require("actionless.util.xdg").get_icon
local color_utils = require("actionless.util.color")
local nlog = require("actionless.util.debug").naughty_log
local dpi = beautiful.xresources.apply_dpi

local keys = {}
function keys.init(awesome_context)

  local modkey = awesome_context.modkey
  local altkey = awesome_context.altkey

  local shell_commands = awesome_context.cmds

  local MOUSE_MOVE_PX = dpi(5)
  local MOUSE_FAST_MOVE_PX = dpi(50)
  local VIRTUAL_MOUSE_MODIFIERS = { modkey, altkey, "Shift", "Control"}

  local revelation = require("third_party.revelation")
  revelation.fg = beautiful.revelation_fg
  revelation.border_color = beautiful.revelation_border_color
  revelation.bg = beautiful.revelation_bg
  revelation.font = beautiful.revelation_font
  revelation.init()

  local tag_previewz = require("third_party.awesome_overview").new({
    default_client_icon = get_icon('apps', 'terminal'),
    screen_bg = beautiful.bg_normal and color_utils.transparentize(beautiful.bg_normal, 0.3),
    client_bg = beautiful.actionless_titlebar_bg_normal,
    client_fg = beautiful.actionless_titlebar_fg_normal,
    client_border_color = beautiful.actionless_titlebar_bg_normal,
    client_bg_focus = beautiful.actionless_titlebar_bg_normal,
    client_fg_focus = beautiful.actionless_titlebar_fg_focus,
    client_border_color_focus = beautiful.actionless_titlebar_bg_focus,
  })



  -- {{{ Menu keybindings
  awful.menu.menu_keys.back = { "Left", "h" }
  awful.menu.menu_keys.down = { "Down", "j" }
  awful.menu.menu_keys.up = { "Up", "k" }
  awful.menu.menu_keys.enter = { "Right", "l" }
  awful.menu.menu_keys.close = { "Escape", '#133', 'q', 'w', }
  -- }}}


  -- {{{ Hotkeys group names
  local TAG_COLOR = "tag"
  local CLIENT_FOCUS = "client: focus"
  local CLIENT_MOVE = "client: move"
  local GROUP_MENU = "menu"
  local AWESOME_COLOR = "AWESOME"
  local CLIENT_MANIPULATION = "client"
  local LAYOUT_MANIPULATION = "layout"
  local LCARS = "LCARS"
  local LAUNCHER = "launcher"
  local MUSIC = "music"
  local PROGRAMS = "programs"
  local SCREENSHOT = "screenshot"
  local VIRTUAL_MOUSE = "virtual mouse"
  local DISPLAY_GROUP = "display"
  -- }}}

  local bind_key = function(mod, key, press, description, group)
    return awful.key.new(mod, key, press, nil, {description=description, group=group})
  end

  if hkng.widget.labels then
    hkng.widget.labels.BackSpace = "BackSpace"
  end


  -- {{{ Root keybindings
  local globalkeys = awful.util.table.join(

    awful.key({modkey}, "/", function()
      hkng.show_help()
    end, nil, {
      description = "show help (all)", group="HELP"
    }),
    awful.key({"Shift", modkey}, "/", function()
      hkng.show_help(nil, nil, {show_awesome_keys=false})
    end, nil, {
      description = "show help for current app", group="HELP"
    }),
    awful.key({altkey, modkey}, "/", function()
      hkng.show_help({}, nil, {show_awesome_keys=true})
    end, nil, {
      description = "show help for awesome only", group="HELP"
    }),

    awful.key({ modkey}, ";", function()
      kbd_helpers.release_modifiers()
      root.fake_input('key_press'  , 'Menu')
    end, function()
      root.fake_input('key_release', 'Menu')
    end, {
      description = "context menu", group=GROUP_MENU
    }),

  -- {{{ Virtual mouse
  -- @TODO: refactor to native awesome stuff and extract to a separate file:
  -- file:///usr/share/doc/awesome/doc/core_components/root.html#fake_input
  -- file:///usr/share/doc/awesome/doc/input_handling/mouse.html#coords
    awful.key(VIRTUAL_MOUSE_MODIFIERS, "Return", function()
      awful.spawn({'xdotool', 'mousedown', '--clearmodifiers', '1'})
    end, function()
      awful.spawn({'xdotool', 'mouseup', '--clearmodifiers', '1'})
    end, {
      description = "left click", group=VIRTUAL_MOUSE
    }),
    awful.key(VIRTUAL_MOUSE_MODIFIERS, "\\", function()
      awful.spawn({'xdotool', 'mousedown', '--clearmodifiers', '2'})
    end, function()
      awful.spawn({'xdotool', 'mouseup', '--clearmodifiers', '2'})
    end, {
      description = "middle click", group=VIRTUAL_MOUSE
    }),
    awful.key(VIRTUAL_MOUSE_MODIFIERS, "BackSpace", function()
      awful.spawn({'xdotool', 'mousedown', '--clearmodifiers', '3'})
    end, function()
      awful.spawn({'xdotool', 'mouseup', '--clearmodifiers', '3'})
    end, {
      description = "right click", group=VIRTUAL_MOUSE
    }),
    awful.key(VIRTUAL_MOUSE_MODIFIERS, "=", function()
      awful.spawn({'xdotool', 'mousedown', '--clearmodifiers', '4'})
    end, function()
      awful.spawn({'xdotool', 'mouseup', '--clearmodifiers', '4'})
    end, {
      description = "wheel down", group=VIRTUAL_MOUSE
    }),
    awful.key(VIRTUAL_MOUSE_MODIFIERS, "-", function()
      awful.spawn({'xdotool', 'mousedown', '--clearmodifiers', '5'})
    end, function()
      awful.spawn({'xdotool', 'mouseup', '--clearmodifiers', '5'})
    end, {
      description = "wheel up", group=VIRTUAL_MOUSE
    }),


    awful.key(VIRTUAL_MOUSE_MODIFIERS, "Up", function()
      awful.spawn({'xdotool', 'mousemove_relative', '--', '0',  '-'..tostring(MOUSE_MOVE_PX)})
    end, {
      description = "move up", group=VIRTUAL_MOUSE
    }),
    awful.key(VIRTUAL_MOUSE_MODIFIERS, "Down", function()
      awful.spawn({'xdotool', 'mousemove_relative', '0',  tostring(MOUSE_MOVE_PX)})
    end, {
      description = "move down", group=VIRTUAL_MOUSE
    }),
    awful.key(VIRTUAL_MOUSE_MODIFIERS, "Left", function()
      awful.spawn({'xdotool', 'mousemove_relative', '--', '-'..tostring(MOUSE_MOVE_PX),  '0'})
    end, {
      description = "move left", group=VIRTUAL_MOUSE
    }),
    awful.key(VIRTUAL_MOUSE_MODIFIERS, "Right", function()
      awful.spawn({'xdotool', 'mousemove_relative', tostring(MOUSE_MOVE_PX),  '0'})
    end, {
      description = "move right", group=VIRTUAL_MOUSE
    }),

    awful.key(VIRTUAL_MOUSE_MODIFIERS, "Home", function()
      awful.spawn({'xdotool', 'mousemove_relative', '--', '0',  '-'..tostring(MOUSE_FAST_MOVE_PX)})
    end, {
      description = "quick move up", group=VIRTUAL_MOUSE
    }),
    awful.key(VIRTUAL_MOUSE_MODIFIERS, "End", function()
      awful.spawn({'xdotool', 'mousemove_relative', '0',  tostring(MOUSE_FAST_MOVE_PX)})
    end, {
      description = "quick move down", group=VIRTUAL_MOUSE
    }),
    awful.key(VIRTUAL_MOUSE_MODIFIERS, "Delete", function()
      awful.spawn({'xdotool', 'mousemove_relative', '--', '-'..tostring(MOUSE_FAST_MOVE_PX),  '0'})
    end, {
      description = "quick move left", group=VIRTUAL_MOUSE
    }),
    awful.key(VIRTUAL_MOUSE_MODIFIERS, "Page_Down", function()
      awful.spawn({'xdotool', 'mousemove_relative', tostring(MOUSE_FAST_MOVE_PX),  '0'})
    end, {
      description = "quick move right", group=VIRTUAL_MOUSE
    }),
    awful.key(VIRTUAL_MOUSE_MODIFIERS, "Insert", function()
      awful.spawn({
        'xdotool',
        'mousemove_relative',
        '--', '-'..tostring(MOUSE_FAST_MOVE_PX),  '-'..tostring(MOUSE_FAST_MOVE_PX)
      })
    end, {
      description = "quick move top-left", group=VIRTUAL_MOUSE
    }),
    awful.key(VIRTUAL_MOUSE_MODIFIERS, "Page_Up", function()
      awful.spawn({
        'xdotool',
        'mousemove_relative',
        '--', tostring(MOUSE_FAST_MOVE_PX),  '-'..tostring(MOUSE_FAST_MOVE_PX)
      })
    end, {
      description = "quick move top-right", group=VIRTUAL_MOUSE
    }),
  -- }}} Virtual mouse


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
      function()
        if awesome_context.widgets.systray_toggle then
          awesome_context.widgets.systray_toggle:toggle()
        else
          awesome_context.widgets.naughty_sidebar:toggle_sidebox()
        end
      end,
      "toggle systray popup", AWESOME_COLOR
    ),

    bind_key({ modkey,  "Control"  }, "s",
      function() awful.spawn{"xscreensaver-command", "-lock"} end,
      "xscreensaver lock", DISPLAY_GROUP
    ),
    bind_key({ modkey,  "Control"  }, "d",
      function() awful.spawn.with_shell("sleep 1 && xset dpms force off") end,
      "turn off display", DISPLAY_GROUP
    ),
    bind_key({ modkey,  }, "o",
      function() awful.spawn.with_shell(os.getenv('HOME').."/.screenlayout/cycle.sh") end,
      "rotate display", DISPLAY_GROUP
    ),
    awful.key({modkey, altkey}, "Page_Up", function()
      awesome_context.widgets.backlight.Up()
    end, {
      description = "backlight up", group=DISPLAY_GROUP
    }),
    awful.key({modkey, altkey}, "Page_Down", function()
      awesome_context.widgets.backlight.Down()
    end, {
      description = "backlight down", group=DISPLAY_GROUP
    }),
    awful.key({modkey, altkey}, "End", function()
      local current_backlight = awesome_context.widgets.backlight.backend.Volume
      local prev_backlight = awesome_context.widgets.backlight.backend.prev_backlight
      awesome_context.widgets.backlight.backend.prev_backlight = current_backlight
      local new_backlight
      if current_backlight == 1 then
        if prev_backlight then
          new_backlight = prev_backlight
        else
          new_backlight = awesome_context.widgets.backlight.presets[1]/100
        end
      else
        new_backlight = 1
      end
      awesome_context.widgets.backlight.SetValue(new_backlight)
    end, {
      description = "backlight toggle prev", group=DISPLAY_GROUP
    }),


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
        local tag_id = tag_helpers.tag_idx_to_key(tag.index)
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
      function()
        awesome_context.widgets.screen[awful.screen.focused().index].manage_client:hide()
        awful.screen.focus_relative(1)
        awesome_context.widgets.screen[awful.screen.focused().index].manage_client:show()
      end,
      "next screen", TAG_COLOR
    ),
    bind_key({ modkey,        }, "Prior",
      function()
        awesome_context.widgets.screen[awful.screen.focused().index].manage_client:hide()
        awful.screen.focus_relative(-1)
        awesome_context.widgets.screen[awful.screen.focused().index].manage_client:show()
      end,
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
      function () awesome_context.menu.mainmenu_toggle(true) end,
      "aWesome menu", GROUP_MENU
    ),
    bind_key({ modkey,       }, "i",
      function ()
        awesome_context.menu.instance = menu_addon.clients_on_tag({
          theme = {width=capi.screen[awful.screen.focused()].workarea.width - beautiful.menu_border_width*2},
          coords = {x=0, y=beautiful.basic_panel_height}
        })
      end,
      "clients on current tag menu", GROUP_MENU
    ),
    bind_key({ modkey,       }, "p",
      function ()
        awesome_context.menu.instance = menu_addon.clients_with_icons({
          theme = {width=capi.screen[awful.screen.focused()].workarea.width - beautiful.menu_border_width*2},
          coords = {x=0, y=beautiful.basic_panel_height}
        })
      end,
      "all clients menu", GROUP_MENU
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
    bind_key({ modkey, "Control" }, "x",
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

    -- volume control
    awful.key({}, "#123", function ()
        awesome_context.widgets.volume.Up()
    end),
    awful.key({}, "#122", function ()
        awesome_context.widgets.volume.Down()
    end),
    awful.key({modkey}, "#123", function ()
        --awesome_context.widgets.volume.Up(nil, 0.002)
        awesome_context.widgets.volume.Up(nil, 0.001)
    end),
    awful.key({modkey}, "#122", function ()
        --awesome_context.widgets.volume.Down(nil, 0.002)
        awesome_context.widgets.volume.Down(nil, 0.001)
    end),
    awful.key({}, "#121", function ()
        awesome_context.widgets.volume.ToggleMute()
    end),
    awful.key({}, "#78", function ()  -- scroll lock
        awesome_context.widgets.volume.ToggleMute()
    end),
    awful.key({}, "#198", function () awesome_context.widgets.volume.toggle_mic() end),

    -- Music player control
    --bind_key({modkey, altkey}, ",",
    --  function () awesome_context.widgets.music.prev_song() end,
    --  "prev song", MUSIC),
    --bind_key({modkey, altkey}, ".",
    --  function () awesome_context.widgets.music.next_song() end,
    --  "next song", MUSIC),
    --bind_key({modkey, altkey}, "/",
    --  function () awesome_context.widgets.music.toggle() end,
    --  "pause music", MUSIC),

    bind_key({modkey, }, "<",
      function () awesome_context.widgets.music.prev_song() end,
      "prev song", MUSIC),
    bind_key({modkey, }, "z",
      function () awesome_context.widgets.music.toggle() end,
      "pause music", MUSIC),
    bind_key({modkey, }, "x",
      function () awesome_context.widgets.music.next_song() end,
      "next song", MUSIC),

    -- Generic
    awful.key({}, "XF86AudioPlay", function () awesome_context.widgets.music.toggle() end),
    awful.key({}, "#150", function () awesome_context.widgets.music.prev_song() end),
    awful.key({}, "#148", function () awesome_context.widgets.music.next_song() end),
    -- lenovo keyboard
    awful.key({}, "#173", function () awesome_context.widgets.music.prev_song() end),
    awful.key({}, "#171", function () awesome_context.widgets.music.next_song() end),
    -- lcars keyboard
    --awful.key({}, "#163", function () awesome_context.widgets.music.next_song() end),

    bind_key({modkey, "Shift"}, "p",
      function ()
        awesome_context.widgets.pipewire_helper.show_menu({
          coords={
            x=(awful.screen.focused().geometry.width - awesome_context.widgets.pipewire_helper.menu_width) / 2,
            y=beautiful.basic_panel_height,
          }
        })
      end,
      "pipewire menu", MUSIC),

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

    bind_key({ modkey, altkey }, "m",
      function() awful.spawn.with_shell('mpv "$(xsel -b)"') end,
      "mpv-xsel", PROGRAMS
    ),
    awful.key.new({ modkey, "Control" }, "m",
      nil, mpv.play_browser_url,
      {description="mpv-xsel from browser", group=PROGRAMS}
    ),
    bind_key({ modkey,  }, "e",
      function() awful.spawn{"emote"} end,
      "emote", PROGRAMS
    ),

    bind_key({ modkey, "Control"  }, "r",
      function()
        awful.spawn.easy_async_with_shell(
          'xrdb -merge $HOME/.Xresources ; pgrep "^xst\\$" | xargs kill -s USR1',
          function()
            awful.util.restart()
          end
        )
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
          "scrot -ub '%Y-%m-%d--%s_$wx$h_scrot.png' -e "
          .. "'mv $f ~/images/'"
        )
      end,
      "screenshot focused", SCREENSHOT
    ),
    bind_key({ "Control", "Shift" }, "Print",
      function ()
        awful.spawn.with_shell(
          "scrot -ub '%Y-%m-%d--%s_$wx$h_scrot.png' -e "
          .. "'mv $f ~/images/ && "
          .. shell_commands.scrot_preview_cmd
          .. "'"
        )
      end,
      "screenshot focused and open", SCREENSHOT
    ),
    bind_key({ "Control", altkey }, "Print",
      function ()
        awful.spawn.with_shell(
        "scrot -u '%Y-%m-%d--%s_$wx$h_scrot.png' -e "
          .. "'mv $f ~/images/ && "
          .. shell_commands.scrot_preview_cmd
          .. "'")
      end,
      "screenshot focused without border", SCREENSHOT
    ),
    bind_key({ altkey        }, "Print",
      function ()
        awful.spawn.with_shell(
          --"scrot -a $(slop -o -f '%x,%y,%w,%h') '%Y-%m-%d--%s_$wx$h_scrot.png' -e "
          --"scrot -a $(slop -f '%x,%y,%w,%h' && sleep 0.3) '%Y-%m-%d--%s_$wx$h_scrot.png' -e "
          "scrot -a $(slop -f '%x,%y,%w,%h' -o && sleep 0.3) '%Y-%m-%d--%s_$wx$h_scrot.png' -e "
          .. "'mv $f ~/images/ && "
          .. shell_commands.scrot_preview_cmd
          .. "'"
        )
      end,
      "screenshot selected", SCREENSHOT
    ),
    bind_key({ "Shift" }, "Print",
      function ()
        awful.spawn.with_shell(
          "scrot '%Y-%m-%d--%s_$wx$h_scrot.png' -e "
          .. "'mv $f ~/images/ && "
          .. shell_commands.scrot_preview_cmd
          .. "'"
        )
      end,
      "screenshot all and open", SCREENSHOT
    ),
    bind_key({  }, "Print",
      function ()
        awful.spawn.with_shell(
          "scrot '%Y-%m-%d--%s_$wx$h_scrot.png' -e "
          .. "'mv $f ~/images/'"
        )
      end,
      "screenshot all", SCREENSHOT
    ),

    bind_key({modkey, "Shift"}, "a",
      revelation,
      "Revelation", AWESOME_COLOR
    ),
    bind_key({modkey}, "a",
      function()
        tag_previewz:toggle(
          awful.screen.focused(),
          { update = true }
        )
      end,
      "Tag Preview", AWESOME_COLOR
    ),
    bind_key({modkey, altkey}, "n",
      function()
        awesome_context.widgets.naughty_sidebar:toggle_sidebox()
      end,
      "notifications sidebox", AWESOME_COLOR
    ),
    bind_key({modkey, altkey}, "u",
      function()
        awesome_context.widgets.naughty_sidebar:remove_or_mark_as_read()
      end,
      "remove unread / mark as read", AWESOME_COLOR
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
  local screen_count = screen.count()
  local max_tag = 12
  if screen_count == 1 then
    max_tag = 24
  end
  for scr = 1, screen_count do
    for i = 1, max_tag do

      local skip = false

      -- in case of 3 screens
      if scr == 2 and screen_count > 2 and i>6 then
        -- F1..F6 will work for the screen #2
        skip = true
      end
      if scr == 3 and i<7 then
        -- and F7..F12 will work for the screen #3
        skip = true
      end

      if not skip then

        if awesome_context.config.swap_screen_hotkeys then
          if scr >= 2 then
            if i <= 12 then
              -- num keys:
              diff = 9
            elseif i>22 then
              diff = 72
            else
              diff = 54
            end
          elseif scr == 1 then
            -- f-keys:
            if i>10 then
              diff = 84
            else
              diff = 66
            end
          end
        else
          if scr == 1 then
            if i <= 12 then
              -- num keys:
              diff = 9
            elseif i>22 then
              diff = 72
            else
              diff = 54
            end
          elseif scr >= 2 then
            -- f-keys:
            if i>10 then
              diff = 84
            else
              diff = 66
            end
          end
        end

        globalkeys = awful.util.table.join(globalkeys,
          bind_key({ modkey }, "#" .. i + diff,
            function ()
              local tag = capi.screen[scr].tags[i]
              if tag then
                local current_screen = awful.screen.focused()
                tag:view_only()
                if capi.screen[scr] ~= current_screen then
                  awful.screen.focus(capi.screen[scr])
                end
              end
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
  end

  globalkeys = awful.util.table.join(globalkeys,
    h_table.unpack(awesome_context.extra_global_keys)
  )
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
        local s = c.screen
        local layout = awful.layout.getname(awful.layout.get(s))
        --nlog(layout)
        local sign = 1
        local new_direction = direction
        if layout == "tileleft" then
          sign = -1
        elseif layout == "tilebottom" then
          if direction == "down" then
            new_direction = "right"
          elseif direction == "up" then
            new_direction = "left"
          elseif direction == "left" then
            new_direction = "up"
          elseif direction == "right" then
            new_direction = "down"
          end
        end
        --nlog(new_direction)
        if new_direction == "down" then
          awful.client.incwfact(-0.05)
        elseif new_direction == "up" then
          awful.client.incwfact( 0.05)
        elseif new_direction == "left" then
          awful.tag.incmwfact(-0.05 * sign)
        elseif new_direction == "right" then
          awful.tag.incmwfact( 0.05 * sign)
        elseif new_direction == "reset_clients" then
          local t = s.selected_tag
          t.windowfact = {}
          awful.layout.arrange(s)
        elseif new_direction == "reset" then
          local t = s.selected_tag
          t.master_width_factor = 0.5
          t.windowfact = {}
          awful.layout.arrange(s)
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
    bind_key({ modkey, "Control"  }, "Home",
      get_resize_function("reset_clients"),
      "reset layout", LAYOUT_MANIPULATION
    ),
    bind_key({ modkey, "Control"  }, "End",
      get_resize_function("reset"),
      "reset layout", LAYOUT_MANIPULATION
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
       awesome_context.widgets.screen[c.screen.index].manage_client:toggle()
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
    ),
    bind_key({ modkey, altkey }, "c",
      function (c)
        c.maximized = false
        c.fullscreen = false
        c.maximized_horizontal = false
        c.maximized_vertical   = false
        local sgeo = c.screen.workarea
        local cgeo = c:geometry()
        if (cgeo.height > sgeo.height) then
          cgeo.height = math.ceil(sgeo.height * 0.9)
        end
        if (cgeo.width > sgeo.width) then
          cgeo.width = sgeo.width + math.ceil(sgeo.height * 0.9) - sgeo.height
        end
        c:geometry(cgeo)
        awful.placement.centered(c, {honor_workarea=true, })
      end,
      "center and resize client", CLIENT_MANIPULATION
    )
  )
  -- }}}


end
return keys

-- vim: fdm=marker:foldenable
