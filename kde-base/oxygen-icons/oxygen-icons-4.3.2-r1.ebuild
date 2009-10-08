# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-base/oxygen-icons/oxygen-icons-4.3.1.ebuild,v 1.1 2009/09/01 16:23:27 tampakrap Exp $

EAPI="2"

KMNAME="oxygen-icons"
KDE_REQUIRED="never"
SLREV=1
inherit kde4-base

DESCRIPTION="Oxygen SVG icon theme."
HOMEPAGE="http://www.oxygen-icons.org/"
SRC_URI="mirror://kde/stable/${PV}/src/${P}.tar.bz2
	http://distfiles.sabayonlinux.org/${CATEGORY}/${PN}/${PN}-sabayon${SLREV}.tar.bz2"

LICENSE="LGPL-3"
KEYWORDS="~amd64 ~hppa ~x86"
IUSE=""

# Block conflicting packages
RDEPEND="
	!kdeprefix? (
		!<kde-base/kdebase-data-4.2.67:4.2[-kdeprefix]
		!<kde-base/kdebase-data-4.2.67:4.3[-kdeprefix]
		!<=kde-base/kdepim-icons-4.2.89[-kdeprefix]
		!<=kde-base/step-4.2.98[-kdeprefix]
	)
	kdeprefix? (
		!<kde-base/kdebase-data-4.2.67:${SLOT}[kdeprefix]
		!<=kde-base/kdepim-icons-4.2.89:${SLOT}[kdeprefix]
		!<=kde-base/step-4.2.98:${SLOT}[kdeprefix]
	)
"
src_prepare() {
	cp -r ../${PN}-sabayon/* ../${P}
}