# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Sabayon Official Installer"
HOMEPAGE="http://www.sabayon.org/"
SRC_URI=""
LICENSE="CC-BY-SA-4.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=app-misc/calamares-sabayon-base-modules-1.2
	app-misc/calamares-sabayon-branding"
RDEPEND="${DEPEND}
	!!app-admin/anaconda"

S="${FILESDIR}/${P}"
src_install() {
	newbin "${S}/Installer.sh" "installer"
	insinto "/etc/skel/Desktop/"
	newins "${S}/Installer.desktop" "Installer.desktop"
}
