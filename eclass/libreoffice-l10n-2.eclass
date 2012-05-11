# Copyright 2004-2012 Sabayon Linux
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

inherit base rpm multilib versionator office-ext

MY_LANG=${PN/libreoffice-l10n-/}
MY_LANG=${MY_LANG/_/-}

# export all the available functions here
EXPORT_FUNCTIONS src_unpack src_prepare src_configure src_compile src_install pkg_postinst pkg_prerm

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
RESTRICT="nomirror"

L10N_VER="$(get_version_component_range 1-3)"
L10N_RC_VERSION="rc2"
LO_BRANCH=$(get_version_component_range 1-2)

BASE_SRC_URI="http://download.documentfoundation.org/libreoffice/stable/${L10N_VER}/rpm"
SRC_URI=""
# try guessing
if [ "${LANGPACK_AVAIL}" = "1" ]; then
	SRC_URI+="${BASE_SRC_URI}/x86/LibO_${L10N_VER}_Linux_x86_langpack-rpm_${MY_LANG}.tar.gz"
fi
if [ "${HELPPACK_AVAIL}" = "1" ]; then
	SRC_URI+=" ${BASE_SRC_URI}/x86/LibO_${L10N_VER}_Linux_x86_helppack-rpm_${MY_LANG}.tar.gz"
fi

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
		rpmdir="LibO_${L10N_VER}${L10N_RC_VERSION}_Linux_x86_langpack-rpm_${dir}/RPMS/"
		[[ -d ${rpmdir} ]] || die "Missing directory: \"${rpmdir}\""
		# First remove dictionaries, we want to use system ones.
		rm -rf "${S}/${rpmdir}/"*dict*.rpm
		einfo "Unpacking Langpack"
		rpm_unpack "./${rpmdir}/"*.rpm
	fi
	if [[ "${HELPPACK_AVAIL}" == "1" ]]; then
		rpmdir="LibO_${L10N_VER}${L10N_RC_VERSION}_Linux_x86_helppack-rpm_${dir}/RPMS/"
		[[ -d ${rpmdir} ]] || die "Missing directory: \"${rpmdir}\""
		einfo "Unpacking Helppack"
		rpm_unpack ./"${rpmdir}/"*.rpm
	fi
	if [[ -n "${TDEPEND}" ]]; then
		if use templates; then
			for i in ${OO_EXTENSIONS[@]}; do
				if [[ ! -f "${S}/${i}" ]]; then
					cp -v "${DISTDIR}/${i}" "${S}"
					ooextused+=( "${i}" )
				fi
                	done
		fi
	fi
	OO_EXTENSIONS=()
	for i in ${ooextused[@]}; do
		OO_EXTENSIONS+=( ${i} )
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

	echo "${OO_EXTENSIONS[@]}"
	office-ext_src_install
}

libreoffice-l10n-2_pkg_postinst() {
	office-ext_pkg_postinst
}
libreoffice-l10n-2_pkg_prerm() {
	office-ext_pkg_prerm
}
