# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

PYTHON_DEPEND="2:2.7"

inherit eutils python scons-utils versionator

MY_PV=$(replace_version_separator 3 'r')

DESCRIPTION="Flexible Isometric Free Engine, 2D"
HOMEPAGE="http://fifengine.de"
SRC_URI="http://downloads.sourceforge.net/project/${PN}/active/src/${PN}-${MY_PV}.tar.gz"

LICENSE="GPL-2"

KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="opengl debug profile"

RDEPEND="dev-libs/boost
	dev-python/pyyaml
	media-libs/libsdl
	media-libs/sdl-ttf
	media-libs/sdl-image[png]
	media-libs/libvorbis
	media-libs/libogg
	media-libs/openal
	sys-libs/zlib
	x11-libs/libXcursor
	x11-libs/libXext
	dev-games/guichan[sdl]
	opengl? ( virtual/opengl virtual/glu )"
DEPEND="${RDEPEND}
	dev-lang/swig"

S=${WORKDIR}/${PN}-${MY_PV}

src_prepare() {
	rm -r ext #delete bundled libs
	epatch "${FILESDIR}/${P}-unbundle-libpng.patch"
}

# Can compiles only with one thread
SCONSOPTS="-j1"

src_compile() {
	export CXXFLAGS="$CXXFLAGS -DBOOST_FILESYSTEM_VERSION=2"
	escons \
		--python-prefix="${D}/$(python_get_sitedir)" \
		--prefix="${D}/usr" \
		$(use_scons debug) \
		$(use_scons debug log log) \
		$(use_scons opengl) \
		$(use_scons profile) \
		|| die "scons failed"
}

src_install() {
	escons install-python --python-prefix="${D}/$(python_get_sitedir)" \
		--prefix="${D}/usr" || die "install failed"
}
