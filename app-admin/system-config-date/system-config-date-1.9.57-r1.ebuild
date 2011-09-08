# Copyright 2004-2011 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
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

# also net-misc/ntp would be a soft-dependency
# but code is redhat-centric, so we won't really
# let user use this crap
# net-misc/ntp
RDEPEND="dev-libs/newt
	dev-python/python-slip
	dev-python/rhpl
	gtk? (  dev-python/pygtk:2
		dev-python/libgnomecanvas-python
		x11-themes/hicolor-icon-theme )"

src_install() {
	base_src_install

	# removing .desktop file, not advertising this, it is
	# only needed by app-admin/anaconda
	rm -rf "${ED}/usr/share/"{man,applications}
	rm -rf "${ED}/etc/"{pam.d,security}
	rm -rf "${ED}/usr/bin"
}

pkg_postrm() {
	python_mod_cleanup /usr/share/${PN}
}
