# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit flag-o-matic eutils kde

DESCRIPTION="KNetworkManager is the KDE front end for NetworkManager."
HOMEPAGE="http://en.opensuse.org/Projects/KNetworkManager"
LICENSE="GPL-2"

SRC_URI="http://nouse.net/projects/KNetworkManager/0.1/${P}.tar.bz2"

SLOT="2"
KEYWORDS="~x86 ~amd64"

IUSE="arts"
DEPENT="
	kde-base/unsermake
        >=net-misc/networkmanager-0.6.4
        "
DEPEND="${RDEPEND}"

src_unpack() {
	cd ${WORKDIR}
	unpack ${A}

	cd ${WORKDIR}/${P}/knetworkmanager
	epatch ${FILESDIR}/${PN}-${PV}-dbus.patch
	

}

src_compile() {
	
	#eautoreconf
	
        #myconf="${myconf}
        #        $(use_with arts)
	#	--prefix=`kde-config --prefix`
	#	"
        UNSERMAKE="yes" kde_src_compile

}

src_install() {
		
        emake DESTDIR=${D} install || die "Make Install failed"
        dodoc README NEWS TODO AUTHORS

}
