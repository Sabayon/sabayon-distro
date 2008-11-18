# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/acx/acx-0.3.37_p20080112.ebuild,v 1.2 2008/02/07 21:03:52 spb Exp $

inherit linux-mod

PATCHLEVEL=${PV##*_p}

DESCRIPTION="Driver for the ACX100 and ACX111 wireless chipset (CardBus, PCI, USB)"
HOMEPAGE="http://acx100.sourceforge.net/"
SRC_URI="http://downloads.sourceforge.net/acx100/${PN}-${PATCHLEVEL}-2.tar.bz2"

LICENSE="GPL-2 as-is"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"

IUSE="debug"

RDEPEND="net-wireless/wireless-tools
		net-wireless/acx-firmware"

S=${WORKDIR}/${PN}-${PATCHLEVEL}

MODULE_NAMES="acx(net:${S})"
CONFIG_CHECK="WIRELESS_EXT FW_LOADER"
BUILD_TARGETS="modules"

pkg_setup() {
	linux-mod_pkg_setup
	BUILD_PARAMS="-C ${KV_DIR} SUBDIRS=${S}"
}

src_unpack() {
	unpack ${A}
	chmod ug+w . -R

	# The default acx_config.h has some rather over-zealous debug output.
	cd $S
	if ! use debug; then
		sed -i '/^#define ACX_DEBUG/s/2/0/' acx_config.h || die "Failed to disable debug support"
	fi

	epatch "${FILESDIR}/${P}.patch"
	epatch "${FILESDIR}/${P}-2.6.27.patch"
}

src_install() {
	linux-mod_src_install

	dodoc README
}
