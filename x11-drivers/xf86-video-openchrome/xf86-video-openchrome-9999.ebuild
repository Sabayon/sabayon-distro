# Copyright 2004-2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# Must be before x-modular eclass is inherited
SNAPSHOT="yes"
XDPVER=-1

inherit eutils subversion x-modular

ESVN_REPO_URI="http://svn.openchrome.org/svn/trunk/"

DESCRIPTION="OpenChrome Project graphics driver"
HOMEPAGE="http://www.openchrome.org/"
SRC_URI=""
KEYWORDS="~amd64 ~ia64 ~sh ~x86 ~x86-fbsd"
IUSE="dri"

S="${WORKDIR}/trunk"

RDEPEND=">=x11-base/xorg-server-1.0.99"
DEPEND="${RDEPEND}
	x11-proto/fontsproto
	x11-proto/randrproto
	x11-proto/renderproto
	x11-proto/xextproto
	x11-proto/xproto
	!x11-drivers/xf86-video-via
	dri? ( x11-proto/xf86driproto
		x11-proto/glproto
		>=x11-libs/libdrm-2
		x11-libs/libX11 )"
		
CONFIGURE_OPTIONS="$(use_enable dri)"

src_unpack() {
	subversion_src_unpack
}

src_compile() {
	eautoreconf || die "eautoreconf failed"
	x-modular_src_compile	
}

pkg_setup() {
	if use dri && ! built_with_use x11-base/xorg-server dri; then
		die "Build x11-base/xorg-server with USE=dri."
	fi
}
