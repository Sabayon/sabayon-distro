# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils flag-o-matic

MY_PN=${PN/-gtk2}
MY_P=${P/-gtk2}
DESCRIPTION="Gtk+2 frontend for pinentry"
HOMEPAGE="http://gnupg.org/aegypten2/index.html"
SRC_URI="mirror://gnupg/${MY_PN}/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~arm ~amd64 ~x86"
IUSE="caps"

RDEPEND="
	~app-crypt/pinentry-base-${PV}
	!app-crypt/pinentry-base[static]
	caps? ( sys-libs/libcap )
	x11-libs/gtk+:2
"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

S="${WORKDIR}/${MY_P}"

src_configure() {
	econf \
		--disable-pinentry-tty \
		--enable-pinentry-gtk2 \
		--disable-pinentry-curses \
		--disable-fallback-curses \
		--disable-pinentry-qt4 \
		$(use_with caps libcap)
}

src_compile() {
	emake AR="$(tc-getAR)"
}

src_install() {
	cd gtk+-2 && emake DESTDIR="${D}" install
}

pkg_postinst() {
	eselect pinentry set pinentry-gtk-2
	# eselect pinentry update ifunset
}

pkg_postrm() {
	eselect pinentry update ifunset
}
