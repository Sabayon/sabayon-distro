# Copyright 2004-2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit kde-functions

DESCRIPTION="KDE internationalization meta-package - merge this to pull in all kde-i18n packages"
HOMEPAGE="http://www.kde.org/"
LICENSE="GPL-2"

SLOT="3.5"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE=""

need-kde ${PV}
LANGS="af ar az bg bn br bs ca cs csb cy da de el en_GB eo es et
eu fa fi fr fy ga gl he hi hr hu is it ja kk km ko lt lv mk
mn ms nb nds nl nn pa pl pt pt_BR ro ru rw se sk sl sr
sr_latn ss sv ta tg th tr uk uz vi zh_CN zh_TW"

#RDEPEND="!kde-base/kde-i18n"
for X in ${LANGS} ; do
	#SRC_URI="${SRC_URI} linguas_${X}? ( mirror://kde/stable/${PV}/src/kde-i18n/kde-i18n-${X}-${PV}.tar.bz2 )"
	IUSE="${IUSE} linguas_${X}"
	RDEPEND="${RDEPEND} ~kde-base/kde-i18n-${X}-${PV}"
done

#src_unpack() {
#	if [[ -z "${LINGUAS}" ]] || [[ -z "${A}" &&	 "${LINGUAS}" != "en" ]]; then
#		echo
#		ewarn "You either have the LINGUAS environment variable unset or it"
#		ewarn "contains languages not supported by kde-base/kde-i18n."
#		ewarn "Because of that, kde-i18n will not add any kind of language"
#		ewarn "support."
#		ewarn
#		ewarn "If you didn't intend this to happen, the available language"
#		ewarn "codes are:"
#		ewarn "${LANGS}"
#		echo
#	fi
#
#	# Override kde_src_unpack.
#	[[ -n ${A} ]] && unpack ${A}
#
#	# Work around KDE bug 126311.
#	for dir in `ls "${WORKDIR}"`; do
#		lang=`echo ${dir} | cut -f3 -d-`
#
#		[[ -e "${WORKDIR}/${dir}/docs/common/Makefile.in" ]] || continue
#		sed -e "s:\$(KDE_LANG)/${lang}/:\$(KDE_LANG)/:g" \
#			-i "${WORKDIR}/${dir}/docs/common/Makefile.in" || die "Failed to fix ${lang}."
#	done
#}

#src_compile() {
#	for dir in `ls "${WORKDIR}"`; do
#		KDE_S="${WORKDIR}/${dir}"
#		kde_src_compile myconf
#		myconf="${myconf} --prefix=${KDEDIR}"
#		kde_src_compile configure
#		kde_src_compile make
#	done
#}

#src_install() {
#	for dir in `ls "${WORKDIR}"`; do
#		cd "${WORKDIR}/${dir}"
#		emake DESTDIR="${D}" install || die
#	done
#}
