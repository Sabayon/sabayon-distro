# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-misc/kdnssd-avahi/kdnssd-avahi-0.1.2.ebuild,v 1.6 2006/11/25 16:47:04 kloeri Exp $

inherit kde

DESCRIPTION="DNS Service Discovery kioslave using Avahi (rather than mDNSResponder)"
HOMEPAGE="http://wiki.kde.org/tiki-index.php?page=Zeroconf+in+KDE"
SRC_URI="http://helios.et.put.poznan.pl/~jstachow/pub/${PN}_${PV}.orig.tar.gz
	mirror://gentoo/kde-admindir-3.5.5.tar.bz2"

LICENSE="GPL-2"
SLOT="0"

KEYWORDS="~alpha ~amd64 ~ia64 ~ppc ~ppc64 ~x86 ~x86-fbsd"

RDEPEND="net-dns/avahi"
DEPEND="${RDEPEND}"

need-kde 3.5

pkg_config() {
	if ! built_with_use net-dns/avahi qt3; then
		eerror "To compile kdnssd-avahi package you need Avahi with Qt 3.x support."
		eerror "but net-dns/avahi is not built with qt3 USE flag enabled."
		die "Please, rebuild net-dns/avahi with the \"qt3\" USE flag."
	fi
}

src_compile() {
	kde_src_compile myconf configure

	emake -C "${S}/${PN}" mocs || die "make mocs failed"

	kde_src_compile make
}
