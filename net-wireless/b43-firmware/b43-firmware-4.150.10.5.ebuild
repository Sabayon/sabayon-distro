# Copyright 2004-2008 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="Firmware for the new b43 b43-legacy drivers for Broadcom wireless adapters using mac80211 driver"
HOMEPAGE="http://www.openwrt.org/"
SRC_URI="http://mirror2.openwrt.org/sources/broadcom-wl-${PV}.tar.bz2"

LICENSE="AS-IS"
SLOT="0"
KEYWORDS="amd64 x86"

IUSE=""
DEPEND=">=sys-apps/hotplug-20040923
	>=net-wireless/b43-fwcutter-011"
S="${WORKDIR}/broadcom-wl-${PV}"

src_unpack() {
	unpack "${A}" || die "failed to unpack"
}

src_compile() {
	einfo "nothing to compile"
}

src_install() {
	FWDIR="${D}/lib/firmware"
	dodir /lib/firmware
	cd ${S}/driver || die "failed to cd into driver directory"
	b43-fwcutter -w ${FWDIR} wl_apsta_mimo.o || die "failed to create firmware"
}

