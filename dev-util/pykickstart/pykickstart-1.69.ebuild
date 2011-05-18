# Copyright 2004-2010 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $

EAPI="3"
EGIT_COMMIT="r${PV}-1"
EGIT_REPO_URI="git://git.fedorahosted.org/git/pykickstart.git"
inherit base distutils git

DESCRIPTION="pykickstart is a python library that is used for reading and writing kickstart files."
HOMEPAGE="http://fedoraproject.org/wiki/Pykickstart"
SRC_URI=""

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0"

RDEPEND="${RDEPEND} sys-devel/gettext"
