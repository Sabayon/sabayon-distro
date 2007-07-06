# Copyright 2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit distutils

MY_PV=${PV/_/}
DESCRIPTION="Wine-doors is an application designed to make installing windows software on Linux, Solaris or other Unix systems easier."
HOMEPAGE="http://www.wine-doors.org"
SRC_URI="http://www.wine-doors.org/releases/${PN}-${MY_PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
S=${WORKDIR}/${PN}-${MY_PV}

DEPEND="
	>=dev-lang/python-2.4.0
	>=dev-python/pycairo-1.2.0
	>=x11-libs/cairo-1.2.0
	>=dev-python/gnome-python-desktop-2.16.0
	app-arch/cabextract
	app-arch/unzip
	app-arch/zip
	app-arch/gzip
	app-arch/bzip2
	app-arch/tar
	dev-util/glade
	dev-libs/libxml2
	app-pda/orange
	"

pkg_setup() {

	if ! built_with_use dev-util/glade python ; then
		error "${PN} needs dev-util/glade compiled with USE=\"python\""
		die "wine-doors needs dev-util/glade compiled with Python support"
	fi

	if ! built_with_use dev-libs/libxml2 python ; then
		error "${PN} needs dev-libs/libxml2 compiled with USE=\"python\""
		die "wine-doors needs dev-libs/libxml2 compiled with Python support"
	fi

}

src_unpack() {
	unpack ${A}
}

src_compile() {
	einfo "nothing to compile"
}

src_install() {
	cd ${S}
        distutils_src_install --temp="${D}"
	dodir /etc/wine-doors

}
