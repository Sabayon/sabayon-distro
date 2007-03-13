# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/linux-wlan-ng-firmware/linux-wlan-ng-firmware-0.2.2.ebuild,v 1.7 2006/04/02 12:02:04 betelgeuse Exp $

inherit eutils

MY_P=${P/-firmware/}

DESCRIPTION="Firmware for Prism2/2.5/3 based 802.11b wireless LAN products"
HOMEPAGE="http://linux-wlan.org"
SRC_URI="ftp://ftp.linux-wlan.org/pub/linux-wlan-ng/${MY_P}.tar.bz2"

LICENSE="MPL-1.1 Conexant-firmware"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"

IUSE=""

DEPEND="!<net-wireless/linux-wlan-ng-0.2.2"
RDEPEND=""

S=${WORKDIR}/${MY_P}

src_compile() {
	local config=${S}/config.mk
	echo TARGET_ROOT_ON_HOST=${D} >> ${config}
	echo FIRMWARE_DIR=/lib/firmware >> ${config}
}

src_install() {
	cd ${S}/src/prism2
	make install-firmware || die "Failed to install firmware"
}

pkg_postinst() {
	einfo "Firmware location has changed to ${ROOT}lib/firmware."
	einfo "You can run emerge --config =${PF} to delete"
	einfo "The old files. Because of the default configuration file"
	einfo "protection, the files are most likely left your system"
	einfo "and are now useless."
}

pkg_config() {
	rm -i ${ROOT}/etc/wlan/*.hex
	rm -i ${ROOT}/etc/wlan/*.pda
}
