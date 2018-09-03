# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python{2_7,3_4,3_5,3_6} )
inherit distutils-r1

DESCRIPTION="YAML for command line"
HOMEPAGE="https://github.com/0k/shyaml"
SRC_URI="https://github.com/0k/shyaml/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
RESTRICT="mirror"

RDEPEND="
	dev-python/pyyaml[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/d2to1[${PYTHON_USEDEP}]"
DEPEND="${DEPEND}"

src_prepare(){
	sed -i "s/version=.*/version=\"${PV}\"/g" "${S}"/autogen.sh || die
	sed -i "s/if.*describe.*/if false; then/g" "${S}"/autogen.sh || die
	sed -i "s/^depends .*//g" "${S}"/autogen.sh || die
	default
}
