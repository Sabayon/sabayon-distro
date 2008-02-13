# Copyright 2004-2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit eutils subversion multilib
ESVN_REPO_URI="http://svn.sabayonlinux.org/projects/entropy/trunk/spritz"
DESCRIPTION="Official Sabayon Linux Package Manager Graphical Client (SVN release)"
HOMEPAGE="http://www.sabayonlinux.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""
S="${WORKDIR}"/trunk

RDEPEND="|| ( >=sys-apps/entropy-0.10.2 >=app-admin/equo-0.10.2 )
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
