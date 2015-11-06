# Copyright 2004-2014 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
# $

inherit rpm eutils multilib versionator

MY_PV=$(get_version_component_range 1-3)

HOMEPAGE="http://www.libreoffice.org"

LICENSE="|| ( LGPL-3 MPL-1.1 )"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86 ~amd64-linux ~x86-linux"
IUSE="offlinehelp"

MY_LANG=${PN/libreoffice-l10n-/}
MY_LANG=${MY_LANG/_/-}

# export all the available functions here
EXPORT_FUNCTIONS src_unpack src_prepare src_configure src_compile src_install

# @ECLASS-VARIABLE: L10N_LANG
# @DESCRIPTION:
# Localization language name
L10N_LANG="${L10N_LANG:-${MY_LANG}}"

# @ECLASS-VARIABLE: HELPPACK_AVAIL
# @DESCRIPTION:
# Set this to "0" if help pack package is not available
HELPPACK_AVAIL="${HELPPACK_AVAIL:-1}"

# @ECLASS-VARIABLE: LANGPACK_AVAIL
# @DESCRIPTION:
# Set this to "0" if lang pack package is not available
LANGPACK_AVAIL="${LANGPACK_AVAIL:-1}"

DESCRIPTION="LibreOffice.org ${L10N_LANG} localisation"

L10N_VER="$(get_version_component_range 1-3)"
L10N_RC_VERSION="$(get_version_component_range 4)"
LO_BRANCH=$(get_version_component_range 1-2)

BASE_SRC_URI="http://download.documentfoundation.org/${PN/-l10n/}/stable/${MY_PV}/rpm"

SRC_URI=""

# try guessing
if [ "${LANGPACK_AVAIL}" = "1" ]; then
	langpack=""
	[[ ${MY_LANG} == en ]] \
		|| langpack="${BASE_SRC_URI}/x86/LibreOffice_${MY_PV}_Linux_x86_rpm_langpack_${MY_LANG/_/-}.tar.gz"
	[[ -z ${langpack} ]] || SRC_URI+=" linguas_${MY_LANG}? ( ${langpack} )"
	IUSE+=" linguas_${MY_LANG}"
fi

if [ "${HELPPACK_AVAIL}" = "1" ]; then
	helppack=""
	[[ ${MY_LANG} == en ]] && lang2=${MY_LANG/en/en_US} || lang2=${MY_LANG}
	helppack="offlinehelp? ( ${BASE_SRC_URI}/x86/LibreOffice_${MY_PV}_Linux_x86_rpm_helppack_${lang2/_/-}.tar.gz )"
	SRC_URI+=" linguas_${MY_LANG}? ( ${helppack} )"
fi

unset lang helppack langpack lang2

RDEPEND+="app-text/hunspell"

RESTRICT="strip"

S="${WORKDIR}"

libreoffice-l10n-2_src_unpack() {
	default

	local lang="${MY_LANG}"
	local dir=${lang/_/-}
	# for english we provide just helppack, as translation is always there
	if [[ "${LANGPACK_AVAIL}" == "1" ]]; then
		if [[ ${MY_LANG} != en ]]; then
			rpmdir="LibreOffice_${PV}_Linux_x86_rpm_langpack_${dir}/RPMS/"
			[[ -d ${rpmdir} ]] || die "Missing directory: \"${rpmdir}\""
			# First remove dictionaries, we want to use system ones.
			rm -rf "${S}/${rpmdir}/"*dict*.rpm
			rpm_unpack "./${rpmdir}/"*.rpm
		fi
	fi
	if [[ "${HELPPACK_AVAIL}" == "1" ]]; then
		if [[ "${LANGUAGES_HELP}" =~ " ${MY_LANG} " ]]; then
			[[ ${MY_LANG} == en ]] && dir="en-US"
			rpmdir="LibreOffice_${PV}_Linux_x86_rpm_helppack_${dir}/RPMS/"
			[[ -d ${rpmdir} ]] || die "Missing directory: \"${rpmdir}\""
			rpm_unpack ./"${rpmdir}/"*.rpm
		fi
	fi
}

libreoffice-l10n-2_src_prepare() { :; }
libreoffice-l10n-2_src_configure() { :; }
libreoffice-l10n-2_src_compile() { :; }

libreoffice-l10n-2_src_install() {
local dir="${S}"/opt/libreoffice${LO_BRANCH}/
# Condition required for people that do not install anything eg no linguas
# or just english with no offlinehelp.
if [[ -d "${dir}" ]] ; then
	insinto /usr/$(get_libdir)/libreoffice/
	doins -r "${dir}"/*
fi
# remove extensions that are in the l10n for some weird reason
rm -rf "${ED}"/usr/$(get_libdir)/libreoffice/share/extensions/
}
