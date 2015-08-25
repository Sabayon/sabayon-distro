# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
#

EAPI=5
inherit eutils mount-boot sabayon-artwork

DESCRIPTION="Official Sabayon Linux Core Artwork"
HOMEPAGE="http://www.sabayon.org/"

LICENSE="CCPL-Attribution-ShareAlike-3.0"
SLOT="0"
KEYWORDS="~arm ~x86 ~amd64"
IUSE=""
RDEPEND="
	sys-apps/findutils
	x11-themes/sabayon-artwork-cursor
	x11-themes/sabayon-artwork-grub
	x11-themes/sabayon-artwork-plymouth-default
	x11-themes/sabayon-artwork-wallpapers
"

S="${WORKDIR}"

src_install() {
        insinto /usr/share/pixmaps
        doins ${FILESDIR}/sabayon-logo.png
}

pkg_postinst() {
	# mount boot first
	mount-boot_mount_boot_partition

	einfo "Please report bugs or glitches to"
	einfo "http://bugs.sabayon.org"
}
