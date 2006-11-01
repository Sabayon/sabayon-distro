# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit distutils subversion

DESCRIPTION="Python bindings for musicbrainz client library"
HOMEPAGE="http://musicbrainz.org/"
ESVN_REPO_URI="http://svn.musicbrainz.org/python-musicbrainz2/trunk/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86 ~amd64"

IUSE="doc"
DEPEND=">=media-libs/musicbrainz-2.1.1
	>=dev-python/ctypes-0.9.6
	>=dev-lang/python-2.3
	doc? ( dev-python/epydoc )"

DOCS="AUTHORS.txt CHANGES.txt COPYING.txt"

src_install() {
	distutils_src_install
	docinto examples
	dodoc examples/*
	if use doc; then
		python setup.py docs
		docinto html
		dohtml html/*
	fi
}
