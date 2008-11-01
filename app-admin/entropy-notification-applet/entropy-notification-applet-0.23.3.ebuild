# Copyright 2004-2008 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit eutils subversion multilib fdo-mime
ESVN_REPO_URI="http://svn.sabayonlinux.org/projects/entropy/tags/${PV}/entropy-notification-applet"
DESCRIPTION="Entropy's Updates Notification Applet (GTK)"
HOMEPAGE="http://www.sabayonlinux.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
S="${WORKDIR}"/trunk

RDEPEND="~app-admin/spritz-${PV}
	dev-python/notify-python
	>=dev-python/gnome-python-extras-2.19
"

src_unpack() {
	# prepare spritz stuff
	subversion_src_unpack
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
}

pkg_postinst() {
	fdo-mime_mime_database_update
	fdo-mime_desktop_database_update
}
