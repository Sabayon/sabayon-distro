# Copyright 1999-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
EAPI="2"
inherit eutils mount-boot sabayon-artwork

DESCRIPTION="Sabayon Core Artwork, contains Gensplash, Wallpapers and Mouse themes"
HOMEPAGE="http://www.sabayon.org/"
SRC_URI="http://distfiles.sabayon.org/${CATEGORY}/${PN}/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RESTRICT="nomirror"
RDEPEND="!<=x11-themes/sabayonlinux-artwork-4
	!<x11-themes/sabayon-artwork-4
	sys-apps/findutils
	!<sys-boot/grub-0.97-r22
	"

S="${WORKDIR}/${PN}"

src_install() {
	# Gensplash theme
	cd ${S}/gensplash
	dodir /etc/splash/sabayon
	cp -r ${S}/gensplash/sabayon/* ${D}/etc/splash/sabayon

	# Cursors
	cd ${S}/mouse/entis/cursors/
	dodir /usr/share/cursors/xorg-x11/entis/cursors
	insinto /usr/share/cursors/xorg-x11/entis/cursors/
	doins -r ./

	# Wallpaper
	cd ${S}/background
	insinto /usr/share/backgrounds
	doins *.png *.jpg

	# Grub
	dodir /boot/grub
	insinto /boot/grub
	doins "${FILESDIR}/5.0/splash.xpm.gz"

}

pkg_postinst() {
	# mount boot first
	mount-boot_mount_boot_partition

	# Update Sabayon initramfs images
	update_sabayon_kernel_initramfs_splash

	ewarn "Please report bugs or glitches to"
	ewarn "bugs.sabayon.org"
}
