local spawn = require("awful.spawn")
local with_shell = spawn.with_shell
local gears_timer = require("gears.timer")
local delayed_call = gears_timer.delayed_call

local run_once = require("actionless.util.spawn").run_once


local autorun = {}

function autorun.init(awesome_context)

  --with_shell('pgrep vmtoolsd >/dev/null && /usr/bin/vmware-user-suid-wrapper')
  --with_shell(os.getenv('HOME').."/.screenlayout/awesome.sh")
  --with_shell('xinput disable "ELAN Touchscreen"')


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

  spawn{"xset", "b", "off"} -- turn off beep

  -- keyboard settings:
  spawn{"xset", "r", "rate", "250", "25"}
  --spawn{"xset", "r", "rate", "175", "17"}
  --spawn{"xset", "r", "rate", "250", "10"}
  ---- replaced with: /etc/lightdm/lightdm.conf [Seat:*]xserver-command=X -ardelay 250 -arinterval 40

 -- spawn{
 --   "setxkbmap",
 --   "-layout", "us,ru",
 ----   "-variant", ",winkeys",
 --   "-variant", ",ruu",
 --   --"-option",
 --   --"grp:caps_toggle,grp_led:caps,terminate:ctrl_alt_bksp,compose:ralt",
 --   "-option",
 --   "grp:shifts_toggle,grp_led:caps,terminate:ctrl_alt_bksp,compose:ralt,caps:escape_shifted_capslock,caps:escape",
 --}
  ---- replaced with: /etc/X11/xorg.conf.d/90-keyboard.conf

  --run_once{"redshift"}
  --run_once{awesome_context.cmds.compositor}

  with_shell("start-pulseaudio-x11 || pulseaudio")

  for _, item in ipairs(awesome_context.autorun) do
    with_shell(item)
  end

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
    run_once{"udiskie", "--appindicator"}
    run_once{"emote"}
  end)


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
