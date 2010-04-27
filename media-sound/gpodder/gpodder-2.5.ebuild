# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
inherit distutils

DESCRIPTION="gPodder is a Podcast receiver/catcher written in Python, using GTK."
HOMEPAGE="http://gpodder.berlios.de/"
SRC_URI="mirror://berlios/${PN}/${P}.tar.gz"
LICENSE="GPL-3"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="bluetooth +dbus +examples gtkhtml +ipod +libnotify +mad mtp nls +ogg"

RDEPEND="dev-python/feedparser
	dev-python/pygtk
	dev-python/mygpoclient
	|| ( dev-lang/python[sqlite] dev-python/pysqlite )
	bluetooth? ( net-wireless/gnome-bluetooth )
	dbus? ( dev-python/dbus-python )
	ipod? ( media-libs/libgpod[python]
	|| ( mad? ( dev-python/pymad ) dev-python/eyeD3 ) )
	mtp? ( dev-python/pymtp )
	ogg? ( media-sound/vorbis-tools )
	libnotify? ( dev-python/notify-python )
	rockbox? ( dev-python/imaging )
	gtkhtml? ( dev-python/gtkhtml-python )"

DEPEND="${RDEPEND}
	dev-util/intltool
	sys-apps/help2man
	dev-python/setuptools"

RESTRICT="test mirror"

src_prepare() {
	if use nls ; then
		if [ -z "${LINGUAS}" ]; then
			ewarn "you must set LINGUAS in /etc/make.conf"
			ewarn "if you want to USE=nls"
			die "please either set LINGUAS or do not use nls"
		fi
		for l in $(find data/po -name '*.po' -exec basename {} .po ';'); do
			if [[ ! "${LINGUAS}" =~ $l ]] ; then
				rm -f data/po/$l.po ; fi
		done
		emake -C data/po
	fi
	emake data/org.gpodder.service
}

src_install() {
	distutils_src_install

	if use examples ; then
		insinto /usr/share/doc/${PF}/scripts
		doins doc/dev/convert/*
		doins doc/dev/examples/*
		elog "Example scripts to use with gPodder can be found in:"
		elog "  /usr/share/doc/${PF}/scripts"
	fi
}