# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit autotools flag-o-matic

DESCRIPTION="Compiz Fusion Window Decorator Extra Plugins"
HOMEPAGE="http://compiz-fusion.org"
SRC_URI="http://releases.compiz-fusion.org/${PV}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="gnome"
RESTRICT="mirror"

RDEPEND="
	>=gnome-base/librsvg-2.14.0
	media-libs/jpeg
	~x11-libs/compiz-bcop-${PV}
	~x11-plugins/compiz-fusion-plugins-main-${PV}
	~x11-wm/compiz-${PV}"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.19
	>=dev-util/intltool-0.35
	>=sys-devel/gettext-0.15
	gnome? ( gnome-base/gconf )"

pkg_setup() {
	if ! built_with_use x11-libs/cairo glitz ; then
		einfo "Please rebuild cairo with USE=\"glitz\""
		die "x11-libs/cairo missing glitz support"
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	use gnome || epatch "${FILESDIR}"/${PN}-no-gconf.patch

	if ! use gnome; then 
		eautoreconf || die "eautoreconf failed"
	fi
}

src_compile() {
	filter-ldflags -znow -z,now
	filter-ldflags -Wl,-znow -Wl,-z,now

	econf $(use_enable gnome gconf) || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS || die "dodoc failed"
}
