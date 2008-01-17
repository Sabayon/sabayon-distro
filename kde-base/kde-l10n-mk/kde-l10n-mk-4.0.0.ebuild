# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="1"

inherit kde4-base

DESCRIPTION="KDE4 mk localization package"
HOMEPAGE="http://www.kde.org/"
LICENSE="GPL-2"

KEYWORDS=""
DEPEND=">=sys-devel/gettext-0.15"
RDEPEND=""
MY_LANG="mk"
IUSE=""
SRC_URI="${SRC_URI/-${MY_LANG}-${PV}.tar.bz2/}/${PN}-${PV}.tar.bz2"

S="${WORKDIR}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	# Create a top-level CMakeLists.txt to include the selected LINGUAS as sub-directories of ${S}
	for dir in * ; do
		[[ -d ${dir} ]] && echo "add_subdirectory( ${dir} )" >> "${S}"/CMakeLists.txt
	done
}
