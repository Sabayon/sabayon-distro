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
IUSE="htmlhandbook"
SRC_URI="${SRC_URI/-${MY_LANG}-${PV}.tar.bz2/}/${PN}-${PV}.tar.bz2"

S="${WORKDIR}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	DIR="${PN}-${PV}"
	if [[ ! -d "${DIR}" ]]; then
		die "Cannot find ${DIR}"
	fi
	echo "add_subdirectory( ${DIR} )" >> "${S}"/CMakeLists.txt
	if ! use htmlhandbook; then
		sed -i -e "/docs/ s:^:#DONOTWANT:" ${DIR}/CMakeLists.txt \
			|| die "Disabling docs for ${MY_LANG} failed."
	fi
}


