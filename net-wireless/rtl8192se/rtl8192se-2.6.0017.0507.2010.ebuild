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

src_install() {
	linux-mod_src_install

	insinto /$(get_libdir)/firmware/RTL8192SE
	doins firmware/RTL8192SE/rtl8192sfw.bin

	dodoc readme.txt
}
