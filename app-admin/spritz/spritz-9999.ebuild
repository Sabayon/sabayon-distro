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
	"
DEPEND="sys-devel/gettext"

src_unpack() {
	# prepare spritz stuff
	subversion_src_unpack
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
}
