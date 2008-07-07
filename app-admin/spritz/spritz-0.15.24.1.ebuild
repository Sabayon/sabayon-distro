# Copyright 2004-2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit eutils subversion multilib fdo-mime
ESVN_REPO_URI="http://svn.sabayonlinux.org/projects/entropy/tags/${PV}/spritz"
DESCRIPTION="Official Sabayon Linux Package Manager Graphical Client (tagged release)"
HOMEPAGE="http://www.sabayonlinux.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
S="${WORKDIR}"/trunk

RDEPEND="~sys-apps/entropy-${PV}
	>=dev-python/pygtk-2.10
	>=x11-libs/vte-0.12.2
	x11-misc/xdg-utils
	"
DEPEND="sys-devel/gettext"

pkg_setup ()
{
        if ! built_with_use x11-libs/vte python; then
                echo
                eerror "x11-libs/vte has not been built with python support."
                eerror "Please re-emerge vte with the python use-flag enabled."
                die "missing python flag for x11-libs/vte"
        fi
}

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
