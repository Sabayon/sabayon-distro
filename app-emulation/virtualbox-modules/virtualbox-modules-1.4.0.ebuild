# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/virtualbox-modules/virtualbox-modules-1.4.0.ebuild,v 1.2 2007/06/23 16:07:33 masterdriverz Exp $

inherit eutils linux-mod

MY_P=vbox-kernel-module-src-${PV}
DESCRIPTION="Modules for Virtualbox OSE"
HOMEPAGE="http://www.virtualbox.org/"
SRC_URI="http://www.virtualbox.org/download/${PV}/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 x86"
IUSE=""

RDEPEND="!<app-emulation/virtualbox-bin-1.3.6
	!<app-emulation/virtualbox-1.3.6
	!=app-emulation/virtualbox-9999"

S=${WORKDIR}/vboxdrv

BUILD_TARGETS="all"
BUILD_TARGET_ARCH="${ARCH}"
MODULE_NAMES="vboxdrv(misc:${S})"

pkg_setup() {
	linux-mod_pkg_setup
	BUILD_PARAMS="KERN_DIR=${KV_DIR} KERNOUT=${KV_OUT_DIR}"
}

src_unpack() {
	unpack ${A}

	# fix Makefile to work inside a chroot
	cd ${S}
	sed -i 's/$(shell uname -r)/${KV_FULL}/' Makefile
}


src_install() {
	linux-mod_src_install

	# udev rule for vboxdrv
	dodir /etc/udev/rules.d
	echo 'KERNEL=="vboxdrv", GROUP="vboxusers" MODE=660' >> "${D}/etc/udev/rules.d/60-virtualbox.rules"
}

pkg_preinst() {
	enewgroup vboxusers
}

pkg_postinst() {
	linux-mod_pkg_postinst
	if use amd64; then
		elog ""
		elog "To avoid the nmi_watchdog bug and load the vboxdrv module"
		elog "you may need to update your bootloader configuration and pass the option:"
		elog "nmi_watchdog=0"
	fi
}
