# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/alsa-lib/alsa-lib-1.0.12.ebuild,v 1.1 2006/08/31 09:15:34 flameeyes Exp $

inherit eutils autotools libtool

MY_P="${P/_rc/rc}"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="Advanced Linux Sound Architecture Library"
HOMEPAGE="http://www.alsa-project.org/"
SRC_URI="mirror://alsaproject/lib/${MY_P}.tar.bz2"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86"
IUSE="doc"

RDEPEND="virtual/alsa
	>=media-sound/alsa-headers-${PV}"
DEPEND="${RDEPEND}
	doc? ( >=app-doc/doxygen-1.2.6 )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${PN}-1.0.10_rc3-hardened.patch"
	epatch "${FILESDIR}/${PN}-1.0.10-no-wordexp-header.patch"

	eautomake
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
		fgrep -Zrl "${S}" "${S}/doc/doxygen/html" | \
			xargs -0 sed -i -e "s:${S}::"
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"

	dodoc ChangeLog TODO
	use doc && dohtml -r doc/doxygen/html/*
}

pkg_postinst() {
	ewarn "Starting from alsa 1.0.11_rc3 the configuration for dmix is changed."
	ewarn "Leaving around old asound.conf or ~/.asoundrc might make all apps"
	ewarn "using ALSA output crash."
	ewarn "Note that dmix output is enabled by default on the 'default' device"
	ewarn "since ALSA 1.0.9."
	einfo ""
	einfo "Please try media-sound/alsa-driver before filing bugs about unstable"
	einfo "or missing output with in-kernel drivers. Misaligned versions of"
	einfo "alsa-lib and drivers used can cause problems."
}
