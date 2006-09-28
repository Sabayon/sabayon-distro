# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit flag-o-matic eutils kde

DESCRIPTION="KNetworkManager is the KDE front end for NetworkManager."
HOMEPAGE="http://en.opensuse.org/Projects/KNetworkManager"
LICENSE="GPL-2"

SRC_URI="http://nouse.net/projects/KNetworkManager/0.1/${PN}-${PV}.tar.bz2 "

SLOT="2"
KEYWORDS="~x86 ~amd64"

IUSE="arts"
DEPENT="
        >=net-misc/networkmanager-0.6.2
        "
DEPEND="${RDEPEND}"

src_compile() {

        myconf="${myconf}
                $(use_without arts)"

        kde_src_compile
}

src_install() {

        emake || die "Make failed"
        emake DESTDIR=${D} install || die "Make Install failed"
        dodoc README NEWS TODO AUTHORS

}
