# Copyright 1999-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
EAPI="2"
inherit eutils mount-boot sabayon-artwork

DESCRIPTION="Sabayon Core Artwork, contains Gensplash, Wallpapers and Mouse themes"
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${PN}-4.1.95.tar.lzma"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""
RESTRICT="nomirror"
RDEPEND="!<=x11-themes/sabayonlinux-artwork-4
	!<x11-themes/sabayon-artwork-4
	!x11-themes/sabayon-artwork-star
	!x11-themes/sabayon-artwork-darkblend
	!x11-themes/sabayon-artwork-corecd
	sys-apps/findutils
	"

S="${WORKDIR}/${PN}"

src_install () {
	# Gensplash theme
	cd ${S}/gensplash
	dodir /etc/splash/sabayon
	cp -r ${S}/gensplash/sabayon/* ${D}/etc/splash/sabayon
	
	# 4.1.96 fixes
	cp -r ${FILESDIR}/4.1.96/* ${D}/etc/splash/sabayon
	rm ${D}/etc/splash/sabayon/CREDITS~

	# Cursors
	cd ${S}/mouse/entis/cursors/
	dodir /usr/share/cursors/xorg-x11/entis/cursors
	insinto /usr/share/cursors/xorg-x11/entis/cursors/
	doins -r ./

	# Wallpaper
	cd ${S}/background
	insinto /usr/share/backgrounds
	doins *.png
}

pkg_postinst () {
	# mount boot first
	mount-boot_mount_boot_partition

	# Update Sabayon initramfs images
	update_sabayon_kernel_initramfs_splash

	ewarn "This is a prelease - ${PV}"
	ewarn "Please report bugs or glitches to"
	ewarn "bugs.sabayonlinux.org"
}
