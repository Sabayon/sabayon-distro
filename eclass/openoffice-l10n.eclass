# Copyright 2004-2010 Sabayon Project
# Distributed under the terms of the GNU General Public License v2
# $

EAPI="2"

inherit base rpm multilib

MY_LANG=${PN/openoffice-l10n-/}
MY_LANG=${MY_LANG/_/-}
MY_PV="${PV/_/}"

# export all the available functions here
EXPORT_FUNCTIONS src_unpack src_prepare src_install

# @ECLASS-VARIABLE: L10N_LANG
# @DESCRIPTION:
# Localization language name
L10N_LANG="${L10N_LANG:-${MY_LANG}}"

DESCRIPTION="OpenOffice.org ${L10N_LANG} localisation"
HOMEPAGE="http://projects.openoffice.org/native-lang.html"
if [[ "${PV}" = "3.2.0" ]]; then
	SRC_URI="mirror://openoffice-extended/${PV}rc5/OOo_${PV}rc5_20100203_LinuxIntel_langpack_${MY_LANG}.tar.gz"
elif [[ "${PV}" = "3.2.1" ]]; then
	SRC_URI="mirror://openoffice-extended/${PV}rc2/OOo_${PV}rc2_20100521_Linux_x86_langpack-rpm_${MY_LANG}.tar.gz"
else
	SRC_URI="--NOT_SET_SEE_openoffice-l10n.eclass--"
fi

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="~app-office/openoffice-${PV}"
DEPEND="dev-util/pkgconfig
	dev-util/intltool"

S="${WORKDIR}/*/RPMS"

OOO_INSTDIR="/usr/$(get_libdir)/openoffice"

openoffice-l10n_src_unpack() {
	cd "${WORKDIR}"
	unpack "${A}"
	mkdir "${WORKDIR}/unpack"
	cd "${WORKDIR}/unpack"
	rpm_unpack ${S}/*.rpm
}

openoffice-l10n_src_prepare() {
	einfo "nothing to prepare"
}

openoffice-l10n_src_install() {
	dodir "${OOO_INSTDIR}"
	local MY_SRC="${WORKDIR}/unpack/opt/openoffice.org/*"
	local MY_SRC2="${WORKDIR}/unpack/opt/openoffice.org3/*"
	cp -R ${MY_SRC} "${D}${OOO_INSTDIR}/" || die "cannot copy"
	cp -R ${MY_SRC2} "${D}${OOO_INSTDIR}/basis${PV:0:3}/" || die "cannot copy"
	# FIXME: upstream bug, localisations listed below try to install the same file
	# as ast bg bn dz el eo fi ga gu hi_IN km ku lv mk ml mr my oc om or pa_IN si ta te tr ug uk uz
	local dict_file="${D}${OOO_INSTDIR}/basis${PV:0:3}/share/extension/install/dict-en.oxt"
	[[ -f "${dict_file}" ]] && ewarn "Removing ${dict_file} due to collisions..." \
		&& rm -f "${dict_file}"
	chown root:root ${D}/${OOO_INSTDIR} -R
}
