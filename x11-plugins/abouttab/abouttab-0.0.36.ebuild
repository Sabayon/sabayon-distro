# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit mozextension multilib

DESCRIPTION="Rough-cut prototype of the new about:tab page for development builds of firefox"
HOMEPAGE="http://labs.mozilla.com/2009/03/new-tab-page-proposed-design-principles-and-prototype/"
SRC_URI="http://people.mozilla.com/~dmills/abouttab/${P}.xpi"

LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2.1 )"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"

IUSE=""

RDEPEND="( >=www-client/mozilla-firefox-9999 )"
DEPEND="${RDEPEND}"

S=${WORKDIR}

src_unpack() {
	xpi_unpack "${P}".xpi
}

src_install() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/mozilla-firefox"
	xpi_install "${S}"/"${P}"
}

pkg_postinst() {
	echo
	ewarn "Note: This is a rough-cut prototype: The page loads too slowly, the"
	ewarn "visual design isn't right, and you can't even tell the browser that"
	ewarn "you don't want a particular site to show up on the new-tab screen."
	echo
	ewarn "See ${HOMEPAGE} for details."
	echo
}
