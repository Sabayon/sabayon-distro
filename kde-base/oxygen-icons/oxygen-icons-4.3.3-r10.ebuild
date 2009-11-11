# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-base/oxygen-icons/oxygen-icons-4.3.3.ebuild,v 1.1 2009/11/02 22:06:58 wired Exp $

EAPI="2"

if [[ ${PV} = *9999* ]]; then
	KMNAME="kdesupport"
else
	KMNAME="oxygen-icons"
fi
KDE_REQUIRED="never"
SLREV=1
inherit kde4-base

DESCRIPTION="Oxygen SVG icon theme."
HOMEPAGE="http://www.oxygen-icons.org/"
SRC_URI="mirror://kde/stable/${PV}/src/${P}.tar.bz2
	http://distfiles.sabayonlinux.org/${CATEGORY}/${PN}/${PN}-sabayon${SLREV}.tar.bz2"

LICENSE="LGPL-3"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~x86"
IUSE=""

# Block conflicting packages
add_blocker kdebase-data '<4.2.67'
add_blocker kdepim-icons 4.2.89
add_blocker kmail '<4.3.2'
add_blocker step 4.2.98

src_prepare() {
	cp -r ../${PN}-sabayon/* ../${P}
}