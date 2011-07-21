# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
PYTHON_DEPEND="2"
inherit gnome2 distutils

DESCRIPTION="A screencasting program created with design in mind"
HOMEPAGE="https://launchpad.net/kazam"
SRC_URI="mirror://sabayon/${CATEGORY}/${P}.tar.gz"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-python/python-distutils-extra"
RDEPEND="dev-libs/keybinder
	dev-python/pycairo
	dev-python/pygobject
	dev-python/pyxdg
	dev-python/librsvg-python
	dev-python/python-xlib
	dev-python/gdata
	dev-python/pycurl
	virtual/ffmpeg"

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup
}

src_configure() {
	einfo "Nothing to configure."
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
	distutils_pkg_postinst
	echo
	elog "Attention: for optional audio recording,"
	elog "running Pulseaudio is currently required."
	echo
}

pkg_postrm() {
	gnome2_icon_cache_update
	distutils_pkg_postrm
}
