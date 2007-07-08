# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="Hardware-accelerated desktop objects for Beryl/Compiz"
HOMEPAGE="http://www.screenlets.org"
SRC_URI="http://www.ryxperience.com/storage/screenlets-0.0.8pre.tar.bz2
		 http://distfiles.gentoo-xeffects.org/screenlets/screenlets-extra-0.0.8_pre-v2.tar.bz2
		 http://distfiles.gentoo-xeffects.org/screenlets/screenlets-themes-0.0.8_pre-v2.tar.bz2
		 http://distfiles.gentoo-xeffects.org/screenlets/screenlets-missing_icons-0.0.8_pre.tar.bz2"

RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-python/pyxdg
	dev-python/dbus-python
	x11-libs/libnotify
	>=dev-python/gnome-python-desktop-2.16.0"

RDEPEND="${DEPEND}"

BASE="/usr"

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

src_install() { 
	cd "${WORKDIR}/screenlets-0.0.8" 

	tar xjf ${DISTDIR}/${PN}-extra-${PV}-v2.tar.bz2 -C src || die "tar failed to extract extra package"
	tar xjf ${DISTDIR}/${PN}-themes-${PV}-v2.tar.bz2 -C src || die "tar failed to extract themes package"
	tar xjf ${DISTDIR}/${PN}-missing_icons-${PV}.tar.bz2 -C src || die "tar failed to extract icons package"

	epatch "${FILESDIR}/screenlets-0.0.8_pre-path.patch"
	epatch "${FILESDIR}/screenlets-0.0.8_pre-scandir_fix.patch"

	python setup.py install --root "${D}" || die "installation failed" 

	exeinto ${BASE}/bin
	newexe "${FILESDIR}/screenlets-tray" screenlets-tray
	newexe "${FILESDIR}/screenlets-control" screenlets-control

	insinto "${BASE}/share/screenlets"
	doins "${FILESDIR}/logo24.png"
	doins "${FILESDIR}/screenlets.svg"
	doins "${FILESDIR}/controlpanel.glade"

	insinto "${BASE}/share/applications"
	doins "${FILESDIR}/screenlets.desktop"
}
