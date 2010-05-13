# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libmimic/libmimic-1.0.4-r1.ebuild,v 1.6 2010/02/19 18:50:59 armin76 Exp $

EAPI="2"
inherit eutils autotools

DESCRIPTION="Video encoding/decoding library for the codec used by msn"
HOMEPAGE="http://farsight.sourceforge.net/"
SRC_URI="mirror://sourceforge/farsight/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ia64 ~ppc ~ppc64 sparc ~x86 ~x86-fbsd"
IUSE="doc +python"

RDEPEND="dev-libs/glib:2"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	doc? ( app-doc/doxygen )"

src_unpack() {
	unpack  ${A}
	if use python; then
		epatch "${FILESDIR}"/${P}-add-python-bindings.patch
		cd "${S}"
		eautoreconf
	fi
}

src_configure() {
	econf $(use_enable doc doxygen-docs python)
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc AUTHORS ChangeLog NEWS README || die "dodoc failed"

	if use doc; then
		dohtml doc/api/html/* || die "dohtml failed"
	fi
}
