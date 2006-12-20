# Copyright 2006 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit distutils

UBUNTU_REV="0ubuntu16"
DESCRIPTION="Hardware Database Client, useful to collect and report hardware information"
HOMEPAGE="http://www.sabayonlinux.org"
SRC_URI="http://www.sabayonlinux.org/distfiles/x11-misc/${PN}_${PV}-${UBUNTU_REV}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="gtk qt4"

DEPEND="=dev-lang/python-2.4*
	qt4? dev-python/PyQt4
	net-analyzer/fping"

RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
	# well'add our patches here
	cp ${FILESDIR}/sabayon-install.py ${S}/setup.py
}

src_compile() {
        einfo "no compilation needed"
	cd ${S}
	# run our installer wrapper
	python setup.py
}

src_install() {
	distutils_python_version
	cd ${S}

	dodir /usr/bin
	dodir /usr/share/hwdb-client
	dodir /usr/share/locale
	dodir /usr/share/applications/kde
	dodir /usr/lib/python${PYVER}/site-packages/hwdb_client
	dodir /usr/share/apps/hwdb-client-kde/pics
	dodir /usr/share/icons/crystalsvg/22x22/apps
	dodir /usr/share/gnome/help/hwdb-client/C

	# prepare dirs
	./install.sh

	if ! use qt4; then
	  rm ${D}/usr/bin/hwdb-kde
	  rm ${D}/usr/share/apps/hwdb-client-kde -rf
	fi

}
