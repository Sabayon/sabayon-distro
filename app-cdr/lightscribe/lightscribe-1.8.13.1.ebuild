# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

inherit rpm

DESCRIPTION="LightScribe System Software by HP"
HOMEPAGE="http://www.lightscribe.com/downloadSection/linux/"
LICENSE_URI_LSS="http://www.lightscribe.com/downloadSection/linux/lssLicense.html"
LICENSE_URI_LPSDK="http://www.lightscribe.com/downloadSection/linux/lpsdkLicense.html"
SRC_URI_LSS="http://download.lightscribe.com/ls/${P}-linux-2.6-intel.rpm"
SRC_URI_LPSDK="http://download.lightscribe.com/ls/${PN}PublicSDK-${PV}-linux-2.6-intel.rpm"
SRC_URI="${SRC_URI_LSS} sdk? ( ${SRC_URI_LPSDK} )"
LICENSE="LightScribe-LSS LightScribe-LPSDK"
SLOT="0"
KEYWORDS="-amd64 ~x86"
IUSE="sdk"
RESTRICT="fetch mirror strip"
DEPEND=""
RDEPEND="virtual/libc
	=virtual/libstdc++-3*
	sys-devel/gcc"

pkg_nofetch() {
	einfo
	einfo "The following steps are necessary to install ${PN}:"
	einfo "1. Please agree to the ${PN} license at"
	einfo "\t${LICENSE_URI_LSS}"
	if useq sdk; then
		einfo "   ...and to the ${PN} SDK license at"
		einfo "\t${LICENSE_URI_LPSDK}"
	fi
	einfo "2. Use the following URL to download the needed files into ${DISTDIR}"
	einfo "\t${SRC_URI_LSS}"
	if useq sdk; then
		einfo "\t${SRC_URI_LPSDK}"
	fi
	einfo "3. Re-run the command that brought you here."
	einfo
}

src_unpack() {
	rpm_src_unpack
}

src_compile() { :; }

src_install() {
	cd ${WORKDIR}

	dodir     /etc
	insinto   /etc
	doins    ./etc/lightscribe.rc
	dodir     /usr/lib
	dolib.so ./usr/lib/liblightscribe.so.1
	dosym     liblightscribe.so.1 /usr/lib/liblightscribe.so
	dodir     /usr/lib/lightscribe/res
	insinto   /usr/lib/lightscribe/res
	doins    ./usr/lib/lightscribe/res/*
	dodir     /usr/lib/lightscribe/updates
	insinto   /usr/lib/lightscribe/updates
	doins    ./usr/lib/lightscribe/updates/*
	dodoc    ./usr/share/doc/lightscribeLicense.rtf

	if useq sdk; then
		dodir /usr/include
		insinto /usr/include
		doins ./usr/include/*
		DOCDESTTREE=sdk dodoc ./usr/share/doc/lightscribe-sdk/docs/*
		DOCDESTTREE=sdk dodoc ./usr/share/doc/lightscribe-sdk/linux_public_SDK_license.rtf
		DOCDESTTREE=sdk/sample/lsprint dodoc ./usr/share/doc/lightscribe-sdk/sample/lsprint/*
	fi
}
