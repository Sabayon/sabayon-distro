# Copyright 1999-2015 Sabayon
# Distributed under the terms of the GNU General Public License v2
#

EAPI=5
inherit eutils sabayon-artwork

DESCRIPTION="Official Sabayon Linux SDDM base Artwork"
HOMEPAGE="http://www.sabayon.org/"

LICENSE="CCPL-Attribution-ShareAlike-3.0"
SLOT="0"
KEYWORDS="~arm ~x86 ~amd64"
IUSE=""
RDEPEND="
	sys-apps/findutils
	x11-misc/sddm
"
S="${WORKDIR}/"
src_install() {	
	# Plymouth default config file
	insinto /etc/sddm
	doins "${FILESDIR}"/sddm.conf
	sed -i -e "s:SDDM_THEME:${SDDM_THEME}:g" "${D}"/etc/sddm/sddm.conf
}

pkg_postinst() {
	einfo "Please report bugs or glitches to"
	einfo "http://bugs.sabayon.org"
}
