# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/griffith/griffith-0.9.5.ebuild,v 1.6 2008/01/25 07:46:37 nelchael Exp $

inherit python

ARTWORK_PV="0.9.4"

DESCRIPTION="Movie collection manager"
HOMEPAGE="http://griffith.berlios.de/"
SRC_URI="http://download.berlios.de/griffith/${P/_/-}.tar.gz
	http://download.berlios.de/griffith/${PN}-extra-artwork-${ARTWORK_PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="doc spell"

RDEPEND="dev-python/imaging
	dev-python/pyxml
	>=dev-python/pygtk-2.6.1
	dev-python/pysqlite:2
	=dev-python/sqlalchemy-0.3*
	>=dev-python/reportlab-1.19
	spell? ( >=dev-python/gnome-python-extras-2.0 )"
DEPEND="${RDEPEND}
	doc? ( app-text/docbook2X )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i \
		-e 's/docbook2x-man/docbook2man.pl/' \
		-e 's#/pl/#/pl.UTF-8/#' \
		docs/*/Makefile || die "sed failed"
	sed -i \
		-e 's/latin1/iso-8859-1/' \
		docs/en/*.xml || die "sed failed"

	sed -i \
		-e 's/ISO-8859-1/UTF-8/' \
		lib/gconsole.py || die "sed failed"
}

src_compile() {
	# Nothing to compile and default `emake` spews an error message
	true
}

src_install() {
	use doc || sed -i -e '/docs/d' Makefile

	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog README TODO NEWS TRANSLATORS

	cd "${WORKDIR}/${PN}-extra-artwork-${ARTWORK_PV}/"
	emake DESTDIR="${D}" install || die "emake install artwork failed"
}

pkg_postinst() {
	python_mod_optimize "${ROOT}usr/share/${PN}/lib"
}

pkg_postrm() {
	python_mod_cleanup "${ROOT}usr/share/${PN}/lib"
}
