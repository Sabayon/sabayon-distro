# Copyright 2004-2010 Sabayon Project
# Distributed under the terms of the GNU General Public License v2
# $

EAPI="3"

inherit base rpm multilib

MY_LANG=${PN/libreoffice-l10n-/}
MY_LANG=${MY_LANG/_/-}
MY_PV="${PV/_/}"

# export all the available functions here
EXPORT_FUNCTIONS src_unpack src_prepare src_install

# @ECLASS-VARIABLE: L10N_LANG
# @DESCRIPTION:
# Localization language name
L10N_LANG="${L10N_LANG:-${MY_LANG}}"

# @ECLASS-VARIABLE: HELPPACK_AVAIL
# @DESCRIPTION:
# Set this to "0" if help pack package is not available
HELPPACK_AVAIL="${HELPPACK_AVAIL:-1}"

DESCRIPTION="LibreOffice.org ${L10N_LANG} localisation"
HOMEPAGE="http://www.documentfoundation.org"
RESTRICT="nomirror"
OOVER="${PV}"
OODLVER="${PV}"
if [[ "${PV}" = "3.3.1" ]]; then
	SRC_URI="http://download.documentfoundation.org/libreoffice/stable/${OOVER}/rpm/x86/LibO_${OODLVER}_Linux_x86_langpack-rpm_${MY_LANG}.tar.gz
		http://download.documentfoundation.org/libreoffice/stable/${OOVER}/rpm/x86/LibO_${OODLVER}_Linux_x86_helppack-rpm_${MY_LANG}.tar.gz"
elif [[ "${PV}" = "3.3.2" ]]; then
	SRC_URI="http://download.documentfoundation.org/libreoffice/stable/${OOVER}/rpm/x86/LibO_${OODLVER}_Linux_x86_langpack-rpm_${MY_LANG}.tar.gz
		http://download.documentfoundation.org/libreoffice/stable/${OOVER}/rpm/x86/LibO_${OODLVER}_Linux_x86_helppack-rpm_${MY_LANG}.tar.gz"
elif [[ "${PV}" = "3.3.3" ]]; then
	SRC_URI="http://download.documentfoundation.org/libreoffice/stable/${OOVER}/rpm/x86/LibO_${OODLVER}_Linux_x86_langpack-rpm_${MY_LANG}.tar.gz
		http://download.documentfoundation.org/libreoffice/stable/${OOVER}/rpm/x86/LibO_${OODLVER}_Linux_x86_helppack-rpm_${MY_LANG}.tar.gz"
elif [[ "${PV}" = "3.4.1" ]]; then
	SRC_URI="http://download.documentfoundation.org/libreoffice/stable/${OOVER}/rpm/x86/LibO_${OODLVER}_Linux_x86_langpack-rpm_${MY_LANG}.tar.gz"
	if [ "${HELPPACK_AVAIL}" = "1" ]; then
		SRC_URI+=" http://download.documentfoundation.org/libreoffice/stable/${OOVER}/rpm/x86/LibO_${OODLVER}_Linux_x86_helppack-rpm_${MY_LANG}.tar.gz"
	fi
elif [[ "${PV}" = "3.4.2.3" ]] || [[ "${PV}" = "3.4.3.2" ]]; then
	SRC_URI="http://download.documentfoundation.org/libreoffice/stable/3.4.2/rpm/x86/LibO_3.4.2_Linux_x86_langpack-rpm_${MY_LANG}.tar.gz"
	if [ "${HELPPACK_AVAIL}" = "1" ]; then
		SRC_URI+=" http://download.documentfoundation.org/libreoffice/stable/3.4.2/rpm/x86/LibO_3.4.2_Linux_x86_helppack-rpm_${MY_LANG}.tar.gz"
	fi
else
	die "unsupported libreoffice-l10n ${PV}"
fi

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="~app-office/libreoffice-${PV}"
DEPEND="dev-util/pkgconfig
	dev-util/intltool"

S="${WORKDIR}/*/RPMS"

OOO_INSTDIR="/usr/$(get_libdir)/libreoffice"

libreoffice-l10n_src_unpack() {
	cd "${WORKDIR}"
	unpack ${A}
	mkdir "${WORKDIR}/unpack"
	cd "${WORKDIR}/unpack"
	rpm_unpack ${S}/*.rpm
}

libreoffice-l10n_src_prepare() {
	einfo "nothing to prepare"
}

libreoffice-l10n_src_install() {
	dodir "${OOO_INSTDIR}/basis-link"
	if [ "${PV:0:3}" = "3.3" ]; then
		cp -R "${WORKDIR}"/unpack/opt/libreoffice/basis${PV:0:3}/* \
		"${ED}${OOO_INSTDIR}/basis-link/" || die "cannot copy"
		cp -R "${WORKDIR}"/unpack/opt/libreoffice/{program,readmes} \
			"${ED}${OOO_INSTDIR}/" || die "cannot copy"
	else
		cp -R "${WORKDIR}"/unpack/opt/libreoffice${PV:0:3}/basis${PV:0:3} \
		"${ED}${OOO_INSTDIR}"/basis${PV:0:3} || die "cannot copy"
		for source_dir in "${WORKDIR}"/unpack/opt/libreoffice${PV:0:3}/{program,readmes}; do
			if [ -d "${source_dir}" ]; then
				cp -R "${source_dir}" "${ED}${OOO_INSTDIR}/" || die "cannot copy"
			fi
		done

	fi
	chown root:root "${ED}/${OOO_INSTDIR}" -R || die "cannot chown"
}
