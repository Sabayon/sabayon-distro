# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit mono autotools

DESCRIPTION="A reusable utility library written in C#"
HOMEPAGE="http://code.google.com/p/libanculus-sharp/"
SRC_URI="http://libanculus-sharp.googlecode.com/files/${P}.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=">=dev-lang/mono-1.2.3
	>=dev-dotnet/gtk-sharp-2.8.0"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	eautoreconf
}

src_install() {
	make DESTDIR="${D}" install || die "install failed"
}

