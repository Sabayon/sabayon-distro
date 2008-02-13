# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils distutils

DESCRIPTION="Hardware-accelerated desktop objects for Beryl/Compiz"
HOMEPAGE="http://www.screenlets.org"
SRC_URI="http://ryxperience.com/storage/screenlets-0.0.10.tar.bz2"
RESTRICT="nomirror"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-python/pyxdg
	dev-python/dbus-python
	x11-libs/libnotify
	>=dev-python/gnome-python-desktop-2.16.0
"

RDEPEND="${DEPEND}"

pkg_setup() {
	if built_with_use --missing false dev-python/gnome-python-desktop nognome;
	then
		if ! built_with_use --missing true dev-python/gnome-python-desktop rsvg || ! built_with_use --missing true dev-python/gnome-python-desktop wnck;
		then
			ewarn "You must build dev-python/gnome-python-desktop with"
			ewarn "USE=\"rsvg wnck\" to allow rsvg support for screenlets."
			ewarn "Otherwise, set USE="-nognome" and re-emerge"
			ewarn "dev-python/gnome-python-desktop to enable all"
			ewarn "plugins. Then re-emerge screenlets."
			die "requires dev-python/gnome-python-desktop with USE=\"rsvg wnck\""
		fi
	fi
}
