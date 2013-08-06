# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_COMPAT=( python{2_5,2_6,2_7} )

inherit distutils-r1

MY_P=Imaging-${PV}

DESCRIPTION="Python Imaging Library (PIL)"
HOMEPAGE="http://www.pythonware.com/products/pil/index.htm"
SRC_URI="http://www.effbot.org/downloads/${MY_P}.tar.gz"

LICENSE="HPND"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x86-solaris"
IUSE="doc examples jpeg lcms scanner test tiff tk truetype zlib"

RDEPEND="
	truetype? ( media-libs/freetype:2 )
	jpeg? ( virtual/jpeg )
	lcms? ( media-libs/lcms:0 )
	scanner? ( media-gfx/sane-backends )
	tiff? ( media-libs/tiff )
	zlib? ( sys-libs/zlib )
	tk? ( || ( dev-lang/python-tk:2.7 dev-lang/python-tk:2.6 dev-lang/python-tk:2.5 ) )
	!dev-python/pillow"
DEPEND="${RDEPEND}"
RDEPEND+=" !dev-python/pillow"

# Tests don't handle missing jpeg, tiff & zlib properly.
REQUIRED_USE="test? ( jpeg tiff zlib )"

S="${WORKDIR}/${MY_P}"

python_prepare_all() {
	local PATCHES=(
		"${FILESDIR}/${P}-no-xv.patch"
		"${FILESDIR}/${P}-sane.patch"
		"${FILESDIR}/${P}-giftrans.patch"
		"${FILESDIR}/${P}-missing-math.patch"
	)

	# Add shebangs.
	sed -e "1i#!/usr/bin/env python" -i Scripts/*.py || die

	# Disable all the stuff we don't want.
	local f
	for f in jpeg lcms tiff tk zlib; do
		if ! use ${f}; then
			sed -i -e "s:feature.${f} =:& None #:" setup.py || die
		fi
	done
	if ! use truetype; then
		sed -i -e 's:feature.freetype =:& None #:' setup.py || die
	fi

	distutils-r1_python_prepare_all
}

# XXX: split into two ebuilds?
wrap_phase() {
	"${@}"

	if use scanner; then
		cd Sane || die
		"${@}"
	fi
}

python_compile() {
	wrap_phase distutils-r1_python_compile
}

python_test() {
	"${PYTHON}" selftest.py || die "Tests fail with ${EPYTHON}"
}

python_install() {
	python_doheader libImaging/{Imaging.h,ImPlatform.h}

	wrap_phase distutils-r1_python_install
}

python_install_all() {
	use doc && local HTML_DOCS=( Docs/. )
	use examples && local EXAMPLES=( Scripts/. )

	distutils-r1_python_install_all

	if use scanner; then
		docinto sane
		dodoc Sane/{CHANGES,README,sanedoc.txt}
	fi

	if use examples && use scanner; then
		docinto examples/sane
		dodoc Sane/demo_*.py
		docompress -x /usr/share/${PF}/examples
	fi
}
