# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit distutils versionator

DESCRIPTION="Pyroom is a text editor that stays out of your way and keeps
other things out of your way, too."
HOMEPAGE="http://www.pyroom.org/"
SRC_URI="http://launchpad.net/${PN}/$(get_version_component_range 1-2)/${PV}/+download/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="dev-python/pyxdg
dev-python/pygtk"

S=${WORKDIR}/${P}
