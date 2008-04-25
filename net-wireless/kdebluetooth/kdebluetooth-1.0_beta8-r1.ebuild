# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/kdebluetooth/kdebluetooth-1.0_beta8.ebuild,v 1.2 2008/03/31 21:42:57 deathwing00 Exp $

inherit kde

DESCRIPTION="KDE Bluetooth Framework"
HOMEPAGE="http://bluetooth.kmobiletools.org/"
#SRC_URI="mirror://sourceforge/kde-bluetooth/${MY_P}.tar.bz2"
# cf. bug 190296
SRC_URI="http://tomstar.ath.cx/load/${PN}/${P}.tar.bz2"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~hppa ~ppc ~sparc ~x86"
IUSE=""

# Localisation will be added once we have a release.

DEPEND=">=dev-libs/openobex-1.1
	app-mobilephone/obexftp
	>=dev-libs/dbus-qt3-old-0.70"

RDEPEND="${DEPEND}
	|| ( ( =kde-base/kdialog-3.5* =kde-base/konqueror-3.5* )  =kde-base/kdebase-3.5* )
	>=net-wireless/bluez-libs-3.11
	>=net-wireless/bluez-utils-3.11"

need-kde 3.5

PATCHES="${FILESDIR}/${P}-gcc43.patch"

src_unpack() {
	kde_src_unpack

	cd "${S}"
	sed -i -e "s:\(MimeType=.*\):\1;:" kdebluetooth/kbtobexclient/kbtobexclient.desktop \
		|| die "sed'ing the desktop file failed"

	rm -f "${S}/configure"
}

src_install() {
	kde_src_install

	# Fix the desktop file
	sed -i -e 's:^\(Categories=.*\):\1;:' \
		"${D}/usr/share/applications/kde/kbtobexsrv.desktop" || die "sed #1 failed"
	sed -i -e 's:^\(MimeTypes\):X-\1:' \
		"${D}/usr/share/applications/kde/kbtobexsrv.desktop" || die "sed #2 failed"
}
