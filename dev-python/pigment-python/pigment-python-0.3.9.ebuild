# Copyright 2006-2008 BreakMyGentoo.org
# Distributed under the terms of the GNU General Public License v2

inherit gnome2 python

DESCRIPTION="Python bindings for pigment"
HOMEPAGE="http://elisa.fluendo.com/"
SRC_URI="http://elisa.fluendo.com/static/download/pigment/${P}.tar.gz"

RESTRICT="nomirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* ~amd64 ~ppc ~x86"
IUSE=""

RDEPEND=">=media-libs/pigment-0.3.11
	>=dev-libs/glib-2.8
	>=dev-python/pygobject-2.8
	>=media-libs/gstreamer-0.10
	>=media-libs/gst-plugins-base-0.10
	>=x11-libs/gtk+-2
	>=dev-lang/python-2.4"

DEPEND="${RDEPEND}"

DOCS="AUTHORS ChangeLog COPYING INSTALL NEWS README TODO"

#MAKEOPTS="-j1"

src_install() {
	einstall || die
}

pkg_postinst() {
	python_version
	python_mod_optimize ${ROOT}/usr/$(get_libdir)/python${PYVER}/site-packages/gtk-2.0
}

pkg_postrm() {
	python_version
	python_mod_cleanup
}
