# Copyright 1999-2011 Sabayon Promotion
# Distributed under the terms of the GNU General Public License v2
#

EAPI=3
inherit eutils mount-boot sabayon-artwork

DESCRIPTION="Offical Sabayon Linux Core Artwork"
HOMEPAGE="http://www.sabayon.org/"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${P}.tar.xz"
LICENSE="CCPL-Attribution-ShareAlike-3.0"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RDEPEND="sys-apps/findutils
	!<sys-boot/grub-0.97-r22
"

S="${WORKDIR}/${PN}"

src_install() {
	# Fbsplash theme
	cd ${S}/fbsplash
	dodir /etc/splash/sabayon
	cp -r ${S}/fbsplash/sabayon/* ${D}/etc/splash/sabayon

	# Cursors
	cd ${S}/mouse/entis/cursors/
	dodir /usr/share/cursors/xorg-x11/entis/cursors
	insinto /usr/share/cursors/xorg-x11/entis/cursors/
	doins -r ./

	# Wallpaper
	cd ${S}/background
	insinto /usr/share/backgrounds
	doins *.png *.jpg
}

pkg_postinst() {
	# mount boot first
	mount-boot_mount_boot_partition

	# Update Sabayon initramfs images
	update_sabayon_kernel_initramfs_splash

	einfo "Please report bugs or glitches to"
	einfo "bugs.sabayon.org"
}
