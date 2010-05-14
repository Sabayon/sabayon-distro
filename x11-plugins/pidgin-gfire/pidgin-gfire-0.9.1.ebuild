# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: j0inty edited by KardasA $

EAPI="2"

DESCRIPTION="Gfire is an open source plugin for the Pidgin IM client which allows you to connect the Xfire network."
HOMEPAGE="http://gfireproject.org/"
SRC_URI="mirror://sourceforge/gfire/${P}.tar.bz2"

LICENSE="GPLv3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug dbus gtk libnotify srvdetection"

RDEPEND=">=net-im/pidgin-2.5.0
		 dbus? ( dev-libs/dbus-glib )
		 gtk? ( >=x11-libs/gtk+-2.14.0 )
		 libnotify? ( >=x11-libs/libnotify-0.3.2 )
		 srvdetection? ( >=net-analyzer/tcpdump-4.1.0-r1[suid] )"

DEPEND="dev-util/pkgconfig
	${RDEPEND}"

src_configure() {
	econf $(use_enable debug) $(use_enable libnotify) $(use_enable dbus dbus-status) $(use_enable gtk)  || die "econf failed"
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog README
}

pkg_postinst() {
    if use srvdetection ; then
    	ewarn "You installed ${PN} with server detection support,"
    	ewarn "this requires tcpdump installation with suid support,"
    	ewarn "this is potential security risk."
    	ewarn "You have been warned"
    	elog "To let users use server detection add them to tcpdump group"  	
    fi
}
