# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

EGIT_REPO_URI="git://git.xonotic.org/xonotic/${PN}.git"

[[ ${PV} == *9999 ]] && SCM="autotools git-2"
inherit base ${SCM}
unset SCM

DESCRIPTION="Blind-ID library for user identification using RSA blind signatures"
HOMEPAGE="http://git.xonotic.org/?p=xonotic/d0_blind_id.git;a=summary"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+crypt openssl  static-libs"

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
	base_src_prepare
	[[ ${PV} == *9999 ]] && eautoreconf
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
