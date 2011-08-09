# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

SCM=""
if [ "${PV#9999}" != "${PV}" ] ; then
	SCM="git-2"
fi
inherit autotools $SCM

DESCRIPTION="Blind-ID library for user identification using RSA blind signatures"
HOMEPAGE="http://git.xonotic.org/?p=xonotic/d0_blind_id.git;a=summary"
SCM=""
if [ "${PV#9999}" != "${PV}" ] ; then
	EGIT_REPO_URI="git://git.xonotic.org/xonotic/${PN}.git"
else
	SRC_URI="http://git.xonotic.org/?p=xonotic/${PN}.git;a=snapshot;h=xonotic-v${PV/_pre/preview};sf=zip -> ${P}.zip"
fi

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="crypt openssl static-libs"

RDEPEND="
	!openssl? ( dev-libs/gmp )
	openssl? ( dev-libs/openssl )
"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
"

pkg_setup() {
	use crypt || ewarn "You will have no encryption, only authentication."
	use openssl && ewarn "OpenSSL is for Mac OS X users only, GMP is faster."
}

src_prepare() {
	if [ "${PV#9999}" = "${PV}" ] ; then
		mv d0_blind_id-xonotic-v0.1.0preview-* ${P} || die
		cd "${S}"
	fi

	eautoreconf
}

src_configure() {
	econf \
		$(use_enable crypt rijndael) \
		$(use_with openssl) \
		$(use_enable static-libs static)
}

src_install() {
	default

	dodoc d0_blind_id.txt
}
