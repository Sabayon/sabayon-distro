# Copyright 1999-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
inherit eutils qt4-r2 fdo-mime
DESCRIPTION="A Secure and Open Source Web Browser that provides solid performance, stability, and cross-platform functionality."
HOMEPAGE="http://dooble.sourceforge.net/"

SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${P}.tar.gz"
RESTRICT="nomirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
DEPEND=""
RDEPEND=""

S="${WORKDIR}/browser"

PATCHES="${FILESDIR}/kubuntu_01_fix_iconset.diff
	${FILESDIR}/kubuntu_02_fix_paths.diff
	${FILESDIR}/kubuntu_03_fix_configs.diff"

src_configure() {
	eqmake4 dooble.pro
}

src_compile() {
	# Emake Fails so...
	make || die "make failed"
}

src_install() {
	# Have todo it manually.... w00t
	dobin Dooble

	dodir /usr/share/dooble/Icons
	# Remove Non Free Stuff
	cd Icons
	rm -rf redcats_blue/ everaldo/ FC-Schalke-04/
	# Do Icon
	dosym /usr/share/dooble/Icons/32x32/dooble.png /usr/share/pixmaps/dooble.png

	cd ${S}
	insinto /usr/share/dooble/Icons
	doins -r Icons/*

	dodir /usr/share/dooble/Images
	insinto /usr/share/dooble/Images
	doins -r Images/*

	dodir /usr/share/dooble/Tab
	insinto /usr/share/dooble/Tab
	doins -r Tab/*


	dodir /usr/share/dooble/qss
	insinto /usr/share/dooble/qss
	doins -r qss/*

	dodir /usr/share/applications
	insinto /usr/share/applications
	doins ${FILESDIR}/dooble.desktop
}

pkg_postinst() {
	fdo-mime_desktop_database_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
}
