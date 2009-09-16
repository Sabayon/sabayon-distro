# Copyright 2004-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit eutils

DESCRIPTION="Sabayon Linux Official artwork meta-package (for compatibility)"
HOMEPAGE="http://www.sabayonlinux.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""
RDEPEND="
	~x11-themes/sabayon-artwork-core-${PV}
"

pkg_postinst() {
	elog "Please install either:"
	elog "- x11-themes/sabayon-artwork-kde"
	elog "- x11-themes/sabayon-artwork-gnome"
	elog "to get back your artwork files."
	elog "Packages have been split, sorry"
}
