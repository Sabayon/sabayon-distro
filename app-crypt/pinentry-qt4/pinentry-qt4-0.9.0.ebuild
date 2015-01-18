# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit multilib eutils flag-o-matic

MY_PN=${PN/-qt4}
MY_P=${P/-qt4}
DESCRIPTION="Qt4 frontend for pinentry"
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
	>=dev-qt/qtgui-4.4.1:4
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

S=${WORKDIR}/${MY_P}

src_prepare() {
	#if use qt4; then
		local f
		for f in qt4/*.moc; do
			"${EPREFIX}"/usr/bin/moc ${f/.moc/.h} > ${f} || die
		done
	#fi
}

src_configure() {
	# Issues finding qt on multilib systems
	export QTLIB="${QTDIR}/$(get_libdir)"

	econf \
		--disable-pinentry-tty \
		--disable-pinentry-gtk2 \
		--disable-pinentry-curses \
		--disable-fallback-curses \
		--enable-pinentry-qt4 \
		$(use_with caps libcap)
}

src_compile() {
	emake AR="$(tc-getAR)"
}

src_install() {
	cd qt4 && emake DESTDIR="${D}" install
}

pkg_postinst() {
	eselect pinentry set pinentry-qt4
	# eselect pinentry update ifunset
}

pkg_postrm() {
	eselect pinentry update ifunset
}
