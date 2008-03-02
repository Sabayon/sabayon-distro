# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-drivers/xf86-video-via/xf86-video-via-0.2.2.ebuild,v 1.5 2007/05/05 18:33:51 dang Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"
XDPVER=-1
inherit x-modular
DESCRIPTION="VIA unichrome graphics driver"
KEYWORDS="amd64 ia64 ~sh x86 ~x86-fbsd"
SRC_URI="http://www.openchrome.org/releases/${P}.tar.gz"
IUSE="dri"
RESTRICT="nomirror"
RDEPEND=">=x11-base/xorg-server-1.0.99
		x11-libs/libXvMC"
DEPEND="${RDEPEND}
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

pkg_setup() {
	if use dri && ! built_with_use x11-base/xorg-server dri; then
		die "Build x11-base/xorg-server with USE=dri."
	fi
}

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch "${FILESDIR}"/${P}.diff.gz
	epatch "${S}"/xserver-xorg-video-openchrome-${PV}/debian/patches/01_gen_pci_ids.diff || die "failed patching"
	x-modular_src_unpack || die "x-modular_src_unpack failed"
}
