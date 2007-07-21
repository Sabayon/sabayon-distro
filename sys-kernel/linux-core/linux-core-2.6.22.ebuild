# Copyright 2004-2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit eutils

DESCRIPTION="Sabayon Linux kernel image and modules"
HOMEPAGE="http://www.sabayonlinux.org"
SRC_URI="http://www.sabayonlinux.org/distfiles/sys-kernel/${PN}/${P}.tar.bz2"
RESTRICT="nomirror"
#S=${WORKDIR}/${P}-${PR}

LICENSE="GPL-2"
KEYWORDS="amd64 x86"
IUSE="source grub"

DEPEND="sys-boot/grub
	sys-apps/gawk
	source? ( =sys-kernel/sabayon-sources-${PV} )"

RDEPEND="${DEPEND}"

src_install() {

	if use x86; then
		KERNELBINS=${S}/x86
	elif use amd64; then
		KERNELBINS=${S}/amd64
	else
		die "Your ARCH is not supported"
	fi

	# check if /boot is not mounted - hackish for now
	BOOT_PART=$(cat /etc/fstab | grep "/boot")
	if [ -n "${BOOT_PART}" ]; then
		BOOT_MOUNTED=$(cat /etc/mtab | grep "/boot")
		if [ -z "${BOOT_MOUNTED}" ]; then
			mount /boot || die "Cannot mount /boot"
		fi
	fi

	dodir /boot
	insinto /boot
	doins -r ${KERNELBINS}/boot/*
	insinto /lib/modules
	mkdir ${D}/lib/modules -p
	cp -Rp ${KERNELBINS}/modules/* ${D}/lib/modules/

	if use grub; then
		cd ${S}
		addwrite /boot/grub
		sh postinstall.sh
	fi
}

pkg_postinst() {
	echo
	einfo "This kernel has been compiled using GCC 4.1.2."
	einfo "You can grab the configuration at:"
	einfo "x86 Edition: http://www.sabayonlinux.org/sabayon/kconfigs/SabayonLinux-x86-3.4.config"
	einfo "x86-64 Edition: http://www.sabayonlinux.org/sabayon/kconfigs/SabayonLinux-x86_64-3.4.config"
	einfo "To successfully compile external modules, you must use"
	einfo "the same compiler and the sources pulled in by the 'source' USE flag"
	echo
}
