# Copyright 2006-2007 BreakMyGentoo.org
# Distributed under the terms of the GNU General Public License v2

inherit gnome2 multilib

DESCRIPTION="Rendering, animation and widget framework for Elisa media center."
HOMEPAGE="http://elisa.fluendo.com/"
SRC_URI="http://elisa.fluendo.com/static/download/${PN}/${P}.tar.gz"

RESTRICT="nomirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* ~amd64 ~ppc ~x86"
IUSE="doc"

RDEPEND=">=dev-libs/glib-2.8
	>=media-libs/gstreamer-0.10.13
	>=media-libs/gst-plugins-base-0.10.13
	>=x11-libs/pango-1.16
	>=x11-libs/cairo-1.4
	dev-libs/check
	>=dev-python/gst-python-0.10
	doc? ( dev-util/gtk-doc )"

DEPEND="${DEPEND}"

DOCS="AUTHORS ChangeLog COPYING INSTALL NEWS README TODO"

G2CONF="${G2CONF} $(use_enable doc gtk-doc)"

MAKEOPTS="-j1"

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
}
