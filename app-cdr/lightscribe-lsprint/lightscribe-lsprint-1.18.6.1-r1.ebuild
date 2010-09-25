# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils rpm multilib flag-o-matic toolchain-funcs

DESCRIPTION="LightScribe System Software (binary only library)."
HOMEPAGE="http://www.lightscribe.com/downloadSection/linux/index.aspx"
SRC_URI="http://download.lightscribe.com/ls/lightscribePublicSDK-${PV}-linux-2.6-intel.rpm"

LICENSE="lightscribeSDK"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="multilib"

DEPEND=">=dev-libs/liblightscribe-${PV}"

RDEPEND="amd64? ( multilib? ( app-emulation/emul-linux-x86-compat ) )"

RESTRICT="fetch"

src_unpack() {
	rpm_src_unpack
	epatch "${FILESDIR}"/liblightscribe-gcc43-1.patch
}

src_compile() {
	has_multilib_profile && ABI="x86"

	$(tc-getCXX) ${CXXFLAGS} -lpthread ${LDFLAGS} -L/opt/lightscribe/$(get_libdir)/ -I/usr/include/lightscribe/ \
	    "${WORKDIR}"/usr/share/doc/lightscribe-sdk/sample/lsprint/bmlite.cpp \
	    "${WORKDIR}"/usr/share/doc/lightscribe-sdk/sample/lsprint/lsprint.cpp \
	    -pthread -llightscribe -lm -m32 -o lsprint || die "lsprint compile failed"
}

src_install() {

	into /opt
	dobin lsprint
}

pkg_nofetch() {
	einfo "Please download the appropriate Lightscribe Linux Public SDK archive"
	einfo "( lightscribePublicSDK-${PV}-linux-2.6-intel.rpm )"
	einfo "from ${HOMEPAGE} (requires to accept license)"
	einfo
	einfo "Then put the file in ${DISTDIR}"
}
