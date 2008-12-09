# Copyright 2004-2008 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit eutils versionator

DESCRIPTION="Sabayon Linux Official upgrade package"
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64 ppc ppc64"
IUSE=""
RESTRICT=""
RDEPEND="app-misc/sabayon-skel
		 !x11-themes/sabayonlinux-artwork"

pkg_postinst () {
	ewarn "This Package is a dummy package to smooth"
	ewarn "the upgrade process to the 4.0 naming scheme of"
	ewarn "Sabayon's Artwork and Skel Packages"
	ewarn ""
	ewarn "sabayonlinux-artwork is now called sabayon-artwork"
	ewarn "sabayonlinux-skel is now called sabayon-skel"
	ewarn ""
	ewarn "Have a Nice Day"
}
