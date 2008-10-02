# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit autotools eutils

DESCRIPTION="Compiz Fusion Window Decorator Extra Plugins"
HOMEPAGE="http://compiz-fusion.org"
SRC_URI="http://releases.compiz-fusion.org/${PV}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gnome"
RESTRICT="mirror"

RDEPEND="
	>=gnome-base/librsvg-2.14.0
	media-libs/jpeg
	~x11-libs/compiz-bcop-${PV}
	~x11-plugins/compiz-fusion-plugins-main-${PV}
	~x11-wm/compiz-${PV}
"

DEPEND="${RDEPEND}
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.19
	>=sys-devel/gettext-0.15
	x11-libs/cairo[glitz]
	gnome? ( gnome-base/gconf )
"

src_prepare() {
	# reported upstream and applied to the git tree as
	# commit f60c5a0b22bc570763d297bc9c672ec80662e083
	epatch "${FILESDIR}"/${PN}-text-fix.patch
	use gnome || {
		epatch "${FILESDIR}"/${PN}-no-gconf.patch

		# required to apply the above patch
		intltoolize --copy --force || die "intltoolize failed"
		glib-gettextize --copy --force || die "glib-gettextize failed"
		eautoreconf || die "eautoreconf failed"
	}
}

src_configure() {
	econf $(use_enable gnome gconf) || die "econf failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}
