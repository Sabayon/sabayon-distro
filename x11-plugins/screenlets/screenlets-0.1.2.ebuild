# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils distutils

DESCRIPTION="Hardware-accelerated desktop objects for Beryl/Compiz"
HOMEPAGE="http://www.screenlets.org"
SRC_URI="http://code.launchpad.net/${PN}/trunk/${PV}/+download/${P}.tar.bz2"
RESTRICT="nomirror"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	>=dev-lang/python-2.4
	dev-python/pygtk
	dev-python/pyxdg
	dev-python/pycairo
	gnome-base/librsvg
	x11-libs/libwnck
	>=dev-python/gnome-python-desktop-2.16.0
"

RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}"

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

src_install(){

	distutils_src_install

        insinto /usr/share/desktop-directories
        doins "${S}"/desktop-menu/desktop-directories/Screenlets.directory

        insinto /usr/share/icons
        doins "${S}"/desktop-menu/screenlets.svg

        # Insert .desktop files
        for x in $(find "${S}"/desktop-menu -name "*.desktop"); do
                domenu ${x}
        done
}