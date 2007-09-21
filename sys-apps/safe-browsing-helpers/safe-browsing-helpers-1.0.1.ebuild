# Copyright 2007 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="SabayonLinux (Gentoo compatbile) Tor/Privoxy configuration tool"
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64 ppc ppc64 sparc"
IUSE=""

RDEPEND="
	net-proxy/privoxy
	net-misc/tor
	>=dev-lang/python-2.4.0
	"
DEPEND="${RDEPEND}"

src_unpack () {
        cd ${WORKDIR}
        cp ${FILESDIR}/${PV}/* . -p
}

src_install () {
	cd ${WORKDIR}
	exeinto /sbin/
	doexe *-setup
}
