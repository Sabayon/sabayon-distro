# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit multilib eutils flag-o-matic

MY_PN=${PN/-gtk2}
MY_P=${P/-gtk2}
DESCRIPTION="Gtk+2 frontend for pinentry" # less than 100 chars!
HOMEPAGE="http://gnupg.org/aegypten2/index.html"
SRC_URI="mirror://gnupg/${MY_PN}/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="caps"

RDEPEND="~app-crypt/pinentry-${PV}
	app-admin/eselect-pinentry
	x11-libs/gtk+:2
	caps? ( sys-libs/libcap )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

S="${WORKDIR}/${MY_P}"

src_configure() {
	econf \
		--disable-dependency-tracking \
		--enable-maintainer-mode \
		--disable-pinentry-gtk \
		--enable-pinentry-gtk2 \
		--disable-pinentry-qt \
		--disable-pinentry-curses \
		--disable-fallback-curses \
		--disable-pinentry-qt4 \
		$(use_with caps libcap)
}

src_install() {
	cd gtk+-2 && emake DESTDIR="${D}" install || die "make install failed"
}

pkg_postinst() {
	eselect pinentry update ifunset
}

pkg_postrm() {
	eselect pinentry update ifunset
}
