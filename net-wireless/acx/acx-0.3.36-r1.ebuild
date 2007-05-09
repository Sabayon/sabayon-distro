# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/acx/acx-0.3.35_p20060521.ebuild,v 1.2 2006/10/20 02:24:29 dsd Exp $

inherit linux-mod

DESCRIPTION="Driver for the ACX100 and ACX111 wireless chipset (CardBus, PCI, USB)"

ACX_DATE="20070101"
HOMEPAGE="http://acx100.sourceforge.net/"
SRC_URI="http://www.cmartin.tk/acx/acx-${ACX_DATE}.tar.bz2"

LICENSE="GPL-2 as-is"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"

IUSE="debug"

RDEPEND="net-wireless/wireless-tools
	net-wireless/acx-firmware"

S="${WORKDIR}/acx-${ACX_DATE}"

MODULE_NAMES="acx(net:${S})"
CONFIG_CHECK="FW_LOADER"
BUILD_TARGETS="modules"

pkg_setup() {
	linux-mod_pkg_setup
	BUILD_PARAMS="-C ${KV_DIR} SUBDIRS=${S}"
}

src_unpack() {
	unpack ${A}
	chmod ug+w . -R

	cd ${S}

	# The default acx_config.h has some rather over-zealous debug output.
	if ! use debug; then
		sed -i '/^#define ACX_DEBUG/s/2/0/' acx_config.h || die "Failed to disable debug support"
	fi
}

src_install() {
	cd ${S}
	linux-mod_src_install
	dodoc README
}
