## Ebuild and package snapshot by cvill64/rubengonc of Sabayon Linux ##

# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
inherit eutils kde

DESCRIPTION="A NetworkManager front-end for KDE"
SRC_URI="
	 http://sabayonlinuxdev.com/distfiles/net-misc/knetworkmanager/knetworkmanager-20060904.tar.bz2
	"

HOMEPAGE="http://en.opensuse.org/Projects/KNetworkManager"
SLOT="0"
LICENSE="GPL-2"
GENTOO_MIRRORS=""
KEYWORDS="~x86 ~amd64"
DEPEND=">=net-misc/networkmanager-0.6.2
        >=kde-base/kdelibs-3.2
       "
IUSE="arts"

src_unpack() {
    unpack ${A}
    S=${WORKDIR}/${P}
    cd ${S}
}

src_compile() {
    emake -f Makefile.cvs
    emake clean
    econf $(use_enable arts) || die "econf failed"
    emake || die "emake failed"  
}


src_install() {
    emake DESTDIR="${D}" install || die "install failed"
}

pkg_postinst() {
    einfo "For using KNetworkManager you have to start the NetworkManager"
    einfo "daemon. To have it running at every boot just do this:        "
    einfo "								 "
    einfo "# rc-update add NetworkManager default			 "
    einfo "								 "
    einfo "								 "
}