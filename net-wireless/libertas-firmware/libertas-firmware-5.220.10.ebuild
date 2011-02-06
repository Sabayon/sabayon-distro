# Copyright 2004-2010 Sabayon
# Distributed under the terms of the GNU General Public License v2

RESTRICT="nomirror"

DESCRIPTION="Firmware for Libertas Wireless Chipsets a/b/g"
HOMEPAGE="http://wiki.laptop.org/go/Libertas"
SRC_URI="mirror://sabayon/net-wireless/${PN}/${PN}-${PV}.p5-1.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="amd64 ppc x86 ppc64"

IUSE=""
RDEPEND="|| ( >=sys-fs/udev-096 >=sys-apps/hotplug-20040923 )"

S=${WORKDIR}

src_unpack() {
	unpack ${A}
}

src_install() {
	cd ${S}/lib/firmware/
	insinto /lib/firmware/
	doins ./*
}
