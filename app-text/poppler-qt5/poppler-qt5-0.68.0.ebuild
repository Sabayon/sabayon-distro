# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils flag-o-matic toolchain-funcs xdg-utils

MY_PN=poppler
MY_P=poppler${P#${PN}}
DESCRIPTION="Qt5 bindings for poppler"
HOMEPAGE="https://poppler.freedesktop.org/"
SRC_URI="https://poppler.freedesktop.org/poppler-${PV}.tar.xz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86 ~arm"
SLOT="0/79"
IUSE="cjk curl cxx debug doc +jpeg +jpeg2k +lcms nss png tiff +utils"
S="${WORKDIR}/poppler-${PV}"

# No test data provided
RESTRICT="test"

COMMON_DEPEND="
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtxml:5
"

DEPEND="${COMMON_DEPEND}
	dev-util/glib-utils
	virtual/pkgconfig
"
RDEPEND="${COMMON_DEPEND}
	~app-text/poppler-base-${PV}[cjk=,cxx=,jpeg=,jpeg2k=,lcms=,png=,tiff=,utils=,curl=,debug=,doc=,nss=]
"

PATCHES=(
	"${FILESDIR}/${MY_PN}-0.60.1-qt5-dependencies.patch"
	"${FILESDIR}/${MY_PN}-0.28.1-fix-multilib-configuration.patch"
	"${FILESDIR}/${MY_PN}-0.61.0-respect-cflags.patch"
	"${FILESDIR}/${MY_PN}-0.57.0-disable-internal-jpx.patch"
)
src_prepare() {

	cmake-utils_src_prepare

	# Clang doesn't grok this flag, the configure nicely tests that, but
	# cmake just uses it, so remove it if we use clang
	if [[ ${CC} == clang ]] ; then
		sed -i -e 's/-fno-check-new//' cmake/modules/PopplerMacros.cmake || die
	fi

	if ! grep -Fq 'cmake_policy(SET CMP0002 OLD)' CMakeLists.txt ; then
		sed '/^cmake_minimum_required/acmake_policy(SET CMP0002 OLD)' \
			-i CMakeLists.txt || die
	else
		einfo "policy(SET CMP0002 OLD) - workaround can be removed"
	fi

	# we need to up the C++ version, bug #622526, #643278
	append-cxxflags -std=c++11
}

src_configure() {
	xdg_environment_reset
	local mycmakeargs=(
		-DBUILD_GTK_TESTS=OFF
		-DBUILD_QT5_TESTS=OFF
		-DBUILD_CPP_TESTS=OFF
		-DENABLE_SPLASH=ON
		-DENABLE_ZLIB=ON
		-DENABLE_ZLIB_UNCOMPRESS=OFF
		-DENABLE_XPDF_HEADERS=ON
		-DSPLASH_CMYK=OFF
		-DUSE_FIXEDPOINT=OFF
		-DUSE_FLOAT=OFF
		-DWITH_Cairo=OFF
		-DENABLE_LIBCURL=$(usex curl)
		-DENABLE_CPP=$(usex cxx)
		-DWITH_GObjectIntrospection=OFF
		-DWITH_JPEG=$(usex jpeg)
		-DENABLE_DCTDECODER=$(usex jpeg libjpeg none)
		-DENABLE_LIBOPENJPEG=$(usex jpeg2k openjpeg2 none)
		-DENABLE_CMS=$(usex lcms lcms2 none)
		-DWITH_NSS3=$(usex nss)
		-DWITH_PNG=$(usex png)
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt5Core=OFF
		-DWITH_TIFF=$(usex tiff)
		-DENABLE_UTILS=$(usex utils)
	)

	cmake-utils_src_configure
}

src_install() {
	pushd "${BUILD_DIR}/qt5"
	emake DESTDIR="${ED}" install
	popd

	# install pkg-config data
	insinto /usr/$(get_libdir)/pkgconfig
	doins "${BUILD_DIR}"/poppler-qt5.pc
}
