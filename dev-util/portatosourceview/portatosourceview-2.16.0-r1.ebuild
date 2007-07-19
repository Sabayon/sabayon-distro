# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

WANT_AUTOCONF=latest
WANT_AUTOMAKE=1.9
inherit distutils gnome2 python virtualx autotools

DESCRIPTION="A gtksourceview widget for portato (based on pygtk)."
HOMEPAGE="http://portato.sourceforge.net/"
SRC_URI="mirror://sourceforge/portato/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"

RDEPEND="virtual/python
	>=x11-libs/gtksourceview-1.1.90"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.7"

DOCS="AUTHORS ChangeLog NEWS README"

src_install() {
	gnome2_src_install

	# install plugins
	insinto "/usr/share/portato/plugins"
	doins *.xml

	# install language file
	insinto "/usr/share/gtksourceview-1.0/language-specs"
	doins gentoo.lang
}

pkg_postinst() {
	python_version
	python_mod_optimize ${ROOT}/usr/$(get_libdir)/python${PYVER}/site-packages/${PN}
}

pkg_postrm() {
	python_version
	python_mod_cleanup
}
