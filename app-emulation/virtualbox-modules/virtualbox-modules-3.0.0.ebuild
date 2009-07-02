# ==========================================================================
# This ebuild come from jokey repository. Zugaina.org only host a copy.
# For more info go to http://gentoo.zugaina.org/
# ************************ General Portage Overlay  ************************
# ==========================================================================
# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/virtualbox-modules/virtualbox-modules-2.2.4.ebuild,v 1.1 2009/06/01 00:25:05 patrick Exp $

# XXX: the tarball here is just the kernel modules split out of the binary
#      package that comes from virtualbox-bin

EAPI=2

inherit eutils linux-mod

MY_P=vbox-kernel-module-src-${PV}
DESCRIPTION="Kernel Modules for Virtualbox"
HOMEPAGE="http://www.virtualbox.org/"
SRC_URI="http://gentoo.zerodev.it/files/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="!=app-emulation/virtualbox-ose-9999"

S=${WORKDIR}

BUILD_TARGETS="all"
BUILD_TARGET_ARCH="${ARCH}"
MODULE_NAMES="vboxdrv(misc:${S}) vboxnetflt(misc:${S}) vboxnetadp(misc:${S})"

pkg_setup() {
	linux-mod_pkg_setup
	BUILD_PARAMS="KERN_DIR=${KV_DIR} KERNOUT=${KV_OUT_DIR}"
	enewgroup vboxusers
}

src_install() {
	linux-mod_src_install

	# udev rule for vboxdrv
	dodir /etc/udev/rules.d
	echo 'KERNEL=="vboxdrv", NAME="vboxdrv", OWNER="root", GROUP="", MODE=""' \
	> "${D}/etc/udev/rules.d/10-virtualbox.rules"
	echo 'SUBSYSTEM=="usb_device", GROUP="", MODE=""' \
	>> "${D}/etc/udev/rules.d/10-virtualbox.rules"
	echo 'SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", GROUP="", MODE=""' \
	>> "${D}/etc/udev/rules.d/10-virtualbox.rules"
}

pkg_postinst() {
	linux-mod_pkg_postinst
	elog "Starting with the 3.x release new kernel modules were added,"
	elog "be sure to load all the needed modules."
	elog ""
	elog "Please add \"vboxdrv\", \"vboxnetflt\" and \"vboxnetadp\" to:"
	if has_version sys-apps/openrc; then
		elog "/etc/conf.d/modules"
	else
		elog "/etc/modules.autoload.d/kernel-${KV_MAJOR}.${KV_MINOR}"
	fi
	elog ""
}
