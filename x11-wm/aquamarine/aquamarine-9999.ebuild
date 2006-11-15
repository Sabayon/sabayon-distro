# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit kde subversion autotools

ESVN_REPO_URI="svn://svn.beryl-project.org/beryl/trunk/${PN}"

DESCRIPTION="Beryl KDE Window Decorator (svn)"
HOMEPAGE="http://beryl-project.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="=x11-wm/beryl-core-9999"

need-kde 3.5

pkg_postinst() {
	kde_pkg_postinst
	echo
	einfo "Please report all bugs to http://bugs.gentoo-xeffects.org"
	einfo "Thank you on behalf of the Gentoo XEffects team"
}
