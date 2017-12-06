local awful = require("awful")

local run_once = require("actionless.util.spawn").run_once


local autorun = {}

function autorun.init(awesome_context)

  awful.spawn.with_shell('pgrep vmtoolsd >/dev/null && /usr/bin/vmware-user-suid-wrapper')
  --awful_spawn.with_shell(os.getenv('HOME').."/.screenlayout/awesome.sh")

  --local kensinton =12
  local kensington = nil
  --local sanwa_pad = 12
  local sanwa_pad = nil
  --local sanwa_big = 12

  -- Kensington
  if kensington then
    awful.spawn.with_shell('xinput set-prop ' .. kensington .. ' "Device Accel Velocity Scaling" 26')
    awful.spawn.with_shell('xinput set-prop ' .. kensington .. ' "Evdev Middle Button Emulation" 1')
    awful.spawn.with_shell('xinput set-prop ' .. kensington .. ' "Evdev Wheel Emulation" 1')
    awful.spawn.with_shell('xinput set-prop ' .. kensington .. ' "Evdev Wheel Emulation Button" 3')
    awful.spawn.with_shell('xinput set-prop ' .. kensington .. ' "Evdev Wheel Emulation Inertia" 20')
    awful.spawn.with_shell('xinput set-prop ' .. kensington .. ' "Evdev Wheel Emulation Timeout" 200')
  end

  -- Sanwa
  if sanwa_pad then
    awful.spawn.with_shell('xinput set-prop ' .. sanwa_pad .. ' "Device Accel Velocity Scaling" 26')
    awful.spawn.with_shell('xinput set-prop ' .. sanwa_pad .. ' "Evdev Middle Button Emulation" 1')
    awful.spawn.with_shell('xinput set-prop ' .. sanwa_pad .. ' "Evdev Wheel Emulation" 1')
    awful.spawn.with_shell('xinput set-prop ' .. sanwa_pad .. ' "Evdev Wheel Emulation Button" 2')
    awful.spawn.with_shell('xinput set-prop ' .. sanwa_pad .. ' "Evdev Wheel Emulation Timeout" 200')

    --from workstation:
    --awful.spawn.with_shell('xinput set-prop ' .. sanwa_pad .. ' "Evdev Wheel Emulation Inertia" 50')
    --from vm:
    --awful.spawn.with_shell('xinput set-prop ' .. sanwa_pad .. ' "Evdev Wheel Emulation Inertia" 170')
    awful.spawn.with_shell('xinput set-prop ' .. sanwa_pad .. ' "Evdev Wheel Emulation Inertia" 350')
  end

  -- keyboard settings:
  awful.spawn.with_shell("xset r rate 250 25")
  --awful.spawn.with_shell("xset r rate 175 17")
  --awful.spawn.with_shell("xset r rate 250 10")
  awful.spawn.with_shell("xset b off") -- turn off beep
  awful.spawn.with_shell(
   "setxkbmap -layout us,ru -variant ,winkeys -option grp:caps_toggle,grp_led:caps,terminate:ctrl_alt_bksp,compose:ralt"
  )

  --run_once("redshift")
  --run_once(awesome_context.cmds.compositor)

  run_once("pulseaudio")
  awful.spawn.with_shell("start-pulseaudio-x11")

  for _, item in ipairs(awesome_context.autorun) do
    awful.spawn.with_shell(item)
  end

  local delayed_call = require("gears.timer").delayed_call
  delayed_call(function()
    awful.spawn.spawn("gpaste-client start")
    --awful.spawn.with_shell("eval $(gnome-keyring-daemon -s --components=pkcs11,secrets,ssh,gpg)")
    run_once("xfce4-power-manager")
    --run_once("xscreensaver -no-splash")
    --run_once("unclutter -root")
    run_once("unclutter")
    --run_once("touchegg")
    --run_once("megasync")
    --run_once("dropbox")
    run_once("kbdd")
    --run_once("mopidy -q 2>&1 >> $HOME/.cache/mopidy.log")
    --run_once("urxvtd")
  end)


  --local gears_timer = require("gears.timer")
  --local delayed_call = gears_timer.delayed_call
  --delayed_call(function()
    --local wlppr = require('actionless.wlppr')
    --gears_timer({
      --callback=wlppr.load_new,
      --timeout=701,
      --autostart=true,
      --call_now=false,
    --})
    --gears_timer({
      --callback=wlppr.change_wallpaper,
      --timeout=500,
      --autostart=true,
      --call_now=true,
    --})
    ----gears_timer({
      ----callback=wlppr.change_wallpaper_best,
      ----timeout=300,
      ----autostart=true,
      ----call_now=true,
    ----})
  --end)

end

return autorun
