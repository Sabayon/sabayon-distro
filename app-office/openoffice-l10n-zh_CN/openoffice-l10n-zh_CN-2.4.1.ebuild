# Copyright 2004-2008 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

WANT_AUTOCONF="2.5"
WANT_AUTOMAKE="1.9"

inherit rpm multilib

IUSE=""
MY_LANG=${PN/openoffice-l10n-/}
MY_LANG=${MY_LANG/_/-}
MY_PV="${PV/_/}"
MY_DATE="20080529"
OOO_INSTDIR="/usr/$(get_libdir)/openoffice"
DESCRIPTION="OpenOffice.org ${MY_LANG} localisation"
HOMEPAGE="http://go-oo.org"
LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
SRC_URI="mirror://openoffice-extended/${PV}rc2/OOo_${PV}rc2_20080529_LinuxIntel_langpack_${MY_LANG}.tar.gz"

RDEPEND=">=media-fonts/arphicfonts-0.1-r2
	~app-office/openoffice-${PV}"

S="${WORKDIR}/*/RPMS"

pkg_setup() {
	if [ ! -d "${OOO_INSTDIR}" ]; then
		die "OpenOffice install dir not found"
	fi
}

src_unpack() {
	cd ${WORKDIR}
	unpack ${A}
	mkdir ${WORKDIR}/unpack
	cd ${WORKDIR}/unpack
	for myrpm in `/bin/ls ${S}`; do
		rpm_unpack ${S}/${myrpm}
	done
}

src_compile() {
	einfo "nothing to compile"	
}

src_install() {
	MY_SRC="${WORKDIR}/unpack/opt/*/*"
	dodir ${OOO_INSTDIR}
	mv ${MY_SRC} ${D}/${OOO_INSTDIR}/
	chown root:root ${D}/${OOO_INSTDIR} -R
}
