# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.*"

inherit eutils

DESCRIPTION="internet radio browser"
HOMEPAGE="http://milki.erphesfurt.de/streamtuner2/"
SRC_URI="mirror://sourceforge/${PN}/${P}.src.tgz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-libs/keybinder[python]
	dev-python/imaging
	dev-python/pygtk
	dev-python/pyquery"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/${P}-fix-python-path.patch
}

src_install() {
	cd "${PN}"
	newbin st2.py streamtuner2
	rm -f st2.py

	insinto /usr/share/pixmaps
	doins streamtuner2.png

	insinto /usr/share/applications
	doins streamtuner2.desktop
	rm -f streamtuner2.desktop

	dodir /usr/share/${PN}
	cp -R . "${D}"usr/share/${PN}
}
