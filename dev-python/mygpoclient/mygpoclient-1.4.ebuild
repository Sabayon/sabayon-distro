# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
inherit distutils

KEYWORDS="~x86 ~amd64"
SRC_URI="http://thpinfo.com/2010/${PN}/${P}.tar.gz"
RESTRICT="mirror"

DESCRIPTION="Pythonic interface to the my.gpodder.org web services."
HOMEPAGE="http://thpinfo.com/2010/mygpoclient http://my.gpodder.org"

IUSE=""

LICENSE="GPL-3"
SLOT="0"

RDEPEND="|| ( >=dev-lang/python-2.6
	 dev-python/simplejson )"

DEPEND="${RDEPEND}
	dev-python/setuptools"
