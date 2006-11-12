# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-im/wengophone/wengophone-2.0_rc2.ebuild,v 1.4 2006/08/30 21:12:24 genstef Exp $

inherit eutils toolchain-funcs

MY_P="wengophone_2.0.0~rc5-svn8281-1"
DESCRIPTION="Wengophone NG is a VoIP client featuring the SIP protcol"
HOMEPAGE="http://dev.openwengo.com"
SRC_URI="http://www.prato.linux.it/~mnencia/debian/wengophone-ng/source/${MY_P/-1}.orig.tar.gz
	http://www.prato.linux.it/~mnencia/debian/wengophone-ng/source/${MY_P}.diff.gz"
#ESVN_REPO_URI="http://dev.openwengo.com/svn/openwengo/wengophone-ng/trunk"
#ESVN_OPTIONS="--username guest --password guest"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
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
S=${WORKDIR}

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
	epatch ${MY_P}.diff
	cd wengophone-*
	for dpatch in debian/patches/*/*.patch; do
		epatch ${dpatch}
	done
}

src_compile() {
	cmake \
		-D CMAKE_CXX_COMPILER:FILEPATH="$(tc-getCXX)" \
		-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
		-D CMAKE_C_COMPILER:FILEPATH="$(tc-getCC)" \
		-DCMAKE_C_FLAGS="${CFLAGS}" \
		-DCMAKE_INSTALL_PREFIX="/usr" \
		-DWITH_BUILDID=ON -DWITH_SHARED_PHAPI=OFF \
		-DWITH_SHARED_OWCURL=OFF -DWITH_SHARED_SFP-PLUGIN=OFF \
		wengophone-* || die "ecmake failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	cd wengophone-*
	domenu debian/wengophone.desktop
	doicon debian/wengophone.xpm
	doman debian/qtwengophone.1
}

pkg_postinst() {
	einfo 'execute "qtwengophone" to start wengophone'
}
