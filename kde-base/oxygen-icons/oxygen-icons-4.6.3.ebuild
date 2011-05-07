# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-base/oxygen-icons/oxygen-icons-4.6.0.ebuild,v 1.1 2011/01/26 20:29:04 alexxy Exp $

EAPI="3"

if [[ ${PV} = *9999* ]]; then
	KMNAME="kdesupport"
else
	KMNAME="oxygen-icons"
fi
KDE_REQUIRED="never"
inherit kde4-base

DESCRIPTION="Oxygen SVG icon theme."
HOMEPAGE="http://www.oxygen-icons.org/"
SLREV=4
SRC_URI="http://dev.gentoo.org/~scarabeus/${P}.tar.xz
	mirror://sabayon/x11-themes/fdo-icons-sabayon${SLREV}.tar.gz"

#SRC_URI="http://dev.gentooexperimental.org/~scarabeus/${P}.tar.xz
#	mirror://sabayon/x11-themes/fdo-icons-sabayon${SLREV}.tar.gz"

LICENSE="LGPL-3"
KEYWORDS="~amd64 ~arm ~ppc ~ppc64 ~x86 ~x86-fbsd ~amd64-linux ~x86-linux"
IUSE="aqua"

# Block conflicting packages
add_blocker kdebase-data '<4.2.67'
add_blocker kdepim-icons 4.2.89
add_blocker step 4.2.98
add_blocker kmail '<4.3.2'

src_prepare() {
	kde4-base_src_prepare
	cp -r ../fdo-icons-sabayon/* ../${P} || die
}
