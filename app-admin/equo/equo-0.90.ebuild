# Copyright 2004-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit eutils multilib
EGIT_TREE="${PV}"
EGIT_REPO_URI="git://sabayon.org/projects/entropy.git"
inherit git

DESCRIPTION="Official Sabayon Linux Package Manager Client"
HOMEPAGE="http://www.sabayonlinux.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="~sys-apps/entropy-${PV}"
RDEPEND="${DEPEND}"

src_install() {
	emake DESTDIR="${D}" LIBDIR=usr/$(get_libdir) equo-install || die "make install failed"
}
