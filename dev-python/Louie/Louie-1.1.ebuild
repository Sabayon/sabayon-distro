# Copyright 2004-2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit distutils

DESCRIPTION="Louie provides Python programmers with a straightforward way to dispatch signals between objects in a wide variety of contexts"
HOMEPAGE="http://www.pylouie.org"
SRC_URI="http://www.sabayonlinux.org/distfiles/dev-python/${P}.tar.gz"
IUSE=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc ~x86"

RDEPEND=">=dev-lang/python-2.4.0"

DEPEND="${RDEPEND}"

src_install() {
	distutils_src_install
	docinto modules
	dodoc doc/*
}

