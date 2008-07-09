# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit mono

DESCRIPTION="WebKit bindings for Mono"
HOMEPAGE="http://www.mono-project.com/"
SRC_URI="http://mono.ximian.com/monobuild/preview/sources/webkit-sharp/${P}.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=">=dev-lang/mono-1.2.4
		net-libs/webkit-gtk
		dev-dotnet/gtk-sharp"
RDEPEND="${DEPEND}"

src_install() {
	    emake DESTDIR="${D}" install || die "Install failed"
	    dodoc README COPYING ChangeLog || die
}

