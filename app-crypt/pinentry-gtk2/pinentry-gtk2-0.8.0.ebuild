# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit multilib eutils

DESCRIPTION="Collection of simple PIN or passphrase entry dialogs which utilize the Assuan protocol (GTK 2 frontend)"
HOMEPAGE="http://www.gnupg.org/aegypten/"
SRC_URI="mirror://gnupg/${PN/-gtk2}/${P/-gtk2}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd ~x64-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="~app-crypt/pinentry-${PV} x11-libs/gtk+:2"
RDEPEND="${DEPEND}"
S="${WORKDIR}/${P/-gtk2}"

src_prepare() {
	epatch "${FILESDIR}/${PN/-gtk2}-0.7.5-grab.patch"
}

src_configure() {

	econf \
		--disable-dependency-tracking \
		--enable-maintainer-mode \
		--disable-pinentry-gtk \
		--enable-pinentry-gtk2 \
		--disable-pinentry-curses \
		--disable-pinentry-qt \
		--disable-pinentry-qt4
}

src_install() {
	cd gtk+-2 && emake DESTDIR="${D}" install || die "make install failed"
}
