# Copyright 2004-2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit eutils multilib fdo-mime python
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
	x11-misc/xdg-utils
	"
DEPEND="sys-devel/gettext"

src_install() {
	emake DESTDIR="${D}" LIBDIR=usr/$(get_libdir) spritz-install || die "make install failed"
}

pkg_postinst() {
	fdo-mime_mime_database_update
	fdo-mime_desktop_database_update
}

pkg_postrm() {
        python_mod_cleanup ${ROOT}/usr/$(get_libdir)/spritz
}

