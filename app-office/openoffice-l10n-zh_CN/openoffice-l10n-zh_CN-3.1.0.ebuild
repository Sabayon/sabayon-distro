# Copyright 2004-2008 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit rpm multilib
IUSE=""
MY_LANG="${PN/openoffice-l10n-}"
MY_LANG="${MY_LANG/_/-}"
MY_PV="${PV/_/}"
MY_DATE="20080930"
OOO_INSTDIR="/usr/$(get_libdir)/openoffice/basis-link"
DESCRIPTION="OpenOffice.org ${MY_LANG} localisation"
HOMEPAGE="http://go-oo.org"
LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
SRC_URI="mirror://openoffice-extended/${PV}rc2/OOo_${PV}rc2_20090427_LinuxIntel_langpack_${MY_LANG}.tar.gz"

RDEPEND="~app-office/openoffice-${PV}
	>=media-fonts/arphicfonts-0.1-r2"
DEPEND="dev-util/pkgconfig
	dev-util/intltool"

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
		einfo "unpacking "${myrpm}
		rpm_unpack ${S}/${myrpm}
	done
}

src_compile() {
	einfo "nothing to compile"	
}

src_install() {
	dodir ${OOO_INSTDIR}
	MY_SRC="${WORKDIR}/unpack/opt/openoffice.org/basis3.0/*"
	MY_SRC2="${WORKDIR}/unpack/opt/openoffice.org3/*"
	cp -R ${MY_SRC} ${D}/${OOO_INSTDIR}/
	cp -R ${MY_SRC2} ${D}/${OOO_INSTDIR}/
	chown root:root ${D}/${OOO_INSTDIR} -R
}
