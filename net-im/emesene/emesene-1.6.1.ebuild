# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils python

MY_PV="1.6"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="Platform independent MSN Messenger client written in Python+GTK"
HOMEPAGE="http://www.emesene.org"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=dev-lang/python-2.6.2
	>=x11-libs/gtk+-2.8.20
	>=dev-python/pygtk-2.8.6"

RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

src_install() {
	rm -f GPL PSF LGPL
	insinto /usr/share/emesene
	doins -r * || die "doins failed"

	fperms a+x /usr/share/emesene/emesene || die "fperms failed"
	dosym /usr/share/emesene/emesene /usr/bin/emesene || die "dosym failed"

	doman misc/emesene.1 || die "doman failed"

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
