# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils

DESCRIPTION="Sabayon Official Installer"
HOMEPAGE="http://www.sabayon.org/"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/installer-desktop-icon.png"
LICENSE="CC-BY-SA-4.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=app-misc/calamares-sabayon-base-modules-1.2
	app-misc/calamares-sabayon-branding"
RDEPEND="${DEPEND}
	!!app-admin/anaconda"

src_unpack() {
	mkdir "${WORKDIR}/${P}"
	cp "${DISTDIR}/${A}" "${WORKDIR}/${P}/"
}

src_install() {
	newbin "${FILESDIR}/Installer.sh" "installer"
	insinto "/etc/skel/Desktop/"
	newins "${FILESDIR}/Installer.desktop" "Installer.desktop"
	fperms +x /etc/skel/Desktop/Installer.desktop
	doicon "${S}/installer-desktop-icon.png"
}
