-- default rc.lua for shifty
--
-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
-- shifty - dynamic tagging library
local shifty = require("shifty")

local lain = require("lain")
local widgets = require("widgets")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Autostart applications
function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
     findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

awful.util.spawn_with_shell("eval $(gnome-keyring-daemon -s --components=pkcs11,secrets,ssh,gpg)")
awful.util.spawn_with_shell("xset r rate 250 25")
awful.util.spawn_with_shell("xset b off")
run_once("compton --backend glx --paint-on-overlay --glx-no-stencil --vsync opengl-swc --unredir-if-possible --config ~/.config/compton_awesome.conf")
run_once("urxvtd")
run_once("unclutter")

run_once("gxkb")
run_once("dropboxd")
-- }}}


-- {{{ Variable definitions

-- localization
os.setlocale(os.getenv("LANG"))

-- beautiful init
beautiful.init(awful.util.getdir("config") .. "/themes/actionless/theme.lua")

-- common
modkey     = "Mod4"
altkey     = "Mod1"
--terminal   = "urxvtc" or "xterm"
terminal   = "terminator"
editor     = "vim" or os.getenv("EDITOR") or "nano" or "vi"
editor_cmd = terminal .. " -e " .. editor

-- user defined
--browser    = "dwb"
--chromium   = "GTK2_RC_FILES=~/.gtkrc-2.0.browsers chromium --enable-user-stylesheet"
--firefox    = "GTK2_RC_FILES=~/.gtkrc-2.0.browsers firefox -P actionless"
chromium   = "chromium --enable-user-stylesheet"
firefox    = "firefox -P actionless"
gui_editor = "/opt/sublime_text/sublime_text"
graphics   = "pinta"
file_manager = "stuurman"
mail       = terminal .. " -e mutt "
iptraf     = terminal .. " -g 180x54-20+34 -e sudo iptraf-ng -i all "
musicplr   = terminal .. " -g 130x34-320+16 -e ncmpcpp "
tmux       = terminal .. " -e tmux "
--tmux       = terminal .. ' -e zsh -c "TERM=screen-256color-bce tmux" '

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
}

-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- Shifty configured tags.
shifty.config.tags = {
    ["1:main"] = {
        layout    = awful.layout.suit.tile,
        mwfact    = 0.60,
        exclusive = false,
        position  = 1,
        init      = true,
        screen    = 1,
        slave     = true,
    },
    ["2:web"] = {
        layout      = awful.layout.suit.tile,
        mwfact      = 0.75,
        exclusive   = false,
        --max_clients = 1,
        position    = 2,
    --    spawn       = browser,
    },
    ["3:work"] = {
        layout    = awful.layout.suit.tile,
        mwfact    = 0.75,
        exclusive = false,
        position  = 3,
        --spawn     = mail,
        slave     = true
    },
    ["4:im"] = {
        layout    = awful.layout.suit.tile.bottom,
        exclusive = false,
        position  = 4,
        nmaster = 0,
    },
    ["5:media"] = {
        layout    = awful.layout.suit.floating,
        exclusive = false,
        position  = 5,
    },
}

-- SHIFTY: application matching rules
-- order here matters, early rules will be applied first
shifty.config.apps = {
    {
        match = {
            --"Navigator",
            "Vimperator",
            --"Gran Paradiso",
            "Chromium",
        },
        tag = "2:web",
    },
    {
        match = {
            "Google Chrome",
            "vmplayer",
        },
        tag = "3:work",
    },
    {
        match = {
            "Skype",
        },
        tag = "4:im",
    },
    {
        match = {
            "pcmanfm",
        },
        slave = true
    },
    {
        match = {
            "OpenOffice.*",
            "Abiword",
            "Gnumeric",
        },
        tag = "office",
    },
    {
        match = {
            "Mplayer.*",
            "Mirage",
            "gimp",
            "gtkpod",
            "Ufraw",
            "easytag",
            "Transmission"
        },
        tag = "5:media",
        nopopup = true,
    },
    {
        match = {
            "MPlayer",
            "Gnuplot",
            "galculator",
        },
        float = true,
    },
    {
        match = {
            terminal,
        },
        honorsizehints = false,
        slave = true,
    },
    {
        match = {""},
        honorsizehints = false,
        buttons = awful.util.table.join(
            awful.button({}, 1, function (c) client.focus = c; c:raise() end),
            awful.button({modkey}, 1, function(c)
                client.focus = c
                c:raise()
                awful.mouse.client.move(c)
                end),
            awful.button({modkey}, 3, awful.mouse.client.resize)
            )
    },
}

-- SHIFTY: default tag creation rules
-- parameter description
--  * floatBars : if floating clients should always have a titlebar
--  * guess_name : should shifty try and guess tag names when creating
--                 new (unconfigured) tags?
--  * guess_position: as above, but for position parameter
--  * run : function to exec when shifty creates a new tag
--  * all other parameters (e.g. layout, mwfact) follow awesome's tag API
shifty.config.defaults = {
    layout = awful.layout.suit.tile,
    ncol = 1,
    mwfact = 0.60,
    floatBars = true,
    guess_name = true,
    guess_position = true,
}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

--menubar.geometry = {
--   height = 18,
--   width = 1680,
--   x = 0,
--   y = 1032
--}

--require("freedesktop/freedesktop")

-- {{{ Wibox
markup = lain.util.markup

-- ALSA volume
volicon = wibox.widget.imagebox(beautiful.widget_vol)
voliconbg = wibox.widget.background(volicon, beautiful.alt_bg)
volumewidget = lain.widgets.alsa({
    channel = 'Master',
    settings = function()
        if volume_now.status == "off" then
            volicon:set_image(beautiful.widget_vol_mute)
        elseif tonumber(volume_now.level) == 0 then
            volicon:set_image(beautiful.widget_vol_no)
        elseif tonumber(volume_now.level) <= 50 then
            volicon:set_image(beautiful.widget_vol_low)
        else
            volicon:set_image(beautiful.widget_vol)
        end

        widget:set_text(" " .. volume_now.level .. "% ")
    end
})
volumewidgetbg = wibox.widget.background(volumewidget, beautiful.alt_bg)

-- MPD
mpdicon = wibox.widget.imagebox(beautiful.widget_music)
mpdicon:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn_with_shell(musicplr) end)))
mpdwidget = lain.widgets.mpd({
    settings = function()
        if mpd_now.state == "play" then
            artist = " " .. mpd_now.artist .. " "
            title  = mpd_now.title  .. " "
            mpdicon:set_image(beautiful.widget_music_on)
        elseif mpd_now.state == "pause" then
            artist = " mpd "
            title  = "paused "
        else
            artist = ""
            title  = ""
            mpdicon:set_image(beautiful.widget_music)
        end

        widget:set_markup(markup(beautiful.mpd_text, artist) .. title)
    end
})
-- mpdwidgetbg = wibox.widget.background(mpdwidget, beautiful.alt_bg)
mpdwidgetbg = mpdwidget

-- MEM
memicon = wibox.widget.imagebox(beautiful.widget_mem)
memwidget = lain.widgets.mem({
    settings = function()
        widget:set_text(" " .. mem_now.used .. "MB ")
    end
})

-- CPU
cpuicon = wibox.widget.imagebox(beautiful.widget_cpu)
cpuwidget = wibox.widget.background(lain.widgets.cpu({
    settings = function()
        widget:set_text(" " .. cpu_now.usage .. "% ")
    end
}), beautiful.alt_bg)

-- Coretemp
--tempicon = wibox.widget.imagebox(beautiful.widget_temp)
--tempwidget = lain.widgets.temp({
--    settings = function()
--        widget:set_text(" " .. coretemp_now .. "°C ")
--    end
--})

-- / fs
fsicon = wibox.widget.imagebox(beautiful.widget_hdd)
fswidget = lain.widgets.fs({
    settings  = function()
        widget:set_text(" " .. used .. "% ")
    end
})
fswidgetbg = wibox.widget.background(fswidget, beautiful.alt_bg)

-- Textclock
clockicon = wibox.widget.imagebox(beautiful.widget_clock)
-- mytextclock = awful.widget.textclock(" %a %d %b  %H:%M")
mytextclock = awful.widget.textclock(" %H:%M")

-- calendar
lain.widgets.calendar:attach(mytextclock, { font_size = 10 })

-- Battery
-- baticon = wibox.widget.imagebox(beautiful.widget_battery)
-- batwidget = lain.widgets.bat({
--     settings = function()
--         if bat_now.perc == "N/A" then
--             bat_now.perc = "AC"
--             baticon:set_image(beautiful.widget_ac)
--        elseif tonumber(bat_now.perc) <= 5 then
--             baticon:set_image(beautiful.widget_battery_empty)
--         elseif tonumber(bat_now.perc) <= 15 then
--             baticon:set_image(beautiful.widget_battery_low)
--         else
--             baticon:set_image(beautiful.widget_battery)
--         end
--         widget:set_markup(" " .. bat_now.perc .. " ")
--     end
--})

-- Separators
spr = wibox.widget.textbox(' ')
arrl = wibox.widget.imagebox()
arrl:set_image(beautiful.arrl)
arrl_dl = wibox.widget.imagebox()
arrl_dl:set_image(beautiful.arrl_dl)
arrl_ld = wibox.widget.imagebox()
arrl_ld:set_image(beautiful.arrl_ld)

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 5, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 4, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mycurrenttask = {}
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = widgets.menu.clients({ width=450 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mycurrenttask[s] = widgets.tasklist(s, widgets.tasklist.filter.focused, mytasklist.buttons, 'fixed')
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.minimizedcurrenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, height = 18 })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(spr)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])
    left_layout:add(spr)
    left_layout:add(mycurrenttask[s])
    left_layout:add(spr)

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(spr)
    right_layout:add(arrl)
    right_layout:add(voliconbg)
    right_layout:add(volumewidgetbg)
    right_layout:add(arrl)
    right_layout:add(mpdicon)
    right_layout:add(mpdwidgetbg)
    right_layout:add(arrl)
    right_layout:add(memicon)
    right_layout:add(memwidget)
    right_layout:add(arrl)
    right_layout:add(cpuicon)
    right_layout:add(cpuwidget)
    --right_layout:add(tempicon)
    --right_layout:add(tempwidget)
    right_layout:add(arrl)
    right_layout:add(fsicon)
    right_layout:add(fswidgetbg)
    right_layout:add(arrl)
    -- right_layout:add(baticon)
    -- right_layout:add(batwidget)
    right_layout:add(mytextclock)
    right_layout:add(spr)
    right_layout:add(arrl_ld)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}



-- SHIFTY: initialize shifty
-- the assignment of shifty.taglist must always be after its actually
-- initialized with awful.widget.taglist.new()
shifty.taglist = mytaglist
shifty.init()

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 5, awful.tag.viewnext),
    awful.button({ }, 4, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, ",",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, ".",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    -- By direction client focus
    awful.key({ modkey }, "Down",
        function()
            awful.client.focus.bydirection("down")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "Up",
        function()
            awful.client.focus.bydirection("up")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "Left",
        function()
            awful.client.focus.bydirection("left")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "Right",
        function()
            awful.client.focus.bydirection("right")
            if client.focus then client.focus:raise() end
        end),

    -- Shifty: keybindings specific to shifty
    awful.key({modkey, "Shift"}, "d", shifty.del), -- delete a tag
    awful.key({modkey, "Shift"}, ",", shifty.send_prev), -- client to prev tag
    awful.key({modkey, "Shift"}, ".", shifty.send_next), -- client to next tag
    awful.key({modkey, "Control"},
              "n",
              function()
                  local t = awful.tag.selected()
                  local s = awful.util.cycle(screen.count(), awful.tag.getscreen(t) + 1)
                  awful.tag.history.restore()
                  t = shifty.tagtoscr(s, t)
                  awful.tag.viewonly(t)
              end),
    awful.key({modkey}, "a", shifty.add), -- creat a new tag
    awful.key({modkey, "Shift"}, "r", shifty.rename), -- rename a tag
    awful.key({modkey, "Shift"}, "a", -- nopopup new tag
    function()
        shifty.add({nopopup = true})
    end),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    -- Menus
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),
    awful.key({ modkey,           }, "i", function () instance = widgets.menu.clients({ width=450 }) end),
    awful.key({ modkey,           }, "p", function() menubar.show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ altkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ altkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),

    -- ALSA volume control
    awful.key({}, "#123",
        function ()
            awful.util.spawn("amixer -q set Master,0 1%+")
            awful.util.spawn("amixer -q set Master,1 1%+")
            volumewidget.update()
        end),
    awful.key({}, "#122",
        function ()
            awful.util.spawn("amixer -q set Master,0 1%-")
            awful.util.spawn("amixer -q set Master,1 1%-")
            volumewidget.update()
        end),
    awful.key({}, "#121",
        function ()
            awful.util.spawn("amixer -q set DAC,0 toggle")
            awful.util.spawn("amixer -q set DAC,1 toggle")
            volumewidget.update()
        end),

    -- MPD control
    awful.key({ altkey, "Control" }, "Up",
        function ()
            awful.util.spawn_with_shell("mpc toggle || ncmpcpp toggle || ncmpc toggle || pms toggle")
            mpdwidget.update()
        end),
    awful.key({ altkey, "Control" }, "Down",
        function ()
            awful.util.spawn_with_shell("mpc stop || ncmpcpp stop || ncmpc stop || pms stop")
            mpdwidget.update()
        end),
    awful.key({ altkey, "Control" }, "Left",
        function ()
            awful.util.spawn_with_shell("mpc prev || ncmpcpp prev || ncmpc prev || pms prev")
            mpdwidget.update()
        end),
    awful.key({ altkey, "Control" }, "Right",
        function ()
            awful.util.spawn_with_shell("mpc next || ncmpcpp next || ncmpc next || pms next")
            mpdwidget.update()
        end),

    -- Copy to clipboard
    awful.key({ modkey }, "c", function () os.execute("xsel -p -o | xsel -i -b") end),

    -- MM Play/Pause
    awful.key({ }, "#172",
        function ()
            awful.util.spawn_with_shell("mpc toggle || ncmpcpp toggle || ncmpc toggle || pms toggle")
            mpdwidget.update()
        end),

    awful.key({ modkey }, "space",  function () awful.util.spawn_with_shell("bash ~/.config/dmenu/dmenu-bind.sh")  end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(tmux) end),
    awful.key({ modkey,           }, "s", function () awful.util.spawn(file_manager) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Control" }, "c", function () awful.util.spawn_with_shell(chromium) end),
    awful.key({ modkey, "Control" }, "f", function () awful.util.spawn_with_shell(firefox) end),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    -- Scrot stuff
    awful.key({ "Control" }, "Print",  function ()
        awful.util.spawn_with_shell("scrot -ub '%Y-%m-%d--%s_$wx$h_scrot.png' -e 'mv $f ~/images/ &amp; viewnior ~/images/$f'")
    end),
    awful.key({ altkey }, "Print",  function ()
        awful.util.spawn_with_shell("scrot -s '%Y-%m-%d--%s_$wx$h_scrot.png' -e 'mv $f ~/images/ &amp; viewnior ~/images/$f'")
    end),
    awful.key({ }, "Print",  function ()
        awful.util.spawn_with_shell("scrot '%Y-%m-%d--%s_$wx$h_scrot.png' -e 'mv $f ~/images/ &amp; viewnior ~/images/$f'")
    end)

)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey,           }, "q",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey, "Shift"   }, "t",      function (c) shifty.create_titlebar(c) awful.titlebar(c) c.border_width = beautiful.border_width end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- SHIFTY: assign client keys to shifty for use in
-- match() function(manage hook)
shifty.config.clientkeys = clientkeys
shifty.config.modkey = modkey

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 12 do
    if i>10 then
        diff = 84
    else
        diff = 66
    end
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + diff,
                  function ()
                      awful.tag.viewonly(shifty.getpos(i))
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + diff,
                  function ()
                      awful.tag.viewtoggle(shifty.getpos(i))
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + diff,
                  function ()
                      if client.focus then
                          local t = shifty.getpos(i)
                          awful.client.movetotag(t)
                          awful.tag.viewonly(t)
                       end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + diff,
                  function ()
                      if client.focus then
                          awful.client.toggletag(shifty.getpos(i))
                      end
                  end))
end

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{

function make_titlebar(c)
	c.border_color = beautiful.titled_border
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.closebutton(c))
        left_layout:add(awful.titlebar.widget.maximizedbutton(c))
        --left_layout:add(awful.titlebar.widget.minimizedbutton(c))

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
	title:set_font(beautiful.sans_font) 
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c,{size=16}):set_widget(layout)
end

-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
       if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
           and awful.client.focus.filter(c) then
           client.focus = c
       end
    end)

    if not startup and not c.size_hints.user_position
       and not c.size_hints.program_position then
        awful.placement.no_overlap(c)
        awful.placement.no_offscreen(c)
    end
    if c.type == "dialog" then
	make_titlebar(c)
    end
end)

--client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
--client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- No border for maximized clients
client.connect_signal("focus",
    function(c)
        local clients = awful.client.visible(s)

        if c.maximized_horizontal == true and c.maximized_vertical == true then
            c.border_width = 0
            --c.border_color = beautiful.border_normal
        else
            c.border_width = beautiful.border_width
            if layout == "max" then
                c.border_color = beautiful.border_normal
            else
	    		if awful.client.floating.get(c) or awful.layout.get(c.screen) == awful.layout.suit.floating then
				make_titlebar(c)
			else
				if #clients == 1 then
                			c.border_color = beautiful.border_normal
				else
                			c.border_color = beautiful.border_focus
				end
            		end
    	    end
        end
    end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

