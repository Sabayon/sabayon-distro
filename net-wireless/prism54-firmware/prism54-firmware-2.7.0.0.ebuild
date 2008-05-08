# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/prism54-firmware/prism54-firmware-1.0.4.3.ebuild,v 1.9 2007/07/02 15:20:30 peper Exp $

RESTRICT="mirror"

DESCRIPTION="Firmware for Intersil Prism GT / Prism Duette wireless chipsets"
HOMEPAGE="http://www.prism54.org/"
SRC_URI="http://www.prism54.org/firmware/${PV}.arm"

LICENSE="as-is"
SLOT="0"
KEYWORDS="amd64 ~ppc x86"

IUSE=""
RDEPEND="|| ( >=sys-fs/udev-096 >=sys-apps/hotplug-20040923 )"

src_unpack() {
	true
}

src_install() {
	insinto /lib/firmware/
	newins ${DISTDIR}/${PV}.arm isl3890
}
