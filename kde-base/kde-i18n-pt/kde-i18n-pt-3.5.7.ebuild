# Copyright 2004-2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit kde

DESCRIPTION="KDE Portuguese localization"
HOMEPAGE="http://www.kde.org/"
LICENSE="GPL-2"

SLOT="3.5"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE=""

LOCALE=${PN/kde-i18n-/}
need-kde ${PV}

SRC_URI="mirror://kde/stable/${PV}/src/kde-i18n/kde-i18n-${LOCALE}-${PV}.tar.bz2"

src_unpack() {
	# Override kde_src_unpack.
	[[ -n ${A} ]] && unpack ${A}

	# Work around KDE bug 126311.
	for dir in `ls "${WORKDIR}"`; do
		lang=`echo ${dir} | cut -f3 -d-`

		[[ -e "${WORKDIR}/${dir}/docs/common/Makefile.in" ]] || continue
		sed -e "s:\$(KDE_LANG)/${lang}/:\$(KDE_LANG)/:g" \
			-i "${WORKDIR}/${dir}/docs/common/Makefile.in" || die "Failed to fix ${lang}."
	done
}

src_compile() {
	for dir in `ls "${WORKDIR}"`; do
		KDE_S="${WORKDIR}/${dir}"
		kde_src_compile myconf
		myconf="${myconf} --prefix=${KDEDIR}"
		kde_src_compile configure
		kde_src_compile make
	done
}

src_install() {
	for dir in `ls "${WORKDIR}"`; do
		cd "${WORKDIR}/${dir}"
		emake DESTDIR="${D}" install || die
	done
}
