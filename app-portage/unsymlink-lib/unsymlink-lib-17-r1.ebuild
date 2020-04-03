# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

#PYTHON_COMPAT=( python2_7 )
#inherit python-single-r1

DESCRIPTION="Convert your system to SYMLINK_LIB=no"
HOMEPAGE="https://github.com/mgorny/unsymlink-lib"
SRC_URI="https://github.com/mgorny/unsymlink-lib/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="amd64"
IUSE=""
#REQUIRED_USE="${PYTHON_REQUIRED_USE}"

PATCHES=(
	"${FILESDIR}/shebang.patch"
)

# Note: for Sabayon's needs, dependency on Python is removed deliberately to help equo
# not upgrade Python or anything related before this script is installed (approach not
# assessed).

# The reason is, if Python or anything is installed first, if migration is
# necessary, the system can be broken. There are some checks being done but for
# that, order of installation should be sane.

# And yes, Python 2 is present on the system anyway.

# Same for Portage.

#RDEPEND="${PYTHON_DEPS}
#	$(python_gen_cond_dep '
#		sys-apps/portage[${PYTHON_MULTI_USEDEP}]
#	')"
RDEPEND=""

src_test() {
	# tests are docker-based
	:
}

src_install() {
	#python_doscript unsymlink-lib
	dobin unsymlink-lib
	dodoc README
}
