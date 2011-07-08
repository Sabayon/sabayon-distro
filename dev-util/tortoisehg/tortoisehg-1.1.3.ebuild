# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
PYTHON_DEPEND="2"

inherit distutils

DESCRIPTION="Mercurial GUI command line tool hgtk"
HOMEPAGE="http://bitbucket.org/${PN}/stable/wiki/Home"
SRC_URI="http://bitbucket.org/${PN}/targz/downloads/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="doc nautilus"

DEPEND=">=dev-lang/python-2.6"
RDEPEND="${DEPEND}
		>=dev-python/pygtk-2.10
		>=dev-vcs/mercurial-1.6.3
		>=dev-python/iniparse-0.4
		doc? ( >=dev-python/sphinx-1.0.3 )
		nautilus? ( >=dev-python/nautilus-python-0.6.1 )"

src_install() {
	distutils_src_install
	dodoc doc/ReadMe{-cs,-ja,}.txt doc/TODO || die

	if use doc ; then
		cd ${S}/doc
		emake html
		dohtml -r build/html || die
	fi

	if use !nautilus; then
		einfo "Excluding Nautilus extension."
		rm -fR ${D}/usr/lib/nautilus
	fi
}
