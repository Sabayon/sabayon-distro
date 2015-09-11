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
	x11-themes/${SDDM_THEME}
	kde-plasma/plasma-meta
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

pkg_postinst() {
    local systemd="/etc/systemd"
    local ud=$(_systemd_get_unitdir)
    # Yeah, i know. that's ugly. Shame on me. But KDM doesn't support plasma5, kde4 is dropped.
    if grep --quiet "ExecStart=/usr/bin/kdm" "${ROOT}"/"${systemd}"/system/display-manager.service; then
        # Trying to make the migration as smooth as possible
        einfo "Migrating from kdm to sddm for you"
        # Remove previously selected display-manager
        rm -rf "${ROOT}"/"${systemd}"/system/display-manager.service
        # Forcing sddm, since kdm won't support plasma5 at all
        ln -s   "${ROOT}"/"${ud}"/sddm.service "${ROOT}"/"${systemd}"/system/display-manager.service
        einfo "If you face issues, please file a bug : https://bugs.sabayon.org/"
    else
        einfo "Seems that you haven't enabled kdm, if you plan to use plasma5, keep in mind that kdm won't work, you have to enable sddm with systemctl:"
        einfo "\tsystemctl enable sddm"
        einfo "If you face issues, please file a bug : https://bugs.sabayon.org/"
    fi
}
