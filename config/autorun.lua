local awful = require("awful")

local run_once = require("actionless.helpers").run_once


local autorun = {}

function autorun.init(awesome_context)

  --awful.util.spawn_with_shell("eval $(gnome-keyring-daemon -s --components=pkcs11,secrets,ssh,gpg)")
  --awful.util.spawn_with_shell("/home/lie/.screenlayout/awesome.sh")
  --run_once("redshift")
  awful.util.spawn_with_shell("xset r rate 250 25")
  awful.util.spawn_with_shell("xset b off")
  --run_once(awesome_context.cmds.compositor)
  run_once("start-pulseaudio-x11")
  run_once("xfce4-power-manager")
  run_once("dropboxd")
  run_once("megasync")
  --run_once("xscreensaver -no-splash")
  run_once("unclutter")
  run_once("setxkbmap -layout us,ru -variant ,winkeys -option grp:caps_toggle,grp_led:scroll,terminate:ctrl_alt_bksp,compose:ralt")
  run_once("kbdd")
  --run_once("urxvtd")

  for _, item in ipairs(awesome_context.autorun) do
    awful.util.spawn_with_shell(item)
  end

end

return autorun
