# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

RESTRICT="nomirror"

DESCRIPTION="Firmware for Intersil Prism GT / Prism Duette USB wireless chipsets"
HOMEPAGE="http://www.prism54.org/"
SRC_URI="http://www.sabayonlinux.org/distfiles/net-wireless/${PN}/${P}.tar.bz2"

LICENSE="as-is"
SLOT="0"
KEYWORDS="amd64 ~ppc x86 ppc64"

IUSE=""
RDEPEND="|| ( >=sys-fs/udev-096 >=sys-apps/hotplug-20040923 )"

S="${WORKDIR}"/${PN}

src_unpack() {
	unpack ${A}
	cd ${S}
}

src_install() {
	cd ${S}
	insinto /lib/firmware/
	doins ./isl*
}
