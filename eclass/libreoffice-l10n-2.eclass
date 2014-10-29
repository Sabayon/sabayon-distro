# Copyright 2004-2014 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
# $

OO_EXTENSIONS=(
	"472ffb92d82cf502be039203c606643d-Sun-ODF-Template-Pack-en-US_1.0.0.oxt"
	"53ca5e56ccd4cab3693ad32c6bd13343-Sun-ODF-Template-Pack-de_1.0.0.oxt"
	"4ad003e7bbda5715f5f38fde1f707af2-Sun-ODF-Template-Pack-es_1.0.0.oxt"
	"a53080dc876edcddb26eb4c3c7537469-Sun-ODF-Template-Pack-fr_1.0.0.oxt"
	"09ec2dac030e1dcd5ef7fa1692691dc0-Sun-ODF-Template-Pack-hu_1.0.0.oxt"
	"b33775feda3bcf823cad7ac361fd49a6-Sun-ODF-Template-Pack-it_1.0.0.oxt"
)

inherit base rpm multilib versionator

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
HOMEPAGE="http://www.documentfoundation.org"
RESTRICT="mirror"

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

unset name_part

IUSE=""

EXT_URI="http://ooo.itc.hu/oxygenoffice/download/libreoffice"
TDEPEND=""
if [[ "${MY_LANG}" == "en_US" ]]; then
	for i in ${OO_EXTENSIONS[@]}; do
		TDEPEND+=" ${EXT_URI}/${i}"
	done
	SRC_URI+=" templates? ( ${TDEPEND} )"
	IUSE+=" templates"
fi

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="=app-office/libreoffice-${LO_BRANCH}*"
DEPEND="dev-util/pkgconfig
	dev-util/intltool"

S="${WORKDIR}"

OOO_INSTDIR="/usr/$(get_libdir)/libreoffice"

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
	if [[ -n "${TDEPEND}" ]]; then
		if use templates; then
			for i in "${OO_EXTENSIONS[@]}"; do
				if [[ ! -f "${S}/${i}" ]]; then
					cp -v "${DISTDIR}/${i}" "${S}"
					ooextused+=( "${i}" )
				fi
                	done
		fi
	fi
	OO_EXTENSIONS=()
	for i in "${ooextused[@]}"; do
		OO_EXTENSIONS+=( "${i}" )
	done
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
