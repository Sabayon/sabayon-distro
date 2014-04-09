# Copyright 2004-2011 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

PYTHON_DEPEND="2"
RESTRICT_PYTHON_ABIS="3.*"

inherit python eutils

DESCRIPTION="command line interface to http://www.sabayonlinux.org/pastebin"
HOMEPAGE="http://www.sabayonlinux.org/pastebin"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~arm ~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc-fbsd ~sparc ~x86 ~x86-fbsd"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_unpack() {
	cd "${S}"
	cp "${FILESDIR}/${P}" ${PN}
}

src_install() {
	dobin ${PN} || die
}
