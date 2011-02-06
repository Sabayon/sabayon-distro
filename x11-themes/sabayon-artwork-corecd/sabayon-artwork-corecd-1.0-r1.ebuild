# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
inherit eutils mount-boot sabayon-artwork

DESCRIPTION="Sabayon CoreCD Artwork"
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${P}.tar.lzma"
LICENSE="CCPL-Attribution-ShareAlike-3.0"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RESTRICT="nomirror"
RDEPEND="sys-apps/findutils
        !x11-themes/sabayon-artwork-core"

S="${WORKDIR}/${PN}"

src_install () {
	# Gensplash theme
	cd ${S}/gensplash
	dodir /etc/splash/sabayon
	cp -r ${S}/gensplash/sabayon/* ${D}/etc/splash/sabayon
	
	# Grub
	dodir /boot/grub
	cp "${FILESDIR}"/grub-${PV}.xpm.gz "${D}"/boot/grub/grub-core.xpm.gz
}

pkg_postinst () {
	# mount boot first
	mount-boot_mount_boot_partition

	# Update Sabayon initramfs images
	update_sabayon_kernel_initramfs_splash
	
	ewarn "Please report bugs or glitches to"
	ewarn "bugs.sabayonlinux.org"
	einfo ""
	einfo "If you see your old splash for a few seconds at boot please run:"
	einfo "\# splash_geninitramfs --res NxN --append /path/to/initramfsimage sabayon"
	einfo "where NxN is your resolution and /path/to/initramfs is your intramfs directory"
	einfo "to update your initramfs"
	einfo ""
	einfo "You may also have to change the \"theme\" option in your grub.conf to \"sabayon\""
	einfo ""
}
