# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils python distutils

DESCRIPTION="Platform independent MSN Messenger client written in Python+GTK"
HOMEPAGE="http://www.emesene.org"
SRC_URI="http://distfiles.sabayonlinux.org/${CATEGORY}/${PN}/${P}.tar.lzma"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=dev-lang/python-2.5
	>=x11-libs/gtk+-2.8.20
	>=dev-python/pygtk-2.8.6
	dev-python/gtkspell-python
	media-libs/libmimic"

RDEPEND="${DEPEND}"


src_compile () {
    cd ${PN}
    "${python}" setup.py build_ext -i
}

src_install() {
    cd ${PN}
	rm GPL PSF LGPL
	rm -rf build
	insinto /usr/share/emesene
	doins -r *

	fperms a+x /usr/share/emesene/emesene
	dosym /usr/share/emesene/emesene /usr/bin/emesene

	doman misc/emesene.1
	dodoc docs/*

	doicon misc/*.png misc/*.svg

	# install the desktop entry
	domenu misc/emesene.desktop
}

pkg_postinst() {
	python_mod_optimize /usr/share/emesene
}

pkg_postrm() {
	python_mod_cleanup /usr/share/emesene
}
