# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils rpm multilib

SDK_PV=1.18.6.1

DESCRIPTION="LightScribe System Software (binary only library)"
HOMEPAGE="http://www.lightscribe.com/downloadSection/linux/index.aspx"
SRC_URI="http://download.lightscribe.com/ls/lightscribe-${PV}-linux-2.6-intel.rpm
	http://download.lightscribe.com/ls/lightscribePublicSDK-${SDK_PV}-linux-2.6-intel.rpm"

LICENSE="lightscribe lightscribeSDK"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="multilib"

RDEPEND="x86? ( sys-libs/libstdc++-v3 )
	amd64? ( sys-libs/libstdc++-v3[multilib] )
	!app-cdr/lightscribe
	!app-cdr/liblightscribe"

RESTRICT="mirror fetch"

S="${WORKDIR}"

QA_PRESTRIPPED="
	opt/lightscribe/lib32/liblightscribe.so.0.0.1
	opt/lightscribe/lib32/libstdcv3.so.5.0.7
	opt/lightscribe/lib/liblightscribe.so.0.0.1
	opt/lightscribe/lib/libstdcv3.so.5.0.7"

pkg_setup() {
	# This is a binary x86 package => ABI=x86
	# Please keep this in future versions
	has_multilib_profile && ABI="x86"
}

src_prepare() {
	# hack in to use provided libstdc++ rename it to libstdcv3
	# can't add an rpath or a LD_PRELOAD to a already build lib to work around
	# the libstdc++ "no version information available" problem Bug 152031 comment 66
	sed -i "s/libstdc++.so.5/libstdcv3.so.5/g" usr/lib/liblightscribe.so.1 || die "sed failed"
	sed -i "s/libstdc++.so.5/libstdcv3.so.5/g" usr/lib/lightscribe/libstdc++.so.5.0.7 || die "sed failed"
}

src_install() {
	local LSDIR="opt/lightscribe/$(get_libdir)"

	exeinto /${LSDIR}/lightscribe/updates
	doexe usr/lib/lightscribe/updates/fallback.sh || die "fallback.sh install failed"
	exeinto /${LSDIR}/lightscribe
	doexe usr/lib/lightscribe/elcu.sh || die "elcu.sh install failed"
	into /opt/lightscribe
	# make revdep-rebuild happy Bug 152031 comment 74
	newlib.so usr/lib/liblightscribe.so.1 liblightscribe.so.0.0.1 || die "liblightscribe.so.* install failed"
	newlib.so usr/lib/lightscribe/libstdc++.so.5.0.7 libstdcv3.so.5.0.7 || die "libstdcv3.so.* install failed"
	dosym liblightscribe.so.0.0.1 /${LSDIR}/liblightscribe.so
	insinto /usr/include/lightscribe
	doins -r usr/include/* || die "includes install failed"
	insinto /etc
	doins -r etc/* || die "config install failed"
	sed -i "s%/usr/lib%${ROOT}${LSDIR}%" "${D}"/etc/lightscribe.rc || die "sed failed"
	dodoc usr/share/doc/*.* \
	      usr/share/doc/lightscribe-sdk/*.* \
	      usr/share/doc/lightscribe-sdk/docs/* || die "doc install failed"
	docinto sample/lsprint
	dodoc usr/share/doc/lightscribe-sdk/sample/lsprint/* || die "lsprint sample install failed"
	dodir /etc/env.d
	echo "LDPATH=${ROOT}${LSDIR}" > "${D}"/etc/env.d/80lightscribe
}

pkg_postinst() {
	elog "This version also support Enhanced Contrast"
	elog "You can activate it by running:"
	elog "${ROOT}opt/lightscribe/$(get_libdir)/lightscribe/elcu.sh"
}

pkg_nofetch() {
	einfo "Please download the appropriate Lightscribe System Software & Linux Public SDK archive's"
	einfo "( lightscribe-${PV}-linux-2.6-intel.rpm"
	einfo "  lightscribePublicSDK-${SDK_PV}-linux-2.6-intel.rpm )"
	einfo "from ${HOMEPAGE} (requires to accept license)"
	einfo
	einfo "Then put the files in ${DISTDIR}"
}
