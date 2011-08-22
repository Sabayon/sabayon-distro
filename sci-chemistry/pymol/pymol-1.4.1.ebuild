# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: Exp $

EAPI="3"

PYTHON_DEPEND="2:2.6"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="2.4 2.5 3.*"
PYTHON_MODNAME="${PN} chempy pmg_tk pmg_wx"

inherit eutils distutils prefix versionator

DESCRIPTION="A Python-extensible molecular graphics system."
HOMEPAGE="http://pymol.sourceforge.net/"
SRC_URI="http://dev.gentoo.org/~jlec/distfiles/${P}.tar.xz"

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

src_prepare() {
	epatch \
		"${FILESDIR}"/${PV}-data-path.patch \
		"${FILESDIR}"/${PV}-shaders.patch

	use web || epatch "${FILESDIR}"/${PV}-web.patch

	epatch "${FILESDIR}"/1.2.2-prefix.patch && \
		eprefixify setup.py

	# Turn off splash screen.  Please do make a project contribution
	# if you are able though. #299020
	epatch "${FILESDIR}"/1.2.1/nosplash-gentoo.patch

	# Respect CFLAGS
	sed -i \
		-e "s:\(ext_comp_args=\).*:\1[]:g" \
		"${S}"/setup.py || die "Failed running sed on setup.py"

	use vmd && epatch "${FILESDIR}"/$(get_version_component_range 1-2)-vmd.patch

	use numpy && \
		sed \
			-e '/PYMOL_NUMPY/s:^#::g' \
			-i setup.py

	rm ./modules/pmg_tk/startup/apbs_tools.py || die

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

	doenvd "${T}"/20pymol || die "Failed to install env.d file."

	cat >> "${T}"/pymol <<- EOF
	#!/bin/sh
	$(PYTHON -f) -O \${PYMOL_PATH}/__init__.py \$*
	EOF

	dobin "${T}"/pymol || die "Failed to install wrapper."

	insinto /usr/share/pymol
	doins -r test data scripts || die "no shared data"

	insinto /usr/share/pymol/examples
	doins -r examples || die "Failed to install docs."

	dodoc DEVELOPERS README || die "Failed to install docs."
}

pkg_postinst() {
	elog "\t USE=shaders was removed,"
	elog "please use pymol config settings"
	elog "\t set use_shaders, 1"
	distutils_pkg_postinst
}
