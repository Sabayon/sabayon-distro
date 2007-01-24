# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit eutils toolchain-funcs

MY_PV="2.0.0~rc5-svn8108"
MY_P="${PN}_${MY_PV}"
DESCRIPTION="Wengophone NG is a VoIP client featuring the SIP protcol"
HOMEPAGE="http://dev.openwengo.com"
SRC_URI="
	http://ftp.debian.org/debian/pool/main/w/wengophone/${MY_P}.orig.tar.gz
	http://ftp.debian.org/debian/pool/main/w/wengophone/${MY_P}-3.diff.gz
	"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

RDEPEND="dev-libs/boost
	dev-libs/glib
	dev-libs/openssl
	media-libs/alsa-lib
	net-libs/gnutls
	media-video/ffmpeg
	=media-libs/portaudio-19*
	|| ( x11-libs/libX11 virtual/x11 )
	>=x11-libs/qt-4.1"

DEPEND="${RDEPEND}
	media-libs/speex
	dev-util/scons
	>=dev-util/cmake-2.4.3"

S=${WORKDIR}/${MY_P/_/-}

pkg_setup() {
	if ! built_with_use dev-libs/boost threads; then
		eerror "This package requires dev-libs/boost compiled with threads support."
		eerror "Please reemerge dev-libs/boost with USE=\"threads\"."
		die "Please reemerge dev-libs/boost with USE=\"threads\"."
	fi

	if test $(gcc-major-version) -ge 4 \
		&& test $(gcc-minor-version) -ge 1 && ! grep visit_each.hpp /usr/include/boost/bind.hpp >/dev/null 2>&1; then
		eerror "You need to add #include <boost/visit_each.hpp> in"
		eerror "/usr/include/boost/bind.hpp to build with gcc-4.1"
		die "Please fix your includes"
	fi
}

src_unpack() {
	unpack ${A}
	epatch ${MY_P}-3.diff

        mv ${MY_P/_/-} ${P}/ -f

        cd ${P}

        for dpatch in debian/patches/debian/*.patch; do
                epatch ${dpatch}
        done

        epatch debian/patches/generic/cmake-fix-static-sfp-plugin.patch
        epatch debian/patches/generic/cmake-external-speex.patch
        epatch debian/patches/generic/cmake-fix-find-alsa-FTBFS.patch
        epatch debian/patches/generic/fix-varargs-alpha.patch

}

src_compile() {
	cd ${WORKDIR}
	cmake \
		-D CMAKE_CXX_COMPILER:FILEPATH="$(tc-getCXX)" \
		-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
		-D CMAKE_C_COMPILER:FILEPATH="$(tc-getCC)" \
		-DCMAKE_C_FLAGS="${CFLAGS}" \
		-DCMAKE_INSTALL_PREFIX="/usr" \
		-DWITH_BUILDID=ON -DWITH_SHARED_PHAPI=OFF \
		-DWITH_SHARED_OWCURL=OFF -DWITH_SHARED_SFP-PLUGIN=OFF \
		${P} || die "ecmake failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	cd ${P}
	domenu debian/wengophone.desktop
	doicon debian/wengophone.xpm
	doman debian/qtwengophone.1
}

pkg_postinst() {
	einfo 'execute "qtwengophone" to start wengophone'
}
