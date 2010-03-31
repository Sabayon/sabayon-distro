# Copyright 2004-2010 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $

EAPI="2"
EGIT_COMMIT="${PN}-${PV}-1"
EGIT_REPO_URI="git://git.fedorahosted.org/pyblock.git"
inherit base git

DESCRIPTION="Python interface for working with block devices"
HOMEPAGE="http://git.fedoraproject.org/git/pyblock.git?p=pyblock.git;a=summary"
SRC_URI=""

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="selinux"

DEPEND="${DEPEND}
	sys-devel/gettext"
DEPEND="${DEPEND}
	sys-fs/lvm2
	sys-fs/dmraid
	dev-python/pyparted"

src_compile() {
	local use_selinux=0
	use selinux && use_selinux=1
	base_src_compile USESELINUX="${use_selinux}"
}
