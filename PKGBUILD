# Upstream URL: https://github.com/actionless/awesome_config


if [[ $(id -u) -eq 0 ]] && [[ -z "${NOARGB:-}" ]] ; then
	echo "INSTALL_NO_ARGB_SHORTCUTS [y/N]"
	read NOARGB
fi
INSTALL_NO_ARGB_SHORTCUTS=${NOARGB:-n}

pkgname=actionless_awesome_config_meta
conflicts=(awesome_config_actionless_meta)
pkgver=0.3
pkgrel=1
pkgdesc="Awesome config dependencies"
arch=('x86_64' 'i686')
url="https://github.com/actionless/awesome_config"
license=('GPLv3')
depends=(
	'awesome'
	'xorg-server'
	'lightdm'
	'lightdm-gtk-greeter'
	'bash'
	'coreutils'

	'lm_sensors'  # temperature widget
	'jq'  # temperature widget
	'procps-ng'  # mem and cpu widgets
	'upower'  # for battery widget
	'pacman-contrib'  # for updates widget

	'xorg-xrdb'  # reload Xresources on awesome WM reload
	'xorg-xset'  # config/autorun: keyboard tweaks
	'xst-git'  # default terminal
	'tmux'  # default terminal multiplexer
	'scrot'  # config/keys: default screenshot tool
	'slop'  # config/keys: helper for default screenshot tool

	'xsettingsd'  # or use lxsettings-daemon from lxsession
	#'lxsession-gtk3' # or 'lxsession'  # needed for lxpolkit
)
optdepends=(
	'mate-session-manager: mate session'
	'mate-polkit: mate session'

	#'gnome-settings-daemon: rc: alternative to xsettingsd'
	#'gnome-session: rc: alternative to lxsession to acompany gnome-settings-daemon'

	'pavucontrol: apw: default mixer'
	'plotinus: Ctrl+Shift+P menu in GTK+3 applications'
	'qt5ct: qt5 theme'
	'nemo: default file manager'
	'nitrogen: default wallpaper manager'
	'gnome-system-monitor: default action when click on cpu/mem widgets'

	'gnome-keyring: config/autorun'
	'gpaste: config/autorun'
	'pulseaudio: config/autorun'
	'kbdd-git: config/autorun: per-window keyboard layout'
	#'unclutter: config/autorun: hide mouse pointer'
	'unclutter-xfixes-git: config/autorun: hide mouse pointer'
	'xfce4-power-manager: config/autorun,actionless/widgets/bat'
	'xorg-xinput: config/autorun: configure trackball'
	'xscreensaver: config/autorun,config/keys'
	'autolight: config/autorun: laptop: adaptive brightness'
)

package() {
  config_dir=$(pwd)/..
  if [[ ${INSTALL_NO_ARGB_SHORTCUTS} = 'y' ]] ; then
	  install -Dm755 ${config_dir}/packaging/awesome_argb \
		"$pkgdir/usr/bin/awesome_argb"

	  install -Dm755 ${config_dir}/packaging/awesome_no_argb \
		"$pkgdir/usr/bin/awesome_no_argb"

	  install -Dm644 ${config_dir}/packaging/awesome_argb.desktop \
		"$pkgdir/usr/share/xsessions/awesome_argb.desktop"

	  install -Dm644 ${config_dir}/packaging/awesome_no_argb.desktop \
		"$pkgdir/usr/share/xsessions/awesome_no_argb.desktop"

	  install -Dm644 ${config_dir}/packaging/mate_awesome.desktop \
		"$pkgdir/usr/share/xsessions/mate_awesome.desktop"

	  install -Dm644 ${config_dir}/packaging/awesome_argb.desktop \
		"$pkgdir/usr/share/xsession_current/awesome_argb.desktop"
	fi
}
