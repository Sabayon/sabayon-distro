# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/zd1211-firmware/zd1211-firmware-1.4.ebuild,v 1.2 2007/11/03 12:03:19 dsd Exp $

EAPI="3"

inherit eutils

DESCRIPTION="PowerVR SGX540 libraries for OMAP4"

HOMEPAGE=""
SRC_URI="https://launchpad.net/~tiomap-dev/+archive/release/+files/${PN}_${PV}.orig.tar.gz
https://launchpad.net/~tiomap-dev/+archive/release/+files/${PN}_${PV}-1.diff.gz"


LICENSE="TI"
SLOT="0"
KEYWORDS="arm"

IUSE=""
DEPEND="sys-libs/sgx-libs
	<x11-base/xorg-server-1.11
	x11-libs/libdrm"
RDEPEND="${DEPEND}"

#S="${WORKDIR}"
RESTRICT="strip"

src_prepare() {
	cd "${WORKDIR}"
	epatch *.diff
}

src_install() {
	exeinto /usr/lib/xorg/modules/drivers
	doexe "${S}"/usr/lib/xorg/modules/drivers/pvr_drv.so
}

