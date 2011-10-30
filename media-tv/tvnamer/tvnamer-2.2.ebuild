# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI=4

inherit distutils

SRC_URI="https://github.com/dbr/${PN}/tarball/${PV}"
DESCRIPTION="Automatic TV episode file renamer, uses data from thetvdb.com"
HOMEPAGE="http://github.com/dbr/tvnamer"
SLOT="0"
KEYWORDS="~amd64 ~x86"
LICENSE="GPL-2"
IUSE=""
DEPEND=">=dev-python/tvdb_api-1.5"
