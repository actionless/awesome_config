local spawn = require("awful.spawn")
local with_shell = spawn.with_shell

local run_once = require("actionless.util.spawn").run_once


local autorun = {}

function autorun.init(awesome_context)

  --with_shell('pgrep vmtoolsd >/dev/null && /usr/bin/vmware-user-suid-wrapper')
  --with_shell(os.getenv('HOME').."/.screenlayout/awesome.sh")
  --with_shell('xinput disable "ELAN Touchscreen"')

  local sanwa_pad = true

  --local kensington = nil
  --if kensington then  -- detect it after asynchronously reading `xinput list` output
    --legacy evdev-based:
    --local kensinton =12
    --with_shell('xinput set-prop ' .. kensington .. ' "Device Accel Velocity Scaling" 26')
    --with_shell('xinput set-prop ' .. kensington .. ' "Evdev Middle Button Emulation" 1')
    --with_shell('xinput set-prop ' .. kensington .. ' "Evdev Wheel Emulation" 1')
    --with_shell('xinput set-prop ' .. kensington .. ' "Evdev Wheel Emulation Button" 3')
    --with_shell('xinput set-prop ' .. kensington .. ' "Evdev Wheel Emulation Inertia" 20')
    --with_shell('xinput set-prop ' .. kensington .. ' "Evdev Wheel Emulation Timeout" 200')
  --end

  if sanwa_pad then  -- detect it after asynchronously reading `xinput list` output
    --legacy evdev-based:
    --local sanwa_big = 12
    --with_shell('xinput set-prop ' .. sanwa_pad .. ' "Device Accel Velocity Scaling" 26')
    --with_shell('xinput set-prop ' .. sanwa_pad .. ' "Evdev Middle Button Emulation" 1')
    --with_shell('xinput set-prop ' .. sanwa_pad .. ' "Evdev Wheel Emulation" 1')
    --with_shell('xinput set-prop ' .. sanwa_pad .. ' "Evdev Wheel Emulation Button" 2')
    --with_shell('xinput set-prop ' .. sanwa_pad .. ' "Evdev Wheel Emulation Timeout" 200')
    ----wheel inertia:
    ----default:
    --with_shell('xinput set-prop ' .. sanwa_pad .. ' "Evdev Wheel Emulation Inertia" 350')
    ----from workstation:
    ----with_shell('xinput set-prop ' .. sanwa_pad .. ' "Evdev Wheel Emulation Inertia" 50')
    ----from vm:
    ----with_shell('xinput set-prop ' .. sanwa_pad .. ' "Evdev Wheel Emulation Inertia" 170')


    --libinput-based:
    spawn{
      'xinput', 'set-prop', 'HID 04d9:1166',
      "libinput Scroll Method Enabled", '0', '0', '1'
    }
  end

  -- keyboard settings:
  spawn{"xset", "r", "rate", "250", "25"}
  --spawn{"xset", "r", "rate", "175", "17"}
  --spawn{"xset", "r", "rate", "250", "10"}
  spawn{"xset", "b", "off"} -- turn off beep
  spawn{
    "setxkbmap",
    "-layout", "us,ru",
    "-variant", ",winkeys",
    "-option", "grp:caps_toggle,grp_led:caps,terminate:ctrl_alt_bksp,compose:ralt"
 }

  --run_once{"redshift"}
  --run_once{awesome_context.cmds.compositor}

  with_shell("start-pulseaudio-x11")  -- yes, with shell

  for _, item in ipairs(awesome_context.autorun) do
    with_shell(item)
  end

  local delayed_call = require("gears.timer").delayed_call
  delayed_call(function()
    --spawn{"gpaste-client", "start"}
    --with_shell("eval $(gnome-keyring-daemon -s --components=pkcs11,secrets,ssh,gpg)")
    run_once{"xfce4-power-manager"}
    --run_once{"xscreensaver -no-splash"}
    --run_once{"unclutter -root"}
    run_once{"unclutter"}
    --run_once{"touchegg"}
    --run_once{"megasync"}
    --run_once{"dropbox"}
    run_once{"kbdd"}
    --run_once("mopidy -q 2>&1 >> $HOME/.cache/mopidy.log")
    --run_once{"urxvtd"}
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
