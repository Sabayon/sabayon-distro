# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/lzma/lzma-4.57.ebuild,v 1.3 2008/01/30 16:03:43 armin76 Exp $

inherit toolchain-funcs

DESCRIPTION="LZMA Stream Compressor from the SDK"
HOMEPAGE="http://www.7-zip.org/sdk.html"
SRC_URI="mirror://sourceforge/sevenzip/${PN}457.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~sparc ~x86"
IUSE="doc"

RDEPEND="!app-arch/lzma-utils"

S=${WORKDIR}

src_unpack() {
	unpack ${A} || die "unpack failed"
	cd "${S}"
	epatch "${FILESDIR}/sqlzma1-449.patch"
}

src_compile() {
	cd CPP/7zip/Compress/LZMA_Alone
	emake -f makefile.gcc \
		CXX="$(tc-getCXX) ${CXXFLAGS}" \
		CXX_C="$(tc-getCC) ${CFLAGS}" \
		|| die "Make failed"
}

src_install() {
	dobin CPP/7zip/Compress/LZMA_Alone/lzma || die
	dodoc history.txt
	use doc && dodoc 7zC.txt 7zFormat.txt lzma.txt Methods.txt
}
