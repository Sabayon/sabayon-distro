# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

# ModemManager likes itself with capital letters
MY_P=${P/modemmanager/ModemManager}

DESCRIPTION="Modem and mobile broadband management for NetworkManager-0.7."
HOMEPAGE="http://mail.gnome.org/archives/networkmanager-list/2008-July/msg00274.html"
SRC_URI="http://people.freedesktop.org/~tambet/ModemManager-0.2.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

DEPEND="dev-util/pkgconfig
	dev-util/intltool
	net-dialup/ppp
	>=net-misc/networkmanager-0.7.0-r2"

RDEPEND=${DEPEND}

S=${WORKDIR}/${MY_P}

src_unpack () {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-close-serial-on-HUP.patch
}

src_compile() {
	econf || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README
}
