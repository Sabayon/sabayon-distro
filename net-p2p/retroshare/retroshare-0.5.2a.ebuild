# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit eutils versionator multilib

MY_PN="RetroShare-v"
MY_P="${MY_PN}${PV}"
MY_SLOT=$(get_version_component_range 1-3)
DESCRIPTION="P2P private sharing application"
HOMEPAGE="http://retroshare.sourceforge.net"
SRC_URI="mirror://sourceforge/retroshare/${MY_P}.tar.gz"
S="${WORKDIR}/trunk/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug cli +qt4"

RDEPEND="app-crypt/gpgme
	dev-libs/libgpg-error
	gnome-base/libgnome-keyring
	net-libs/libupnp
	x11-libs/qt-core:4
	qt4? (
		x11-libs/qt-gui:4
		x11-libs/qt-opengl:4
	)
"
DEPEND="${RDEPEND}
	!net-p2p/retroshare-gui
	!net-p2p/retroshare-cli"

REQUIRED_USE="|| ( cli qt4 )"

src_prepare() {
	epatch "${FILESDIR}/retroshare-0.5.1d.patch"
	sed -i -e \
		"s|/usr/lib/retroshare/extensions/|/usr/$(get_libdir)/${PV}/extensions/|" \
		libretroshare/src/rsserver/rsinit.cc \
		|| die "sed failed"
}

src_compile() {
	cd "${WORKDIR}/trunk/libbitdht/src"
	qmake -makefile libbitdht.pro || die
	emake

	cd "${WORKDIR}/trunk/libretroshare/src"
	qmake -makefile libretroshare.pro || die
	emake

	if use qt4; then
		cd "${WORKDIR}/trunk/retroshare-gui/src"
		qmake -makefile RetroShare.pro || die
		emake
	fi

	if use cli; then
		cd "${WORKDIR}/trunk/retroshare-nogui/src"
		qmake -makefile retroshare-nogui.pro || die
		emake
	fi
}

src_install() {
	if use qt4; then
		cd "${WORKDIR}/trunk/retroshare-gui/src"
		emake INSTALL_ROOT="${D}" install || die
	fi

	if use cli; then
		cd "${WORKDIR}/trunk/retroshare-nogui/src"
		emake INSTALL_ROOT="${D}" install || die
	fi
}

pkg_postinst() {
	use qt4 && einfo "The GUI executable name is: RetroShare"
	use cli && einfo "The console executable name is: retroshare-cli"
}
