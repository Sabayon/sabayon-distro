# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/aqsis/aqsis-1.6.0.ebuild,v 1.3 2011/03/22 09:48:08 jlec Exp $

EAPI="1"

inherit versionator multilib eutils cmake-utils

DESCRIPTION="Open source RenderMan-compliant 3D rendering solution"
HOMEPAGE="http://www.aqsis.org"
if [[ "${P}" == *_p* ]] ; then
	# snapshot
	_PV=($(get_version_components ${PV}))
	DATE="${_PV[3]/p/}"
	DATE="${DATE:0:4}-${DATE:4:2}-${DATE:6:2}"
	MY_P="${PN}-$(get_version_component_range 1-3)-${DATE}"
	SRC_URI="http://download.aqsis.org/builds/testing/source/tar/${MY_P}.tar.gz"
	S="${WORKDIR}/${PN}-$(get_version_component_range 1-3)"
else
	SRC_URI="mirror://sourceforge/aqsis/${P}.tar.gz"
fi

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="+fltk openexr"

RDEPEND="
	>=dev-libs/boost-1.34.0
	>=media-libs/tiff-3.7.1
	>=sys-libs/zlib-1.1.4
	fltk? ( >=x11-libs/fltk-1.1.10-r2:1 )
	openexr? ( media-libs/openexr )"

DEPEND="
	${RDEPEND}
	dev-libs/libxslt
	>=dev-util/cmake-2.6.3
	>=sys-devel/bison-1.35
	>=sys-devel/flex-2.5.4"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/aqsis_boost1.46.patch"
}

src_compile() {
	if use fltk ; then
		# hack to get fltk library/include paths
		# (upstream doesn't autodetect the gentoo install path for fltk)
		fltk_version="$(get_version_component_range 1 \
			$(best_version x11-libs/fltk | sed -e 's/^x11-libs\/fltk//'))"
		mycmakeargs="${mycmakeargs}
			-DAQSIS_USE_FLTK:BOOL=ON
			-DAQSIS_FLTK_INCLUDE_DIR:PATH=$(fltk-config --includedir)
			-DAQSIS_FLTK_LIBRARIES_DIR:PATH=/usr/$(get_libdir)/fltk-${fltk_version}"
	else
		mycmakeargs="${mycmakeargs} -DAQSIS_USE_FLTK:BOOL=OFF"
	fi

	mycmakeargs="${mycmakeargs}
		-DAQSIS_BOOST_LIB_SUFFIX:STRING=-mt
		-DAQSIS_USE_OPENEXR:BOOL=$(use openexr && echo ON || echo OFF)
		-DAQSIS_USE_RPATH:BOOL=OFF
		-DLIBDIR:STRING=$(get_libdir)
		-DSYSCONFDIR:STRING=/etc
		-DCMAKE_INSTALL_PREFIX:PATH=/usr"

	cmake-utils_src_compile
}

src_install() {
	DOCS="AUTHORS INSTALL README"
	newdoc "release-notes/1.6/summary-1.6.0.txt" ReleaseNotes
	cmake-utils_src_install
}
