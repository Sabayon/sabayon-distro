# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit autotools eutils gnome2 subversion

RESTRICT="mirror"

DESCRIPTION="Official themes for Cairo-dock"
HOMEPAGE="http://www.cairo-dock.org"
SRC_URI=""

ESVN_REPO_URI="http://svn.berlios.de/svnroot/repos/${PN/-themes/}/trunk/themes"
ESVN_STORE_DIR="${PORTAGE_ACTUAL_DISTDIR-${DISTDIR}}/svn-src/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="~x11-misc/cairo-dock-${PV}"

src_unpack() {
	subversion_src_unpack

	eautoreconf || die "eautoreconf failed"
}

pkg_postinst() {
	gnome2_pkg_postinst

	ewarn "DO NOT report bugs to Gentoo's bugzilla"
	einfo "Please report all bugs to #gentoo-desktop-effects"
	einfo "Thank you on behalf of the Gentoo Desktop-Effects team"
}
