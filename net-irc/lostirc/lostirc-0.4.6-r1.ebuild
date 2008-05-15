# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-irc/lostirc/lostirc-0.4.6-r1.ebuild,v 1.4 2008/02/08 16:03:27 coldwind Exp $

inherit autotools

IUSE="debug nls"
DESCRIPTION="A simple but functional graphical IRC client"
HOMEPAGE="http://lostirc.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
SLOT="0"
LICENSE="GPL-2"
KEYWORDS="amd64 ppc sparc x86"

RDEPEND=">=dev-cpp/gtkmm-2.4
	>=dev-cpp/glibmm-2.4.4
	dev-libs/libsigc++:2"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i -e 's:atkmm-1.6::' configure.ac || die "sed failed in configure.ac"
	sed -i -e 's:@MKINSTALLDIRS@:@MKDIR_P@:' \
		-e '/^mkinstalldirs =/s:$(SHELL)::' po/Makefile.in.in \
		|| die "sed failed in po.Makefile.in.in"
	eautoreconf
}

src_compile() {
	econf \
		--enable-desktopfile \
		$(use_enable debug logdebug) \
		$(use_enable nls)
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "install failed"
	dodoc AUTHORS ChangeLog README TODO NEWS || die "dodoc failed"
}
