# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXft/libXft-2.1.11.ebuild,v 1.1 2006/10/22 18:03:06 joshuabaergen Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular flag-o-matic

DESCRIPTION="X.Org Xft library"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"

IUSE=""

RDEPEND="x11-libs/libXrender
	x11-libs/libX11
	x11-libs/libXext
	x11-proto/xproto
	>=media-libs/freetype-2.2.1
	>=media-libs/fontconfig-2.2"
DEPEND="${RDEPEND}"

pkg_setup() {
	# No such function yet
	# x-modular_pkg_setup

	# (#125465) Broken with Bdirect support
	filter-flags -Wl,-Bdirect
	filter-ldflags -Bdirect
	filter-ldflags -Wl,-Bdirect
}
src_unpack() {
	unpack ${A} && cd "${S}"/src/
	# New SPR patch
	epatch ${FILESDIR}/${P}-dont_interfere_with_newspr.patch || die
}
