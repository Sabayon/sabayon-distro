# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit git autotools

EGIT_REPO_URI="git://anongit.opencompositing.org/fusion/decorators/${PN}"

DESCRIPTION="Emerald Window Decorator (git)"
HOMEPAGE="http://opencompositing.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

PDEPEND="~x11-themes/emerald-themes-${PV}"

RDEPEND=">=x11-libs/gtk+-2.8.0
	>=x11-libs/libwnck-2.14.2
	~x11-wm/compiz-${PV}"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.19
	>=sys-devel/gettext-0.15
	>=dev-util/intltool-0.35"

S="${WORKDIR}/${PN}"

src_compile() {
	eautoreconf || die "eautoreconf failed"
	glib-gettextize --copy --force || die
	intltoolize --automake --copy --force || die

	econf --disable-mime-update || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
}

pkg_postinst() {
	ewarn "DO NOT report bugs to Gentoo's bugzilla"
	einfo "Please report all bugs to nesl247@gmail.com"
	einfo "Thank you on behalf of the Gentoo Xeffects team"
}
