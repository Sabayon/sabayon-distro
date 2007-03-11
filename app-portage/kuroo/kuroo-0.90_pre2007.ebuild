# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit kde subversion

ESVN_PROJECT="${PN/-svn}"
ESVN_REPO_URI="svn://kuroo.org/repos/kuroo/trunk"
ESVN_STORE_DIR="${DISTDIR}/svn-src"
ESVN_BOOTSTRAP="make -f Makefile.cvs"

DESCRIPTION="A KDE Portage frontend"
HOMEPAGE="http://kuroo.org"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~x86 ~amd64 ~ppc ~sparc"
IUSE="debug"

RDEPEND="kde-misc/kdiff3"

need-kde 3.5

