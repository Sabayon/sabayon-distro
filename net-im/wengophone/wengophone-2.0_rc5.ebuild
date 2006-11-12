# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-im/wengophone/wengophone-2.0_rc2.ebuild,v 1.4 2006/08/30 21:12:24 genstef Exp $

inherit eutils toolchain-funcs

MY_P="wengophone_2.0.0~rc5-svn8281"
DESCRIPTION="Wengophone NG is a VoIP client featuring the SIP protcol"
HOMEPAGE="http://dev.openwengo.com"
SRC_URI="http://www.prato.linux.it/~mnencia/debian/wengophone-ng/source/${MY_P}.orig.tar.gz
	http://www.prato.linux.it/~mnencia/debian/wengophone-ng/source/${MY_P}-1.diff.gz"
#ESVN_REPO_URI="http://dev.openwengo.com/svn/openwengo/wengophone-ng/trunk"
#ESVN_OPTIONS="--username guest --password guest"

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
	|| ( x11-libs/libX11 virtual/x11 )
	>=x11-libs/qt-4.1"

DEPEND="${RDEPEND}
	media-libs/speex
	dev-util/scons"
S=${WORKDIR}/${MY_P/_/-}

SCONS_CALL="scons nobuildid=1 prefix=/usr mode=release-symbols destdir=${D} libdir=${D}/usr/lib/wengophone"
# does not stay exported from pkg_setup
export QTDIR=/usr QTLIBDIR=/usr/lib/qt4 QTINCLUDEDIR=/usr/include/qt4 QTPLUGINDIR=/usr/lib/qt4/plugins

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
	epatch ${MY_P}-1.diff
	cd ${S}
	for dpatch in debian/patches/*.patch; do
		epatch ${dpatch}
	done
}

src_compile() {
	${SCONS_CALL} qtwengophone qtwengophone-translations || die "scons failed"
}

src_install() {
	${SCONS_CALL} qtwengophone-install || die "scons install failed"
	domenu debian/wengophone.desktop
	doicon debian/wengophone.xpm
	doman debian/qtwengophone.1
}

pkg_postinst() {
	einfo 'execute "qtwengophone" to start wengophone'
}
