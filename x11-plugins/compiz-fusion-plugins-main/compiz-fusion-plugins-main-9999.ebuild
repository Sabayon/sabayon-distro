# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

MY_PN="${PN/compiz-fusion-}"

inherit git flag-o-matic autotools

EGIT_REPO_URI="git://anongit.opencompositing.org/fusion/${MY_PN}"

DESCRIPTION="Compiz Fusion Window Decorator Plugins (git)"
HOMEPAGE="http://opencompositing.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="~x11-wm/compiz-${PV}
	media-libs/jpeg
	>=gnome-base/librsvg-2.14.0
	~x11-libs/compiz-bcop-${PV}"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.19
	>=sys-devel/gettext-0.15
	>=dev-util/intltool-0.35"

S="${WORKDIR}/${MY_PN}"

pkg_setup() {
	if ! built_with_use x11-libs/cairo glitz ; then
		einfo "Please rebuild cairo with USE=\"glitz\""
		die "x11-libs/cairo missing glitz support"
	fi
}

src_compile() {
	filter-ldflags -znow -z,now
	filter-ldflags -Wl,-znow -Wl,-z,now

	eautoreconf || die "eautoreconf failed"
	glib-gettextize --copy --force || die "glib-gettextize failed"
	intltoolize --automake --copy --force || die "intloolize failed"

	econf || die "econf failed"
	emake -j1 || die "make failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
}

pkg_postinst() {
	ewarn "DO NOT report bugs to Gentoo's bugzilla"
	einfo "Please report all bugs to nesl247@gmail.com"
	einfo "Thank you on behalf of the Gentoo Xeffects team"
}
