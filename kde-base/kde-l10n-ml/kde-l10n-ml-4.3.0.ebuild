# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit kde4-base

MY_LANG="${PN/kde-l10n-/}"
DESCRIPTION="KDE4 ${MY_LANG} localization package"
HOMEPAGE="http://www.kde.org/"
LICENSE="GPL-2"

KEYWORDS="~amd64 ~x86"
DEPEND=">=sys-devel/gettext-0.15"
RDEPEND=""
IUSE="+handbook"
SRC_URI="${SRC_URI/-${MY_LANG}-${PV}.tar.bz2/}/${PN}-${PV}.tar.bz2"

src_unpack() {
	unpack "${A}"
	cd "${S}"
	DIR="${PN}-${PV}"
	if [[ -d "${DIR}" ]]; then
		echo "add_subdirectory( ${DIR} )" >> "${S}"/CMakeLists.txt
	fi
}

src_prepare() {
	# override kde4-base_src_prepare which
	# fails at enable_selected_doc_linguas
	base_src_prepare
}

src_configure() {
	mycmakeargs="${mycmakeargs}
		$(cmake-utils_use_build handbook docs)"
	kde4-base_src_configure
}


