# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="3"
PYTHON_DEPEND="2"

inherit distutils

MY_P="${P/rb_/}" MY_P="${MY_P/-python/}"
S="${WORKDIR}/${MY_P}/bindings/python"

DESCRIPTION="Python bindings for the rb_libtorrent library"
HOMEPAGE="http://www.rasterbar.com/products/libtorrent/"
SRC_URI="mirror://sourceforge/libtorrent/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~x86-fbsd"
IUSE="debug"

DEPEND="net-libs/rb_libtorrent
	dev-libs/boost
	!net-libs/libtorrent"
RDEPEND="${DEPEND}"

src_compile() {
        cd "${S}"
	cp "${FILESDIR}"/rb_libtorrent-python_setup.py ./setup.py
}
