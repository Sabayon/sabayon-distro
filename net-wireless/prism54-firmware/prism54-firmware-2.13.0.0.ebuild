# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/prism54-firmware/prism54-firmware-1.0.4.3.ebuild,v 1.9 2007/07/02 15:20:30 peper Exp $

inherit eutils

RESTRICT="mirror"
DESCRIPTION="Firmware for Intersil Prism GT / Prism Duette wireless chipsets"
HOMEPAGE="http://www.prism54.org/"
SRC_URI="
	http://daemonizer.de/prism54/prism54-fw/fw-softmac/2.13.12.0.arm
	http://daemonizer.de/prism54/prism54-fw/fw-usb/2.13.1.0.arm.0
	http://daemonizer.de/prism54/prism54-fw/fw-usb/2.13.24.0.lm87.arm
	"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RDEPEND=">=sys-fs/udev-096"

src_unpack() {
	einfo "nothing to unpack"
}

src_install() {
	insinto /lib/firmware/
	for fw in ${SRC_URI}; do
		doins ${DISTDIR}/$(basename ${fw})
	done
}
