# Copyright 2004-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
# $

EAPI="2"
inherit base cmake-utils

DESCRIPTION="QJson is a qt-based library that maps JSON data to QVariant objects."
HOMEPAGE="http://qjson.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE=""
DEPEND=">=dev-util/cmake-2.6"
RDEPEND="x11-libs/qt-core"

CMAKE_IN_SOURCE_BUILD="1"
