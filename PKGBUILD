# Upstream URL: https://github.com/actionless/awesome_config


if [[ $(id -u) -eq 0 ]] && [[ -z "${NOARGB:-}" ]] ; then
	echo "INSTALL_NO_ARGB_SHORTCUTS [y/N]"
	read NOARGB
fi
INSTALL_NO_ARGB_SHORTCUTS=${NOARGB:-n}

pkgname=actionless_awesome_config_meta
conflicts=(awesome_config_actionless_meta)
pkgver=0.5
pkgrel=10
pkgdesc="Awesome config dependencies"
arch=('any')
url="https://github.com/actionless/awesome_config"
license=('GPLv3')
depends=(
	'awesome'
	'xorg-server'
	'lightdm'
	'lightdm-gtk-greeter'
	'bash'
	'coreutils'
	'librsvg' # SVG scaling
	'xcb-util-errors' # for pretty-printing of X11 errors

	'curl' # async image fallback
	'jq' # temperature widget
	'lm_sensors' # temperature widget
	'procps-ng' # mem and cpu widgets
	'brightnessctl' # brightness widget  @TODO: make it optional
	'pacman-contrib' # for updates widget  @TODO: make it optional
	'upower' # for battery widget  @TODO: make it optional

	# @TODO: make them optional?
	'xorg-xrdb' # reload Xresources on awesome WM reload
	'xorg-xset' # config/autorun: keyboard tweaks
	'xst-git' # default terminal
	'tmux' # default terminal multiplexer
	'scrot' # config/keys: default screenshot tool
	'slop' # config/keys: helper for default screenshot tool

	# @TODO: make them optional?
	'xsettingsd'
	'mate-polkit'
)
optdepends=(
	# < settings' daemons start
	#'mate-session-manager: mate session and settings manager'
	#'mate-polkit: mate polkit session'
	#
	#'gnome-settings-daemon: rc: alternative to xsettingsd'
	#'gnome-session: rc: alternative to lxsession to acompany gnome-settings-daemon'
	#
	#'lxsession-gtk3: gtk3 lxsession, lxsettings-daemon and lxpolkit'
	#'lxsession: lxsession, lxsettings-daemon and lxpolkit'
	# settings' daemons end>

	'picom: compositing + rounded borders'
	'plotinus: Ctrl+Shift+P menu in GTK+3 applications'
	'qt5ct: qt5 theme config'
	'qt6ct: qt6 theme config'

	'emote: config/autorun: emoji keyboard'
	'gnome-keyring: config/autorun'
	'gpaste: config/autorun'
	'kbdd-git: config/autorun: per-window keyboard layout'
	'udiskie: config/autorun: automounting'
	'unclutter: config/autorun: hide mouse pointer'
	'xscreensaver: config/autorun,config/keys'

	#'pulseaudio: config/autorun'
	#
	'gst-plugin-pipewire: new audio server'
	'lib32-pipewire: new audio server'
	'lib32-pipewire-jack: new audio server'
	'pipewire: new audio server'
	'pipewire-alsa: new audio server'
	'pipewire-jack: new audio server'
	'pipewire-pulse: new audio server'
	'wireplumber: new audio server'

	'autolight: config/autorun: adaptive brightness (LAPTOP)'
	'xfce4-power-manager: config/autorun,actionless/widgets/bat (LAPTOP)'
	'nut: config/autorun,actionless/widgets/bat(TBD) (UPS)'
	'nut-monitor: config/autorun (UPS)'
	'xorg-xinput: config/autorun: configure trackball'

	'pavucontrol: apw: default mixer'
	'nemo: default file manager'
	'bulky: bulk file renamer for nemo'
	'nitrogen: default wallpaper manager'
	'gnome-system-monitor: default action when click on cpu/mem widgets'

	'easyeffects: config/menu/audio'
	'qpwgraph: config/menu/audio'
	'ocenaudio: config/menu/audio'
)

package() {
	config_dir=$(pwd)/..
	if [[ ${INSTALL_NO_ARGB_SHORTCUTS} = 'y' ]] ; then
	install -Dm755 ${config_dir}/packaging/awesome_argb \
		"$pkgdir/usr/bin/awesome_argb"

	install -Dm755 ${config_dir}/packaging/awesome_no_argb \
		"$pkgdir/usr/bin/awesome_no_argb"

	install -Dm755 ${config_dir}/packaging/awesome_composite \
		"$pkgdir/usr/bin/awesome_composite"

	install -Dm644 ${config_dir}/packaging/awesome_argb.desktop \
		"$pkgdir/usr/share/xsessions/awesome_argb.desktop"

	install -Dm644 ${config_dir}/packaging/awesome_no_argb.desktop \
		"$pkgdir/usr/share/xsessions/awesome_no_argb.desktop"

	install -Dm644 ${config_dir}/packaging/awesome_composite.desktop \
		"$pkgdir/usr/share/xsessions/awesome_composite.desktop"

	install -Dm644 ${config_dir}/packaging/mate_awesome.desktop \
		"$pkgdir/usr/share/xsessions/mate_awesome.desktop"
	fi
}
