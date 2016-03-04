local awful = require("awful")

local run_once = require("actionless.helpers").run_once


local autorun = {}

function autorun.init(awesome_context)

  --awful.spawn.with_shell("eval $(gnome-keyring-daemon -s --components=pkcs11,secrets,ssh,gpg)")
  --awful.spawn.with_shell("/home/lie/.screenlayout/awesome.sh")
  --run_once("redshift")
  awful.spawn.with_shell("xset r rate 250 25")
  --awful.spawn.with_shell("xset r rate 250 10")
  awful.spawn.with_shell("xset b off") -- turn off beep
  --run_once(awesome_context.cmds.compositor)
  awful.spawn.with_shell("xsettingsd")
  run_once("pulseaudio")
  awful.spawn.with_shell("start-pulseaudio-x11")
  run_once("xfce4-power-manager")
  run_once("dropbox")
  run_once("megasync")
  --run_once("xscreensaver -no-splash")
  run_once("unclutter -root")
  run_once("setxkbmap -layout us,ru -variant ,winkeys -option grp:caps_toggle,grp_led:scroll,terminate:ctrl_alt_bksp,compose:ralt")
  run_once("kbdd")
  --run_once("mopidy -q 2>&1 >> $HOME/.cache/mopidy.log")
  --run_once("urxvtd")

  for _, item in ipairs(awesome_context.autorun) do
    awful.spawn.with_shell(item)
  end

end

return autorun
