# Copyright 2006 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

inherit eutils versionator

DESCRIPTION="SabayonLinux Live tool for X.Org video driver configuration"
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64 ppc"
IUSE=""

RDEPEND=">=x11-base/xorg-server-1.6.5
	>=x11-libs/libX11-1.2.2
	>=app-misc/sabayonlive-tools-1.6.0
	dev-lang/python
	"


DEPEND="${RDEPEND}"

src_unpack () {

        cd ${WORKDIR}
        cp ${FILESDIR}/gpu-configuration . -p

}

src_prepare() {
	# Patch gpu-detector to make entropy calls exit correctly
	epatch "${FILESDIR}/gpu-detector.patch"
}

src_install () {

	cd ${WORKDIR}
	exeinto /sbin/
	doexe gpu-configuration

}
