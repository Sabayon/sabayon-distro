# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# Must be before x-modular eclass is inherited
SNAPSHOT="yes"
XDPVER=-1

inherit x-modular eutils

DESCRIPTION="Unichrome Project graphics driver"
HOMEPAGE="http://unichrome.sourceforge.net/"
SRC_URI="mirror://sourceforge/unichrome/${P}.tar.gz"
KEYWORDS="~amd64 ~ia64 ~sh ~x86 ~x86-fbsd"
IUSE="dri"

RDEPEND=">=x11-base/xorg-server-1.0.99"
DEPEND="${RDEPEND}
	!x11-drivers/xf86-video-via
	x11-proto/fontsproto
	x11-proto/randrproto
	x11-proto/renderproto
	x11-proto/xextproto
	x11-proto/xproto
	dri? ( x11-proto/xf86driproto
		x11-proto/glproto
		>=x11-libs/libdrm-2
		x11-libs/libX11 )"
		
CONFIGURE_OPTIONS="$(use_enable dri)"

src_unpack() {
	x-modular_src_unpack
	epatch ${FILESDIR}/${P}-ubuntu.patch
}

pkg_setup() {
	if use dri && ! built_with_use x11-base/xorg-server dri; then
		die "Build x11-base/xorg-server with USE=dri."
	fi
}
