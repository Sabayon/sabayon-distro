# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils distutils

EAPI="2"

DESCRIPTION="Mercurial GUI command line tool hgtk"
HOMEPAGE="http://bitbucket.org/tortoisehg/stable/wiki/Home"
SRC_URI="http://bitbucket.org/${PN}/targz/downloads/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="doc"

DEPEND=">=dev-lang/python-2.6"
RDEPEND="${DEPEND}
		>=dev-python/pygtk-2.10
		>=dev-vcs/mercurial-1.4
		>=dev-python/iniparse-0.3.1
		doc? ( >=dev-python/sphinx-0.6 )"

src_install() {
	distutils_src_install
	dodoc ReleaseNotes.txt doc/ReadMe{-cs,-ja,}.txt doc/TODO || die

	if use doc ; then
		cd ${S}/doc
		emake html
		dohtml -r build/html || die
	fi
}

