# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils python

DESCRIPTION="Platform independent MSN Messenger client written in Python+GTK"
HOMEPAGE="http://www.emesene.org"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=dev-lang/python-2.4.3
	>=x11-libs/gtk+-2.8.20
	>=dev-python/pygtk-2.8.6"

RDEPEND="${DEPEND}"

src_install() {
	rm GPL PSF LGPL
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
