# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI="3"
PYTHON_DEPEND="2"

inherit distutils

MY_PN=TinyUrl
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Super tiny library and command-line interface to tinyurl.com"
HOMEPAGE="http://meatballhat.com/projects/TinyUrl"
SRC_URI="http://pypi.python.org/packages/source/T/${MY_PN}/${MY_P}.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc examples"

DEPEND=""
RDEPEND=""

PYTHON_MODNAME="${MY_P}"
S="${WORKDIR}/${MY_P}"
