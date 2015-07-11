# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils flag-o-matic toolchain-funcs

MY_PN=${PN/-gnome}
MY_P=${P/-gnome}
DESCRIPTION="GNOME 3 frontend for pinentry"
HOMEPAGE="http://gnupg.org/aegypten2/index.html"
SRC_URI="mirror://gnupg/${MY_PN}/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~arm ~amd64 ~x86"
IUSE="caps"

RDEPEND="
	~app-crypt/pinentry-base-${PV}
	!app-crypt/pinentry-base[static]
	app-crypt/libsecret
	>=app-eselect/eselect-pinentry-0.6
	caps? ( sys-libs/libcap )
"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

S="${WORKDIR}/${MY_P}"

src_configure() {
	[[ "$(gcc-major-version)" -ge 5 ]] && append-cxxflags -std=gnu++11

	econf \
		--disable-pinentry-tty \
		--disable-pinentry-gtk2 \
		--disable-pinentry-curses \
		--disable-fallback-curses \
		--disable-pinentry-qt4 \
		$(use_with caps libcap) \
		--enable-libsecret \
		--enable-pinentry-gnome3
}

src_install() {
	cd gnome3 && emake DESTDIR="${D}" install
}

pkg_postinst() {
	eselect pinentry set pinentry-gnome3
	# eselect pinentry update ifunset
}

pkg_postrm() {
	eselect pinentry update ifunset
}
