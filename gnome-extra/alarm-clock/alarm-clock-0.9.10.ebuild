# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit distutils python

DESCRIPTION="Alarm Clock is a personal alarm clock applet for the Gnome panel."
HOMEPAGE="http://alarm-clock.54.pl/"
SRC_URI="http://dp0154.debowypark.waw.pl/ac/downloads/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"

DEPEND=""
RDEPEND=">=dev-python/pygtk-2
	dev-python/notify-python
	dev-python/gst-python"

src_unpack() {
	distutils_src_unpack

	# Make sure setup.py is executable.
	/bin/chmod a+x setup.py
}

src_compile() {
	./setup.py build
}

src_install() {
	./setup.py install --root=${D}
}
