# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/amanith/amanith-0.3-r1.ebuild,v 1.2 2007/06/11 04:40:45 vapier Exp $

inherit eutils toolchain-funcs

DESCRIPTION="OpenSource C++ CrossPlatform framework designed for 2d & 3d vector graphics"
HOMEPAGE="http://www.amanith.org/"
SRC_URI="http://www.amanith.org/download/files/${PN}_${PV//.}.tar.gz"

LICENSE="QPL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="examples jpeg opengl png truetype"

DEPEND="truetype? ( >=media-libs/freetype-2.2.1 )
	jpeg? ( >=media-libs/jpeg-6b )
	png? ( >=media-libs/libpng-1.2.10 )
	opengl? ( media-libs/glew )
	>=x11-libs/qt-4.1.0"

S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-build.patch
	epatch "${FILESDIR}"/${P}-gcc4.patch
	epatch "${FILESDIR}"/${P}-freetype.patch #179734
	epatch "${FILESDIR}"/${P}-glew-update.patch

	rm -rf 3rdpart include/GL || die
	sed -i -e '/SUBDIRS/s:3rdpart::' amanith.pro || die

	use_plugin() { use $1 || sed -i -e "/DEFINES.*_$2_PLUGIN/d" config/settings.conf ; }
	use_plugin jpeg JPEG
	use_plugin opengl OPENGLEXT
	use_plugin png PNG
	use_plugin truetype FONTS
	sed -i -e '/USE_QT4/s:#::' config/settings.conf || die
	sed -i -e '/SUBDIRS/s:examples::' amanith.pro || die
}

src_compile() {
	export AMANITHDIR=${S}
	# make sure our env settings are respected
	qmake \
		-unix \
		QMAKE_CC=$(tc-getCC) \
		QMAKE_CXX=$(tc-getCXX) \
		QMAKE_CFLAGS="${CFLAGS}" \
		QMAKE_CXXFLAGS="${CXXFLAGS}" \
		QMAKE_LFLAGS="${LDFLAGS}" \
		|| die "qmake failed"
	emake || die "emake failed"
}

src_install() {
	dolib.so lib/*.so* plugins/*.so* || die

	insinto /usr/include
	doins -r include/amanith || die

	dodoc CHANGELOG FAQ README doc/amanith.chm

	if use examples ; then
		insinto /usr/share/doc/${PF}/examples
		doins -r examples data config || die
	fi
}
