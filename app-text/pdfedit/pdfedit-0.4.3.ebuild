# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit qt3

DESCRIPTION="Editor for manipulating PDF documents. GUI and commandline interface."
HOMEPAGE="http://pdfedit.petricek.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"

IUSE="doc"
RDEPEND="=x11-libs/qt-3*
	media-libs/t1lib"
DEPEND="${RDEPEND}
	dev-libs/boost
	doc? ( app-doc/doxygen )"

src_configure(){
	# for C{,XX}_EXTRA read README and bug #277723
	# Disable parallel make detection as we pass required -j with emake
	# ARCH is set to avoid pollution of CFLAGS with arch value...
	econf \
		--docdir=/usr/share/doc/${PF}/ \
		--with-parallel-make=off \
		$(use_enable doc doxygen-doc) \
		$(use_enable doc advanced-doc) \
		ARCH="" \
		C_EXTRA="-fmessage-length=0 -D_FORTIFY_SOURCE=2 -fno-strict-aliasing ${CFLAGS}" \
		CXX_EXTRA="-fmessage-length=0 -D_FORTIFY_SOURCE=2 -fno-strict-aliasing -fexceptions ${CXXFLAGS}"
}

src_install() {
	emake INSTALL_ROOT="${D}" install || die "emake install failed"
	rm "${D}"/usr/share/doc/${PF}/{LICENSE.GPL,README.cygwin}
}
