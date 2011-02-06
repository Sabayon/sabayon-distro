# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils eutils

DESCRIPTION="Python bindings for Network Security Services (NSS)"
HOMEPAGE="http://people.redhat.com/jdennis/python-nss/doc/api/html"
SRC_URI="mirror://sabayon/${CATEGORY}/${P}.tar.lzma"

LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

DEPEND="dev-libs/nss
	dev-libs/nspr
	doc? ( dev-python/docutils
		dev-python/epydoc )"

RDEPEND="${DEPEND}"

RESTRICT_PYTHON_ABIS="3.*"
DOCS="README doc/ChangeLog"

src_prepare() {
	epatch "${FILESDIR}"/python-nss-fix-path.patch
}

src_install() {
	distutils_src_install

	#TODO fix doc generations
	if use doc; then
		einfo "Generating API documentation..."

		PYTHONPATH="${ED}$(python_get_sitedir -f)" epydoc --html --docformat restructuredtext \
		-o "${S}"/build-2.6/doc/html  "${S}"/build-2.6/lib.linux-x86_64-2.6/nss

		dohtml  -r "${S}/build/doc/"html/*
		insinto /usr/share/doc/"${PF}"
		doins -r ./test
		insinto /usr/share/doc/"${PF}"/examples
		doins doc/examples/*.py
	fi
}
