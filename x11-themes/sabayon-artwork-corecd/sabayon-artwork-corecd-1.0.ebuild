# Copyright 1999-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
inherit eutils mount-boot sabayon-artwork

DESCRIPTION="Sabayon CoreCD Artwork"
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI="http://distfiles.sabayonlinux.org/${CATEGORY}/${PN}/${P}.tar.lzma"
LICENSE="CCPL-Attribution-ShareAlike-3.0"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RESTRICT="nomirror"
RDEPEND="!<=x11-themes/sabayonlinux-artwork-4
        sys-apps/findutils
        "

S="${WORKDIR}/${PN}"

src_install () {
	# Gensplash theme
	cd ${S}/gensplash
	dodir /etc/splash/sabayon-core
	cp -r ${S}/gensplash/sabayon/* ${D}/etc/splash/sabayon-core
}

pkg_postinst () {
	ewarn "Please report bugs or glitches to"
	ewarn "bugs.sabayonlinux.org"
		
	einfo "If you see your old splash for a few seconds at boot please run:"
	einfo "# splash_geninitramfs --res NxN --append /path/to/initramfsimage sabayon-core"
	einfo "where NxN is your resolution and /path/to/initramfs is your intramfs directory"
	einfo "to update your initramfs"
	
	einfo "To use this theme you will need to change the \"theme\" option in your"
	einfo "grub.conf to \"sabayon-core\""
	
	# mount boot first
	mount-boot_mount_boot_partition

	# Update Sabayon initramfs images
	update_sabayon_kernel_initramfs_splash
}
