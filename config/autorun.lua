local awful = require("awful")

local run_once = require("actionless.helpers").run_once


local autorun = {}

function autorun.init(status)


--awful.util.spawn_with_shell("eval $(gnome-keyring-daemon -s --components=pkcs11,secrets,ssh,gpg)")
--awful.util.spawn_with_shell("/home/lie/.screenlayout/awesome.sh")
awful.util.spawn_with_shell("xset r rate 250 25")
awful.util.spawn_with_shell("xset b off")
run_once(status.cmds.compositor)
run_once("dropboxd")
--run_once("xscreensaver -no-splash")
run_once("unclutter")
run_once("gxkb")


end
return autorun
