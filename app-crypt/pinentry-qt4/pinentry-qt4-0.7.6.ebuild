# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit multilib eutils

DESCRIPTION="Collection of simple PIN or passphrase entry dialogs which utilize the Assuan protocol (Qt4 frontend)"
HOMEPAGE="http://www.gnupg.org/aegypten/"
SRC_URI="mirror://gnupg/${PN/-qt4}/${P/-qt4}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd ~x64-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="~app-crypt/pinentry-${PV} >=x11-libs/qt-gui-4.4.1"
RDEPEND="${DEPEND}"
S="${WORKDIR}/${P/-qt4}"

src_prepare() {
	local file
	for file in qt4/*.moc; do
		"${EPREFIX}"/usr/bin/moc ${file/.moc/.h} > ${file} || die "moc ${file} failed"
	done
}

src_configure() {

        # Issues finding qt on multilib systems
        export QTLIB="${QTDIR}/$(get_libdir)"

	econf \
		--disable-dependency-tracking \
		--enable-maintainer-mode \
		--disable-pinentry-gtk \
		--disable-pinentry-gtk2 \
		--disable-pinentry-curses \
		--disable-pinentry-qt \
		--enable-pinentry-qt4
}

src_install() {
	cd qt4 && emake DESTDIR="${D}" install || die "make install failed"
}
