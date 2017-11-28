awesome wm config
==============

#### Installation

Works with Awesome WM 4.2

```sh
cd ~/.config/
git clone https://github.com/actionless/awesome_config.git -b devel awesome
cd awesome
git submodule init
git submodule update
# optionally copy config with machine-specific variables
cp config/local.lua.example config/local.lua
# on Arch Linux or Manjaro:
makepkg -fi --syncdeps
```

 - [lcars](http://i.imgur.com/8C6l5ko.gifv) layout
 - in `*-xresources` themes panel [adapts](http://imgur.com/a/qIAAa) for current xrdb theme

`themes/lcars-xresourecs-hidpi/theme.lua`
![Screenshot](https://github.com/actionless/awesome_config/raw/devel/screenshots/screenshot_new.png "Screenshot")

`themes/twmish/theme.lua` and [this](https://github.com/actionless/oomox/blob/master/colors/retro/classic_x_new) oomox theme
![Screenshot](https://i.redd.it/hre8tx9vynyx.png "Screenshot")

`themes/gtk/theme.lua` and [this](https://github.com/actionless/oomox/blob/master/colors/retro/uzi) oomox theme
![Screenshot](http://i.imgur.com/fhl6wYp.png "Screenshot")

Lcars layout:
![Screenshot](https://raw.githubusercontent.com/actionless/awesome_config/devel/screenshots/screenshot.png "Screenshot")

The same screenshot with other colors set in ~/.Xresources:


#### Widget popups

@TODO: upload newer screenshots

##### CPU
Shows results from top for last second

![cpu](https://raw.githubusercontent.com/actionless/awesome_config/devel/screenshots/cpu.png "cpu")

##### Memory
Shows unified percentage of used memory for all applications' processes

![mem](https://raw.githubusercontent.com/actionless/awesome_config/devel/screenshots/mem.png "mem")

##### Systray toggle (like in windows xp :) )
![st](http://i.imgur.com/HFfERGC.png "st")

##### Calendar (taken from Lain widgetkit)
![cal](http://i.imgur.com/pB5n12b.png "cal")

##### Music (supports mpd, cmus, clementine, spotify at the _same_ time)
![music](http://i.imgur.com/W7ur5SQ.png "music")

Battery widget shows up only when it draining/charging.
Indicators are changing color to brighter one to show changed state (like too big load average or too low battery).
@TODO: upload screens.
