# Copyright 2004-2010 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $

EAPI="2"
inherit python base

DESCRIPTION="The system-config-date tool lets you set the date and time of your machine."
HOMEPAGE="http://fedoraproject.org/wiki/SystemConfig/date"
SRC_URI="https://fedorahosted.org/released/${PN}/${P}.tar.bz2"

LICENSE="GPL-1"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="gtk"

# FIXME: would also require a dependency against anaconda
DEPEND="app-text/docbook-xml-dtd
        app-text/docbook-sgml-dtd
        app-text/gnome-doc-utils
        app-text/rarian
        dev-libs/newt
        dev-util/desktop-file-utils
        dev-util/intltool
        sys-devel/gettext"

RDEPEND="net-misc/ntp
        dev-python/libgnomecanvas-python
        dev-libs/newt
	dev-python/python-slip
        dev-python/rhpl
	gtk? ( dev-python/pygtk )
        x11-themes/hicolor-icon-theme"

PATCHES=( "${FILESDIR}"/${P}-unicode-fix.patch )

pkg_postrm() {
        python_mod_cleanup /usr/share/${PN}
}
