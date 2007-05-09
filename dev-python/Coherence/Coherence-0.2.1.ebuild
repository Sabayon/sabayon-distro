# Copyright 2004-2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit distutils

DESCRIPTION="Coherence is a framework written in Python enabling your application to participate in digital living networks, at the moment primarily the UPnP universe"
HOMEPAGE="https://coherence.beebits.net/"
SRC_URI="http://www.sabayonlinux.org/distfiles/dev-python/${P}.tar.gz"
IUSE=""
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc ~x86"
RESTRICT="nomirror"

DEPEND="
	>=dev-lang/python-2.4
	dev-python/elementtree
	dev-python/celementtree
	>=dev-python/gst-python-0.10
	dev-python/soappy
	dev-python/Louie
	dev-python/configobj
	dev-python/nevow
	
	"

src_install() {
	distutils_src_install
	docinto modules
	dodoc docs/*
}

