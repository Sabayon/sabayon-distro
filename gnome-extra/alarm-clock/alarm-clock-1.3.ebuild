# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils gnome2

DESCRIPTION="Alarm Clock is a personal alarm clock applet for the Gnome panel."
HOMEPAGE="http://alarm-clock.pl/"
SRC_URI="http://www.alarm-clock.pl/media/distfiles/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"

DEPEND=""
RDEPEND=">=dev-python/pygtk-2
	dev-python/notify-python
	dev-python/gst-python"

src_unpack() {
	gnome2_src_unpack
	cd ${S}

	gnome2_omf_fix
}
