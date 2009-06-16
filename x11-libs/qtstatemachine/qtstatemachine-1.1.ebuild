# Copyright 2004-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
# $

EAPI="2"
inherit eutils base multilib

DESCRIPTION="Qt State Machine Framework"
SLOT="4"
KEYWORDS="~amd64 ~x86"
IUSE=""
SRC_URI="ftp://ftp.trolltech.com/qt/solutions/lgpl/qtstatemachine-1.1-opensource.tar.gz"
RESTRICT="mirror"
LICENSE="|| ( LGPL-2.1 GPL-3 QPL-1.0 )"

RDEPEND="dev-libs/glib
	media-libs/libpng
	x11-libs/qt-core:4
	x11-libs/qt-gui:4"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${P}-opensource"

src_configure() {

	# build system is utterly broken
	echo "yes" | ./configure -library || die "configure failed"

}

src_compile() {
	qmake -makefile -nocache || die "qmake failed"
	emake || "make failed"
}

src_install() {

	# build system is broken
	dolib.so lib/*

}

pkg_postinst() {
	ewarn "This package is VERY EXPERIMENTAL."
	ewarn "Its build system is utterly broken."
	ewarn "No examples are installed because of the issue above"
	ewarn "...and your cat will be eaten by a black hole!"
	ewarn "plop!"
}
