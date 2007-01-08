# Copyright 2006 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

WANT_AUTOMAKE="latest"
WANT_AUTOCONF="latest"

inherit subversion distutils

ESVN_REPO_URI="http://svn.sabayonlinux.org/projects/${PN}/trunk"

DESCRIPTION="Hardware Database Client, useful to collect and report hardware information"
HOMEPAGE="http://www.sabayonlinux.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-*"
IUSE="gtk qt4"

DEPEND="=dev-lang/python-2.4*
	qt4? (dev-python/PyQt4)
	net-analyzer/fping"

RDEPEND="${DEPEND}"

S="${WORKDIR}/trunk"

src_compile() {
	ewarn "This is SVN release!"
        einfo "No compilation needed as made with PyQt4"
	cd ${S}
	# run our installer wrapper
	python sabayon-install.py
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

pkg_postinst() {
	einfo "Please report all bugs to http://bugs.sabayonlinux.org"
}
