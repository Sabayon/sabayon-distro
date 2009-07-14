# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: 

inherit eutils base gnome2

DESCRIPTION="Plugins for GEdit"
HOMEPAGE="http://live.gnome.org/GeditPlugins"
SRC_URI="ftp://ftp.gnome.org/pub/gnome/sources/${PN}/2.26/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
DEPENDS="app-editors/gedit-${PV}"
