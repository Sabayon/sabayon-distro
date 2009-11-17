# Copyright 2009 Sabayon Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils fdo-mime

MY_P=QuantZ
S=${WORKDIR}/${MY_P}

DESCRIPTION="A 'unique puzzle action game' developed by Gamerizon"
HOMEPAGE="http://www.gamerizon.com/"
SRC_URI="http://dl.dropbox.com/u/2159868/QuantZ-beta_1.1.2_i386.tar.gz"

LICENSE="EULA"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="fetch"

RDEPEND="x11-libs/libxcb"

DEPEND="${RDEPEND}"

pkg_nofetch() {
    einfo "Please download"
    einfo "  - QuantZ-beta_1.1.2_i386.tar.gz"
    einfo "from ${HOMEPAGE} and place them in ${DISTDIR}"
    # Or http://gamerizon.s3.amazonaws.com/QuantZ-beta_1.1.2_i386.tar.gz sssh =P
}


src_compile () {
	einfo "No Compilation, Binary install"
}

src_install () {
	dodir /opt/quantz

	# Install stuffs
	cd ${S}
	exeinto /opt/quantz
	doexe QuantZ

	cd ${S}/lib
	insinto /opt/quantz/lib
	doins libopenal.so.1
	# Needs 32bit libxcb
	if use amd64 ; then
		doins $FILESDIR/libxcb.so.1
	fi

	cd ${S}/icons
	insinto /opt/quantz/icons
	doins 48x48.png
	dosym /opt/quantz/icons/48x48.png /usr/share/pixmaps/QuantZ.png

	cd ${S}
	dosym /opt/quantz/QuantZ /opt/bin/QuantZ
	dodoc README COPYING
	#doman QuantZ.manual
	domenu $FILESDIR/quantz.desktop

	dobin $FILESDIR/QuantZ
}

pkg_postinst() {
	fdo-mime_desktop_database_update
}
