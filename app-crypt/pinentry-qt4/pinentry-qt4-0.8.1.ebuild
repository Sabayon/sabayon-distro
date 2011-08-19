# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

MY_PN=${PN/-qt4}
MY_P=${P/-qt4}
DESCRIPTION="Qt4 frontend for pinentry"
HOMEPAGE="http://gnupg.org/aegypten2/index.html"
SRC_URI="mirror://gnupg/${MY_PN}/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="caps"

RDEPEND="~app-crypt/pinentry-${PV}
	app-admin/eselect-pinentry
	>=x11-libs/qt-gui-4.4.1
	caps? ( sys-libs/libcap )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	local file
	for file in qt4/*.moc; do
		"${EPREFIX}"/usr/bin/moc ${file/.moc/.h} > ${file} || die
	done
}

src_configure() {
	# Issues finding qt on multilib systems
	export QTLIB="${QTDIR}/$(get_libdir)"

	econf \
		--disable-dependency-tracking \
		--enable-maintainer-mode \
		--disable-pinentry-gtk \
		--disable-pinentry-gtk2 \
		--disable-pinentry-qt \
		--disable-pinentry-curses \
		--disable-fallback-curses \
		--enable-pinentry-qt4 \
		$(use_with caps libcap)
}

src_install() {
	cd qt4 && emake DESTDIR="${D}" install || die "make install failed"
}

pkg_postinst() {
	eselect pinentry update ifunset
}

pkg_postrm() {
	eselect pinentry update ifunset
}
