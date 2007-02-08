# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/acx/acx-0.3.35_p20060521.ebuild,v 1.2 2006/10/20 02:24:29 dsd Exp $

inherit linux-mod

DESCRIPTION="Driver for the ACX100 and ACX111 wireless chipset (CardBus, PCI, USB)"

HOMEPAGE="http://acx100.sourceforge.net/"
SRC_URI="http://www.cmartin.tk/acx/acx-20070101.tar.bz2"

LICENSE="GPL-2 as-is"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"

IUSE="debug"

RDEPEND="net-wireless/wireless-tools
	net-wireless/acx-firmware"

S=${WORKDIR}

MODULE_NAMES="acx(net:${S})"
CONFIG_CHECK="NET_RADIO FW_LOADER"
BUILD_TARGETS="modules"

pkg_setup() {
	linux-mod_pkg_setup
	BUILD_PARAMS="-C ${KV_DIR} SUBDIRS=${S}"
}

src_unpack() {
	unpack ${A}
	chmod ug+w . -R

	# The default acx_config.h has some rather over-zealous debug output.
	if ! use debug; then
		sed -i '/^#define ACX_DEBUG/s/2/0/' acx_config.h || die "Failed to disable debug support"
	fi


	# fix 2.6.18 compilation
	epatch ${FILESDIR}/${P}-2.6.18.patch

	# fix 2.6.19 compilation
	epatch ${FILESDIR}/${P}-2.6.19.patch
}

src_install() {
	linux-mod_src_install

	dodoc README
}
