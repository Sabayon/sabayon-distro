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

if [ -n "${L10N_RC_VERSION}" ]; then
	# this is a RC, thus testing
	BASE_SRC_URI="http://download.documentfoundation.org/libreoffice/testing/${L10N_VER}/rpm"
	TARBALL_VERSION="${L10N_VER}.${L10N_RC_VERSION}"
else
	BASE_SRC_URI="http://download.documentfoundation.org/libreoffice/stable/${L10N_VER}/rpm"
	TARBALL_VERSION="${L10N_VER}"
fi
SRC_URI=""
if [ "$(get_version_component_range 1)" = "3" ]; then
	URI_PREFIX="LibO"
	RPM_SUFFIX_LANG="langpack-rpm"
	RPM_SUFFIX_HELP="helppack-rpm"
else
	URI_PREFIX="LibreOffice"
	RPM_SUFFIX_LANG="rpm_langpack"
	RPM_SUFFIX_HELP="rpm_helppack"
fi

# remove "name_part" when not needed
if [[ ${PV} = 4.2.6.* || ${PV} = 4.2.6 ]]; then
	name_part=-secfix
else
	name_part=
fi

# try guessing
if [ "${LANGPACK_AVAIL}" = "1" ]; then
	SRC_URI+="${BASE_SRC_URI}/x86/${URI_PREFIX}_${TARBALL_VERSION}${name_part}_Linux_x86_${RPM_SUFFIX_LANG}_${MY_LANG}.tar.gz"
fi
if [ "${HELPPACK_AVAIL}" = "1" ]; then
	SRC_URI+=" ${BASE_SRC_URI}/x86/${URI_PREFIX}_${TARBALL_VERSION}${name_part}_Linux_x86_${RPM_SUFFIX_HELP}_${MY_LANG}.tar.gz"
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
		rpmdir="${URI_PREFIX}_${TARBALL_VERSION}"*"_Linux_x86_${RPM_SUFFIX_LANG}_${dir}/RPMS/"
		# First remove dictionaries, we want to use system ones.
		rm -rf "${S}/${rpmdir}/"*dict*.rpm
		einfo "Unpacking Langpack"
		rpm_unpack ./${rpmdir}/*.rpm
	fi
	if [[ "${HELPPACK_AVAIL}" == "1" ]]; then
		rpmdir="${URI_PREFIX}_${TARBALL_VERSION}"*"_Linux_x86_${RPM_SUFFIX_HELP}_${dir}/RPMS/"
		einfo "Unpacking Helppack"
		rpm_unpack ./${rpmdir}/*.rpm
	fi
}

libreoffice-l10n-2_src_prepare() { :; }
libreoffice-l10n-2_src_configure() { :; }
libreoffice-l10n-2_src_compile() { :; }

libreoffice-l10n-2_src_install() {
	local dir="${S}"/opt/${PN/-l10n/}$(get_version_component_range 1-2)/
	# Condition required for people that do not install anything eg no linguas
	# or just english with no offlinehelp.
	if [[ -d "${dir}" ]] ; then
		insinto /usr/$(get_libdir)/${PN/-l10n/}/
		doins -r "${dir}"/*
	fi
	# remove extensions that are in the l10n for some weird reason
	rm -rf "${ED}"/usr/$(get_libdir)/${PN/-l10n/}/share/extensions/
}
