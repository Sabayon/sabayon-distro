# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
MY_PN=PythonDaap

DESCRIPTION="DAAP client implemented in Python"
HOMEPAGE="http://foo.bar.com/"

SRC_URI="http://static.jerakeen.org/files/${MY_PN}-${PV}.tar.gz"
LICENSE="GPL"
SLOT="0"

KEYWORDS="~x86 ~amd64"

DEPEND="dev-lang/python"

RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_PN}-${PV}"

src_unpack() {
	unpack ${A}
	cd "${S}"
}

src_compile() {
	python setup.py build || die
}

src_install() {
	python setup.py install --root="${D}" || die
}
