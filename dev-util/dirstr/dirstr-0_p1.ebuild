# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_5 python3_6 )

inherit python-r1

DESCRIPTION="Makes a directory structure according to a specifcation file"
HOMEPAGE="https://github.com/Enlik/dirstr"
SRC_URI="mirror://sabayon/${CATEGORY}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
	${PYTHON_DEPS}"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

src_install() {
	dobin dirstr.py
	python_replicate_script "${ED}/usr/bin/dirstr.py"
}
