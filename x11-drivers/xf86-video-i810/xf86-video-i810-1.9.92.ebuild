# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-drivers/xf86-video-i810/xf86-video-i810-1.9.91.ebuild,v 1.1 2007/03/08 23:32:21 joshuabaergen Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"
XDPVER=-1

inherit x-modular

# This really needs a pkgmove...
SRC_URI="http://xorg.freedesktop.org/archive/individual/driver/xf86-video-intel-${PV}.tar.bz2"

S="${WORKDIR}/xf86-video-intel-${PV}"

DESCRIPTION="X.Org driver for Intel cards"

KEYWORDS="~amd64 ~arm ~ia64 ~sh ~x86 ~x86-fbsd"
IUSE="dri"

RDEPEND=">=x11-base/xorg-server-1.2.99.901
	x11-libs/libXvMC"
DEPEND="${RDEPEND}
	x11-proto/fontsproto
	x11-proto/randrproto
	x11-proto/renderproto
	x11-proto/xextproto
	x11-proto/xproto
	dri? ( x11-proto/xf86driproto
			>=x11-libs/libdrm-2.2
			x11-libs/libX11 )"

CONFIGURE_OPTIONS="$(use_enable dri)"

pkg_setup() {
	if use dri && ! built_with_use x11-base/xorg-server dri; then
		die "Build x11-base/xorg-server with USE=dri."
	fi
}
