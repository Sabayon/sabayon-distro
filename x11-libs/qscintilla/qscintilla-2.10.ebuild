# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Meta package for ${PN} (install ${PN}-qt4 or ${PN}-qt5 instead)"
HOMEPAGE="https://www.riverbankcomputing.com/software/qscintilla/intro"
SRC_URI=""

LICENSE="metapackage"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="designer doc +qt4 qt5"

DEPEND="
	qt4? ( =${CATEGORY}/${PN}-qt4-${PVR} )
	qt5? ( =${CATEGORY}/${PN}-qt5-${PVR} )
"
# Depend on qt4 for compatibility which was until the split ebuild was
# introduced.
RDEPEND="
	qt4? ( =${CATEGORY}/${PN}-qt4-${PVR} )
	!qt4? ( =${CATEGORY}/${PN}-qt5-${PVR} )
"
