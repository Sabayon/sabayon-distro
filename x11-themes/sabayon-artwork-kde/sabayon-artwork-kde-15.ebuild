# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
#

EAPI=5
CMAKE_REQUIRED="never"
inherit eutils kde4-base sabayon-artwork

DESCRIPTION="Sabayon Linux Official KDE Artwork"
HOMEPAGE="http://www.sabayon.org/"
SRC_URI="mirror://sabayon/${CATEGORY}/${PN}/${PN}-${PVR}.tar.xz"
LICENSE="CCPL-Attribution-ShareAlike-3.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="+ksplash"
RDEPEND="
    x11-misc/lightdm
    x11-misc/lightdm-gtk-greeter
    kde-plasma/plasma-meta
    kde-apps/kde-l10n:5
    !kde-apps/kde-l10n:4
    "


S="${WORKDIR}/${PN}"

src_install() {
    # KDM
    dodir /usr/share/apps/kdm/themes
    cd ${S}/kdm
    insinto /usr/share/apps/kdm/themes
    doins -r ./

    # Kwin
    dodir ${KDEDIR}/share/apps/aurorae/themes/
    cd ${S}/kwin
    insinto ${KDEDIR}/share/apps/aurorae/themes/
    doins -r ./
}

