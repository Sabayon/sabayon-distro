# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/python-poppler/python-poppler-0.12.1-r2.ebuild,v 1.1 2011/12/14 18:52:33 neurogeek Exp $

EAPI="3"
PYTHON_DEPEND="2:2.6"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="2.4 2.5 3.* *-jython"
PYTHON_EXPORT_PHASE_FUNCTIONS="1"

inherit eutils libtool python

DESCRIPTION="Python bindings to the Poppler PDF library"
HOMEPAGE="http://launchpad.net/poppler-python"
SRC_URI="http://launchpad.net/poppler-python/trunk/development/+download/pypoppler-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~x86-fbsd"
IUSE="examples"

S=${WORKDIR}/pypoppler-${PV}

RDEPEND=">=app-text/poppler-0.18.0[cairo]
	>=dev-python/pycairo-1.8.4
	dev-python/pygobject:2
	dev-python/pygtk:2"
DEPEND="${RDEPEND}"

src_prepare() {
	# http://pkgs.fedoraproject.org/gitweb/?p=pypoppler.git;a=tree
	epatch \
		"${FILESDIR}"/${P}-75_74.diff \
		"${FILESDIR}"/${P}-79_78.diff \
		"${FILESDIR}"/${P}-poppler0.15.0-changes.patch \
		"${FILESDIR}"/${P}-poppler-0.18.0-minimal-fix.patch

	elibtoolize
	python_copy_sources
}

src_install() {
	python_src_install
	python_clean_installation_image

	dodoc NEWS || die

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins demo/demo-poppler.py || die
	fi
}
