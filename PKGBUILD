# Upstream URL: https://github.com/actionless/awesome_config


if [[ $(id -u) -eq 0 ]] && [[ -z "${NOARGB:-}" ]] ; then
	echo "INSTALL_NO_ARGB_SHORTCUTS [y/N]"
	read NOARGB
fi
INSTALL_NO_ARGB_SHORTCUTS=${NOARGB:-n}

pkgname=awesome_config_actionless_meta
pkgver=0.1
pkgrel=2
pkgdesc="Awesome config dependencies"
arch=('x86_64' 'i686')
url="https://github.com/actionless/awesome_config"
license=('GPLv3')
depends=(
	'awesome'
	'bash'
	'coreutils'
	'imagemagick'  # music widget (album cover)
	'lm_sensors'  # temperature widget
	'lxsession-gtk3' # or 'lxsession'  # needed for lxpolkit
	'procps-ng'
	'qt5-tools'  # for qdbus
	'scrot'
	'tmux'
	'upower'  # for battery widget
	'xorg-xrdb'
	'xorg-xset'
	'xsettingsd'  # or use lxsettings-daemon from lxsession
	'xst-git'  # default terminal
)
optdepends=(
	#'gnome-settings-daemon: rc: alternative to xsettingsd'
	#'gnome-session: rc: alternative to lxsession to acompany gnome-settings-daemon'
	'gnome-keyring: config/autorun'
	'gpaste: config/autorun'
	'pavucontrol: apw: default mixer'
	'pulseaudio: config/autorun'
	'kbdd-git: config/autorun: per-window keyboard layout'
	'plotinus: Ctrl+Shift+P menu in GTK+3 applications'
	'qt5ct: qt5 theme'
	#'unclutter: config/autorun: hide mouse pointer'
	'unclutter-xfixes-git: config/autorun: hide mouse pointer'
	'xfce4-power-manager: config/autorun,actionless/widgets/bat'
	'xorg-xinput: config/autorun: configure trackball'
	'xscreensaver: config/autorun,config/keys'
	'nemo: default file manager'
	'nitrogen: default wallpaper manager'
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
	fi
}
