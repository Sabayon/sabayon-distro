# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-chemistry/pymol/pymol-1.5.0.1.ebuild,v 1.2 2012/02/14 08:18:11 jlec Exp $

EAPI=4

PYTHON_DEPEND="2:2.7"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="2.4 2.5 2.6 3.*"
PYTHON_MODNAME="${PN} chempy pmg_tk pmg_wx"

inherit distutils eutils fdo-mime prefix versionator

DESCRIPTION="A Python-extensible molecular graphics system"
HOMEPAGE="http://pymol.sourceforge.net/"
SRC_URI="
	mirror://sourceforge/project/${PN}/${PN}/${PV}/${PN}-v${PV}.tar.bz2
	http://dev.gentoo.org/~jlec/distfiles/${PN}.xpm.tar"

LICENSE="PSF-2.2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86 ~amd64-linux ~x86-linux"
IUSE="apbs numpy vmd web"

DEPEND="
	dev-lang/python-tk
	dev-python/numpy
	dev-python/pmw
	media-libs/freetype:2
	media-libs/glew
	media-libs/libpng
	media-video/mpeg-tools
	sys-libs/zlib
	media-libs/freeglut
	apbs? (
		dev-libs/maloc
		sci-chemistry/apbs
		sci-chemistry/pdb2pqr
		sci-chemistry/pymol-apbs-plugin
	)
	web? ( !dev-python/webpy )"
RDEPEND="${DEPEND}"

S="${WORKDIR}"/${PN}

src_prepare() {
	epatch \
		"${FILESDIR}"/${P}-setup.py.patch \
		"${FILESDIR}"/${P}-data-path.patch \
		"${FILESDIR}"/${P}-flags.patch

	use web || epatch "${FILESDIR}"/${P}-web.patch

	epatch "${FILESDIR}"/${P}-prefix.patch && \
		eprefixify setup.py

	use vmd && epatch "${FILESDIR}"/${P}-vmd.patch

	if use numpy; then
		sed \
			-e '/PYMOL_NUMPY/s:^#::g' \
			-i setup.py || die
	fi

	rm ./modules/pmg_tk/startup/apbs_tools.py || die

	echo "site_packages = \'$(python_get_sitedir -f)\'" > setup3.py || die

	# python 3.* fix
	# sed '452,465d' -i setup.py
	distutils_src_prepare
}

src_configure() {
	:
}

src_install() {
	distutils_src_install

	# These environment variables should not go in the wrapper script, or else
	# it will be impossible to use the PyMOL libraries from Python.
	cat >> "${T}"/20pymol <<- EOF
		PYMOL_PATH="${EPREFIX}/$(python_get_sitedir -f)/${PN}"
		PYMOL_DATA="${EPREFIX}/usr/share/pymol/data"
		PYMOL_SCRIPTS="${EPREFIX}/usr/share/pymol/scripts"
	EOF

	doenvd "${T}"/20pymol

	cat >> "${T}"/pymol <<- EOF
	#!/bin/sh
	$(PYTHON -f) -O \${PYMOL_PATH}/__init__.py -q \$*
	EOF

	dobin "${T}"/pymol

	insinto /usr/share/pymol
	doins -r test data scripts

	insinto /usr/share/pymol/examples
	doins -r examples

	dodoc DEVELOPERS README

	doicon "${WORKDIR}"/${PN}.xpm
	make_desktop_entry pymol PyMol ${PN}.xpm "Graphics;Science;Chemistry"
}

pkg_postinst() {
	elog "\t USE=shaders was removed,"
	elog "please use pymol config settings"
	elog "\t set use_shaders, 1"
	distutils_pkg_postinst
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
}
