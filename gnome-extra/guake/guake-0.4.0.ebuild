# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
inherit gnome2

DESCRIPTION="Guake is a drop-down terminal for Gnome"
HOMEPAGE="http://guake-terminal.org/"
SRC_URI="http://guake.org/files/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=dev-lang/python-2.4
	dev-python/gnome-python
	dev-python/notify-python
	x11-libs/vte[python]
	dev-python/dbus-python"
RDEPEND=${DEPEND}

# Not on Gentoo Mirrors
RESTRICT="primaryuri"
