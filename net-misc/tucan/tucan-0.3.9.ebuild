# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils

DESCRIPTION="Manages automatic downloads and uploads from one-click hosting sites like RapidShare"
HOMEPAGE="http://tucaneando.com/"
SRC_URI="http://forja.rediris.es/frs/download.php/1470/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gtk"

RDEPEND="dev-lang/python
	gtk? ( dev-python/pygtk
		gnome-base/librsvg )
	app-text/tesseract
	dev-python/imaging"

src_compile() { :; }

src_install() {
	emake DESTDIR="${D}"/usr install || die "emake install failed"
	dodoc CHANGELOG README || die "dodoc failed"
	if use gtk ; then
		doicon media/tucan.svg || die "doicon failed"
		make_desktop_entry tucan Tucan
	fi
}

pkg_postinst() {
	if ! use gtk ; then
		ewarn "Please be aware that Tucan curses interface is still under"
		ewarn "development."
		ewarn
		ewarn "You should use 'tucan --cli' for curses interface or"
		ewarn "simply use 'tucan --daemon' to use it daemonized."
	fi
}
