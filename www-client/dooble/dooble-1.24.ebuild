# Copyright 1999-2011 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
inherit eutils qt4-r2 fdo-mime
DESCRIPTION="A Secure and Open Source Web Browser"
HOMEPAGE="http://dooble.sourceforge.net/"

SRC_URI="mirror://sourceforge/${PN}/Version%20${PV}/Dooble.d.tar.gz ->
${P}.tar.gz"

LICENSE="GPL-2 LGPL-2.1" # icon sets
SLOT="0"
KEYWORDS=""
IUSE=""
DEPEND="dev-libs/libgcrypt
	x11-libs/qt-core:4
	x11-libs/qt-gui:4
	x11-libs/qt-sql:4
	x11-libs/qt-webkit:4
"
RDEPEND="${DEPEND}"

S="${WORKDIR}/dooble.d/trunk/browser/"

PATCHES=( "${FILESDIR}/00-dooble-${PV}-icon-path.diff"
	"${FILESDIR}/01-dooble-${PV}-path-fix.diff" )

src_configure() {
	eqmake4 dooble.pro
}

src_compile() {
	emake || die "make failed"
}

# translations aren't visible unless the browser
# is called from /usr/share/dooble, needs fixing
src_install() {
	# Have todo it manually.... w00t
	dobin Dooble || die

	dosym /usr/share/dooble/Icons/32x32/dooble.png \
		/usr/share/pixmaps/dooble.png || die

	insinto /usr/share/dooble/Icons
	doins -r Icons/* || die

	insinto /usr/share/dooble/Images
	doins -r Images/* || die

	insinto /usr/share/dooble/Tab
	doins -r Tab/* || die

	insinto /usr/share/dooble/translations
	doins translations/*.qm || die

	domenu "${FILESDIR}"/dooble.desktop || die
}

pkg_postinst() {
	fdo-mime_desktop_database_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
}
