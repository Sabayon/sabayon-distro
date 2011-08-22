# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

DESCRIPTION="Collection of simple PIN or passphrase entry dialogs which utilize the Assuan protocol"
HOMEPAGE="http://gnupg.org/aegypten2/index.html"
SRC_URI="mirror://gnupg/${PN}/${P/-base}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="caps static"

RDEPEND="app-admin/eselect-pinentry
	static? ( >=sys-libs/ncurses-5.7-r5[static-libs] )
	!static? ( sys-libs/ncurses )
	caps? ( sys-libs/libcap )"
DEPEND="${RDEPEND}"
S="${WORKDIR}/${P/-base}"

pkg_setup() {
	use static && append-ldflags -static
}

src_configure() {
		econf \
		--disable-dependency-tracking \
		--enable-maintainer-mode \
		--disable-pinentry-gtk \
		--disable-pinentry-gtk2 \
		--disable-pinentry-qt \
		--enable-pinentry-curses \
		--enable-fallback-curses \
		--disable-pinentry-qt4 \
		$(use_with caps libcap)
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO
	rm -f "${D}"/usr/bin/pinentry || die
}

pkg_postinst() {
	elog "We no longer install pinentry-curses and pinentry-qt SUID root by default."
	elog "Linux kernels >=2.6.9 support memory locking for unprivileged processes."
	elog "The soft resource limit for memory locking specifies the limit an"
	elog "unprivileged process may lock into memory. You can also use POSIX"
	elog "capabilities to allow pinentry to lock memory. To do so activate the caps"
	elog "USE flag and add the CAP_IPC_LOCK capability to the permitted set of"
	elog "your users."
	eselect pinentry update ifunset
	use gtk && elog "If you want pinentry for Gtk+, please install app-crypt/pinentry-gtk."
	use qt4 && elog "If you want pinentry for Qt4, please install app-crypt/pinentry-qt4."
}

pkg_postrm() {
	eselect pinentry update ifunset
}
