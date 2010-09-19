# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils linux-mod

MY_P="${PN}_linux_${PV}"

DESCRIPTION="Legacy driver for the RTL8192se wireless chipset"
HOMEPAGE="http:///www.realtek.com.tw/"
SRC_URI="http://github.com/downloads/benf/gentoo-overlay/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=""
RDEPEND=""

S=${WORKDIR}/${MY_P}

MODULE_NAMES="r8192se_pci(net::${S}/HAL/rtl8192)"
BUILD_TARGETS="clean all"

src_prepare() {
	# fixup fux0red build system
	# please check if other zombies are around every new package release
	# upstream should really fix this stuff
	einfo "Fixing broken build system..."
	for rtl_makefile in "${S}/Makefile" "${S}/HAL/rtl8192/Makefile" "${S}/rtllib/Makefile"; do
		sed -i "${rtl_makefile}" -e "s:\`uname -r\`:${KV_FULL}:g" || die "Unable to patch Makefile"
		sed -i "${rtl_makefile}" -e "s:\$(shell uname -r):${KV_FULL}:g" || die "Unable to patch Makefile (2)"
		sed -i "${rtl_makefile}" -e "s:\$(shell uname -r|cut -d. -f1,2):${KV_MAJOR}.${KV_MINOR}:g" || die "Unable to patch Makefile (3)"
		sed -i "${rtl_makefile}" -e "s:\$(shell uname -r | cut -d. -f1,2,3,4):${KV_FULL}:g" || die "Unable to patch Makefile (4)"
		# useless... moblin stuff
		sed -i "${rtl_makefile}" -e "s:\$(shell uname -r | cut -d. -f6 | cut -d- -f1):${KV_LOCAL}:g" || die "Unable to patch Makefile (5)"
		# do not run depmod -a
		sed -i "${rtl_makefile}" -e 's:/sbin/depmod -a ${shell uname -r}::g' || die "Unable to patch Makefile (6)"
	done
}

src_install() {
	linux-mod_src_install

	insinto /$(get_libdir)/firmware/RTL8192SE
	doins firmware/RTL8192SE/rtl8192sfw.bin

	dodoc readme.txt
}
