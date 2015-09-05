# Copyright 2004-2013 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $

inherit kde5

MY_LANG="${PN/kde-l10n-/}"

# export all the available functions here
EXPORT_FUNCTIONS src_prepare src_configure

L10N_NAME="${L10N_NAME:-${MY_LANG}}"
DESCRIPTION="KDE ${L10N_NAME} localization package"
HOMEPAGE="http://l10n.kde.org"
LICENSE="GPL-2"

KEYWORDS="~amd64 ~arm ~x86"

DEPEND="
	sys-devel/gettext
"
RDEPEND="
	!<kde-apps/kde-l10n-${PV}
"

IUSE="+handbook"
KDE_HANDBOOK="true"

URI_BASE="${SRC_URI/-${MY_LANG}-${PV}.tar.xz/}"
SRC_URI="${SRC_URI} ${URI_BASE}/${PN}-${PV}.tar.xz"

kde-l10n_src_configure() {
	mycmakeargs=(
		$(cmake-utils_use_find_package handbook KF5DocTools)
	)
	kde5_src_configure
}

kde-l10n_src_compile() {
	kde5_src_compile
}

kde-l10n_src_test() {
	kde5_src_test
}

kde-l10n_src_install() {
	kde5_src_install
}

kde-l10n_src_prepare() {
	
	# Drop KDE4-based part
	sed -e '/add_subdirectory(4)/ s/^/#/'\
		-i "${S}"/CMakeLists.txt || die
	
	# Handbook optional
	sed -e '/KF5DocTools/ s/ REQUIRED//'\
		-i "${S}"/5/${MY_LANG}/CMakeLists.txt || die
	if ! use handbook ; then
		sed -e '/add_subdirectory(docs)/ s/^/#/'\
			-i "${S}"/5/${MY_LANG}/CMakeLists.txt || die
	fi
	
	# Fix broken LINGUAS=sr (KDE4 leftover)
	if [[ ${MY_LANG} = "sr" ]] ; then
		sed -e '/add_subdirectory(lokalize)/ s/^/#/'\
			-i "${S}"/5/${MY_LANG}/data/kdesdk/CMakeLists.txt || die
	fi
}
