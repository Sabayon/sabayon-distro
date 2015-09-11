# Copyright 2004-2015 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit systemd

DESCRIPTION="Sabayon KDM -> SDDM migration package"
HOMEPAGE="http://www.sabayon.org/"
LICENSE="GPL-2"
SLOT="4"

KEYWORDS="~amd64 ~x86 ~arm"
IUSE=""
RDEPEND="
            x11-misc/sddm
            x11-themes/sabayon-artwork-sddm-default
            x11-themes/sabayon-artwork-kde
"

S="${WORKDIR}/"

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
