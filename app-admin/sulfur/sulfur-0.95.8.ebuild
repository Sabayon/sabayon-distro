# Copyright 2004-2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI=2
inherit eutils gnome2-utils multilib fdo-mime python
EGIT_TREE="${PV}"
EGIT_REPO_URI="git://sabayon.org/projects/entropy.git"
inherit git
DESCRIPTION="Official Sabayon Linux Package Manager Graphical Client (tagged release)"
HOMEPAGE="http://www.sabayonlinux.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="~sys-apps/entropy-${PV}
	>=dev-python/pygtk-2.12.1-r2
	>=x11-libs/vte-0.12.2[python]
	>=dev-util/glade-3.6.0[python]
	x11-misc/xdg-utils
	!<app-admin/spritz-0.95
	"
DEPEND="sys-devel/gettext"

src_compile() {
	emake -j1 || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" LIBDIR=usr/$(get_libdir) sulfur-install || die "make install failed"
	dodir /etc/gconf/schemas
	insinto /etc/gconf/schemas
	doins "${S}/sulfur/misc/entropy-handler.schemas"
}

pkg_postinst() {
	fdo-mime_mime_database_update
	fdo-mime_desktop_database_update
	gnome2_gconf_savelist
	gnome2_gconf_install
}

pkg_postrm() {
        python_mod_cleanup ${ROOT}/usr/$(get_libdir)/entropy/sulfur
	gnome2_gconf_savelist
	gnome2_gconf_uninstall
}

