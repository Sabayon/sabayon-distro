# Copyright 2004-2010 Sabayon Project
# Distributed under the terms of the GNU General Public License v2
# $

EAPI="2"

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
	SRC_URI="http://download.documentfoundation.org/libreoffice/stable/${OOVER}/rpm/x86/LibO_${OODLVER}_Linux_x86_langpack-rpm_${MY_LANG}.tar.gz
		http://download.documentfoundation.org/libreoffice/stable/${OOVER}/rpm/x86/LibO_${OODLVER}_Linux_x86_helppack-rpm_${MY_LANG}.tar.gz"
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
	local MY_SRC="${WORKDIR}/unpack/opt/libreoffice/basis${PV:0:3}"
	cp -R "${WORKDIR}/unpack/opt/libreoffice/basis${PV:0:3}"/* \
		"${D}${OOO_INSTDIR}/basis-link/" || die "cannot copy"
	cp -R "${WORKDIR}/unpack/opt/libreoffice/"{program,readmes} \
		"${D}${OOO_INSTDIR}/" || die "cannot copy"
	chown root:root "${D}/${OOO_INSTDIR}" -R || die "cannot chown"
}
