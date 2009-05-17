# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

inherit rpm multilib

DESCRIPTION="LightScribe System Software by LaCie"
HOMEPAGE="http://www.lacie.com/products/product.htm?pid=10803"
SRC_URI="http://www.lacie.com/download/drivers/${P}-linux-2.6-intel.rpm"
LICENSE="LightScribe"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror strip"
DEPEND=""
RDEPEND="virtual/libc
	=virtual/libstdc++-3*
	sys-devel/gcc
	amd64? ( app-emulation/emul-linux-x86-baselibs app-emulation/emul-linux-x86-compat )"

src_unpack() {
	rpm_src_unpack
}

src_compile() { :; }

src_install() {

	has_multilib_profile && ABI=x86

	cd ${WORKDIR}

	dodir     /etc
	insinto   /etc
	doins    ./etc/lightscribe.rc
	dodir     /usr/$(get_libdir)/lightscribe
	insinto   /usr/$(get_libdir)/lightscribe
	doins     -r ./usr/lib/lightscribe/*
	exeinto   /usr/$(get_libdir)/lightscribe
	doexe     ./usr/lib/lightscribe/elcu.sh
	dodir     /usr/$(get_libdir)/lightscribe/updates
	exeinto   /usr/$(get_libdir)/lightscribe/updates
	doexe     ./usr/lib/lightscribe/updates/fallback.sh
	dolib.so ./usr/lib/liblightscribe.so.1
	dosym     liblightscribe.so.1 /usr/$(get_libdir)/liblightscribe.so
	dodir     /usr/$(get_libdir)/lightscribe/res
	insinto   /usr/$(get_libdir)/lightscribe/res
	doins    ./usr/lib/lightscribe/res/*
	dodir     /usr/$(get_libdir)/lightscribe/updates
	insinto   /usr/$(get_libdir)/lightscribe/updates
	doins    ./usr/lib/lightscribe/updates/*
	dodoc    ./usr/share/doc/lightscribeLicense.rtf

}
