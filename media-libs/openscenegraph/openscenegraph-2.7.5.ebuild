# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

MY_P="OpenSceneGraph-${PV}"

DESCRIPTION="an open source high performance 3D graphics toolkit"
HOMEPAGE="http://www.openscenegraph.org/"
SRC_URI="http://www.openscenegraph.org/downloads/developer_releases/OpenSceneGraph-${PV}.zip"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~ppc"
IUSE=""

RDEPEND="virtual/opengl
	media-libs/jpeg 
	media-libs/tiff
    	media-libs/giflib
	media-libs/freetype
	media-libs/libpng 
	media-libs/lib3ds"
DEPEND="${DEPEND}
		>=dev-util/cmake-2.6"

S="${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-pkgconfig.patch
        epatch "${FILESDIR}"/${PN}-osgga.patch
        #epatch "${FILESDIR}"/${PN}-openthreads.patch
}

src_compile() {
	#CCACHE=$(echo $FEATURES | grep 'ccache' | sed 's/.*ccache.*/ccache/g')
	#cmake ${S} -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
	#emake

cmake ${S} \
                -DCMAKE_C_FLAGS="${CFLAGS}" \
                -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
                -DCMAKE_BUILD_TYPE=Release \
                -DCMAKE_INSTALL_PREFIX=/usr \
                -DCMAKE_BUILD_OSG_EXAMPLES=OFF \
		-DCMAKE_BUILD_OSG_WRAPPERS=OFF \
		-DCMAKE_BUILD_OSG_APPLICATIONS=OFF \
		|| die "cmake failed"

	emake || die "emake failed"
}

src_install() {
	make DESTDIR=${D} install || die "einstall failed"
	insinto "/usr/lib/pkgconfig"
	doins ${S}/openthreads.pc || die "failed installing oth pkgconfig"
	doins ${S}/openscenegraph.pc || die "failed installing osg pkgconfig"
}
