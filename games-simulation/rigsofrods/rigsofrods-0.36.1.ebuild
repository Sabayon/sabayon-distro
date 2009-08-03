# Copyright 2004-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
# $

EAPI="2"
NEED_PYTHON="2.5"
inherit eutils python games cmake-utils
CMAKE_USE_DIR="${WORKDIR}/${PV}/build"
CMAKE_BUILD_TYPE="Release"

DESCRIPTION="Rigs of Rods truck simulator, based on an advanced soft-body physics engine."
HOMEPAGE="http://rigsofrods.blogspot.com"
SRC_URI="mirror://sourceforge/${PN}/${PN}-source-${PV}.tar.gz
	mirror://sourceforge/${PN}/${PN}-contents-${PV}.zip"

LICENSE="GPL-3 CCPL-Attribution-NonCommercial-NoDerivs-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	dev-libs/zziplib[sdl]
	media-gfx/nvidia-cg-toolkit
	media-libs/devil[X,gif,jpeg,opengl,png,sdl,tiff]
	media-libs/freeimage
	x11-libs/wxGTK:2.8[X,opengl,sdl]
	virtual/opengl
	"
DEPEND="${RDEPEND}
	app-arch/unzip"

src_prepare() {

	# Fix compilation, macro not found
	# epatch "${FILESDIR}/${P}-fix-build.patch"
	# Fix CFLAGS
	epatch "${FILESDIR}/${P}-fix-CFLAGS.patch"
	# Fix another wxGTK code bug
	epatch "${FILESDIR}/${P}-fix-wx-error.patch"

	# add missing header
	cp "${FILESDIR}/rornet.h" "${WORKDIR}/${PV}/build/main/source/" || die "rornet.h copy failed"
	cp "${FILESDIR}/rornet.h" "${WORKDIR}/${PV}/build/configurator/source/" || die "rornet.h copy failed"

}
