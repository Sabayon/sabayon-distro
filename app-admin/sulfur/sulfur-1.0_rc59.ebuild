# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
PYTHON_DEPEND="2"
inherit eutils gnome2-utils fdo-mime python

DESCRIPTION="Sulfur, the Entropy Package Manager Store"
HOMEPAGE="http://www.sabayon.org"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

SRC_URI="mirror://sabayon/sys-apps/entropy-${PV}.tar.bz2"
S="${WORKDIR}/entropy-${PV}/sulfur"

RDEPEND="dev-python/pygtk:2
	~sys-apps/entropy-${PV}
	sys-apps/file[python]
	sys-devel/gettext
	x11-libs/vte:0[python]
	x11-misc/xdg-utils"
DEPEND="sys-devel/gettext"

src_compile() {
	emake || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" LIBDIR="usr/lib" install || die "make install failed"
	dodir /etc/gconf/schemas
	insinto /etc/gconf/schemas
	doins "${S}/misc/entropy-handler.schemas"
}

pkg_postinst() {
	fdo-mime_mime_database_update
	fdo-mime_desktop_database_update
	gnome2_gconf_savelist
	gnome2_gconf_install
	python_mod_optimize "/usr/lib/entropy/${PN}"
}

pkg_postrm() {
	python_mod_cleanup "/usr/lib/entropy/${PN}"
	gnome2_gconf_savelist
	gnome2_gconf_uninstall
}
