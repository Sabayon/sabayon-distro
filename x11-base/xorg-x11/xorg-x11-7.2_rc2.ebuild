# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-base/xorg-x11/xorg-x11-7.1.ebuild,v 1.9 2006/11/02 05:15:05 dberkholz Exp $

inherit eutils

DESCRIPTION="An X11 implementation maintained by the X.Org Foundation (meta package)"
HOMEPAGE="http://xorg.freedesktop.org"

LICENSE="as-is"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 sh sparc x86 ~x86-fbsd"

# Collision protect will scream bloody murder if we install over old versions
RDEPEND="!<=x11-base/xorg-x11-6.9"

# Server
RDEPEND="${RDEPEND}
	=x11-base/xorg-server-1.1.99.902"

# Common Applications
RDEPEND="${RDEPEND}
	>=x11-apps/mesa-progs-6.5
	>=x11-apps/setxkbmap-1.0.2
	>=x11-apps/xauth-1.0.1
	>=x11-apps/xhost-1.0.1
	>=x11-apps/xinit-1.0.3
	>=x11-apps/xmodmap-1.0.2
	>=x11-apps/xrandr-1.0.2"

# Common Libraries - move these to eclass eventually
RDEPEND="${RDEPEND}
	>=x11-libs/libSM-1.0.2
	>=x11-libs/libXcomposite-0.3.1
	>=x11-libs/libXcursor-1.1.8
	>=x11-libs/libXdamage-1.0.4
	>=x11-libs/libXfixes-4.0.3
	>=x11-libs/libXp-1
	>=x11-libs/libXv-1.0.2
	>=x11-libs/libXxf86dga-1.0.1
	>=x11-libs/libXinerama-1.0.1
	>=x11-libs/libXScrnSaver-1.1.1"

# Some fonts
RDEPEND="${RDEPEND}
	media-fonts/ttf-bitstream-vera
	>=media-fonts/font-bh-type1-1
	>=media-fonts/font-adobe-utopia-type1-1.0.1
	>=media-fonts/font-adobe-100dpi-1"

# Documentation
RDEPEND="${RDEPEND}
	>=app-doc/xorg-docs-1.2"

DEPEND="${RDEPEND}"

src_install() {
	# Make /usr/X11R6 a symlink to ../usr.
	dodir /usr
	dosym ../usr /usr/X11R6
}

pkg_preinst() {
	# Check for /usr/X11R6 -> /usr symlink
	if [[ -e "${ROOT}usr/X11R6" ]] &&
		[[ $(readlink "${ROOT}usr/X11R6") != "../usr" ]]; then
			eerror "${ROOT}usr/X11R6 isn't a symlink to ../usr. Please delete it."
			ewarn "First, save a list of all the packages installing there:"
			ewarn "		equery belongs ${ROOT}usr/X11R6 > usr-x11r6-packages"
			ewarn "This requires gentoolkit to be installed."
			die "${ROOT}usr/X11R6 is not a symlink to ../usr."
	fi

	# Filter out ModulePath line since it often holds a now-invalid path
	# Bug #112924
	# For RC3 - filter out RgbPath line since it also seems to break things
	XORGCONF="/etc/X11/xorg.conf"
	if [ -e ${XORGCONF} ]; then
		mkdir -p "${IMAGE}/etc/X11"
		sed "/ModulePath/d" ${XORGCONF}	> ${IMAGE}${XORGCONF}
		sed -i "/RgbPath/d" ${IMAGE}${XORGCONF}
	fi
}

pkg_postinst() {
	# I'm not sure why this was added, but we don't inherit x-modular
	# x-modular_pkg_postinst

	echo
	einfo "Please note that the xcursors are in ${ROOT}usr/share/cursors/${PN}."
	einfo "Any custom cursor sets should be placed in that directory."
	echo
	einfo "If you wish to set system-wide default cursors, please create"
	einfo "${ROOT}usr/local/share/cursors/${PN}/default/index.theme"
	einfo "with content: \"Inherits=theme_name\" so that future"
	einfo "emerges will not overwrite those settings."
	echo
	einfo "Listening on TCP is disabled by default with startx."
	einfo "To enable it, edit ${ROOT}usr/bin/startx."
	echo

	ewarn "Please read the modular X migration guide at"
	ewarn "http://www.gentoo.org/proj/en/desktop/x/x11/modular-x-howto.xml"
	echo
	einfo "If you encounter any non-configuration issues, please file a bug at"
	einfo "http://bugs.gentoo.org/enter_bug.cgi?product=Gentoo%20Linux"
	einfo "and attach ${ROOT}etc/X11/xorg.conf, ${ROOT}var/log/Xorg.0.log and emerge info"
	echo
	einfo "You can now choose which drivers are installed with the VIDEO_CARDS"
	einfo "and INPUT_DEVICES settings. Set these like any other Portage"
	einfo "variable in ${ROOT}etc/make.conf or on the command line."
	echo

	# (#76985)
	einfo "Visit http://www.gentoo.org/doc/en/index.xml?catid=desktop"
	einfo "for more information on configuring X."
	echo

	# Try to get people to read this, pending #11359
	ebeep 5
	epause 10
}
