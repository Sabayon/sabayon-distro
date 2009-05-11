# Copyright 2004-2008 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI=2
inherit eutils multilib fdo-mime
EGIT_TREE="${PV}"
EGIT_BRANCH="stable"
EGIT_REPO_URI="git://sabayon.org/projects/entropy.git"
inherit git
DESCRIPTION="Entropy's Updates Notification Applet (GTK)"
HOMEPAGE="http://www.sabayonlinux.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="~app-admin/spritz-${PV}
	dev-python/notify-python
	>=dev-python/gnome-python-extras-2.19
"

src_install() {
	cd "${S}/${PN}"	
	emake DESTDIR="${D}" install || die "make install failed"
}

pkg_postinst() {
	fdo-mime_mime_database_update
	fdo-mime_desktop_database_update
}
