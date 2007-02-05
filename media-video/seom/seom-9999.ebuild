# Copyright 2004-2007 SabayonLinux
# Distributed under the terms of the GNU General Public License v2

inherit eutils subversion autotools

DESCRIPTION="Seom media package"
HOMEPAGE=""
ESVN_REPO_URI="svn://dbservice.com/big/svn/${PN}/trunk"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="-* "
IUSE=""

DEPEND=""

src_unpack() {
        subversion_src_unpack
}
