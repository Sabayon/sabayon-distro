# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/alsa-lib/alsa-lib-1.0.10.ebuild,v 1.15 2006/06/26 22:27:47 flameeyes Exp $

inherit eutils autotools libtool

MY_P="${P/_rc/rc}"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="Advanced Linux Sound Architecture Library"
HOMEPAGE="http://www.alsa-project.org/"
SRC_URI="mirror://alsaproject/lib/${MY_P}.tar.bz2"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"

KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86"
IUSE="doc jack"

RDEPEND="virtual/alsa
	>=media-sound/alsa-headers-${PV}"
DEPEND="${RDEPEND}
	doc? ( >=app-doc/doxygen-1.2.6 )"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch "${FILESDIR}/${PN}-1.0.10_rc3-hardened.patch"
	epatch "${FILESDIR}/${PN}-1.0.10_rc3-test.patch"
	epatch "${FILESDIR}/${P}-test-ppc.patch"

	eautoreconf
	elibtoolize
	epunt_cxx
}

src_compile() {
	# needed to avoid gcc looping internaly
	use hppa && export CFLAGS="-O1 -pipe"

	econf \
		--enable-static \
		--enable-shared \
		|| die "configure failed"

	emake || die "make failed"

	if use doc; then
		emake doc || die "failed to generate docs"
	fi
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"

	dodoc ChangeLog TODO
	use doc && dohtml -r doc/doxygen/html/*
}

pkg_postinst() {
	ewarn "Please use media-sound/alsa-driver rather than in-kernel drivers as there"
	ewarn "have been some problems recently with the in-kernel drivers.	 See bug #87544."
}
