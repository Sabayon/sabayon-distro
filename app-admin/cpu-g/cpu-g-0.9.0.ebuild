# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
PYTHON_DEPEND="2"
inherit eutils prefix python

DESCRIPTION="Displays information about your CPU, RAM, Motherboard and more"
HOMEPAGE="http://gtk-apps.org/content/show.php/CPU-G?content=113796"
SRC_URI="mirror://sourceforge/cpug/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
	dev-python/pygobject:2
	dev-python/pygtk:2
"

src_prepare() {
	epatch "${FILESDIR}"/cpu-g-fix-paths.patch
	eprefixify ${PN}
}

src_install() {
	dobin ${PN} || die
	domenu data/${PN}.desktop || die
	doicon data/${PN}.png || die
	doman doc/${PN}.1 || die
	insinto /usr/share/${PN}
	doins ${PN}.glade || die
	doins -r data || die
	rm "${ED}"usr/share/${PN}/data/${PN}.desktop || die
}
