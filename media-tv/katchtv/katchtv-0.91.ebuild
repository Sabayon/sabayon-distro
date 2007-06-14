# Copyright 2004-2007 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils 

DESCRIPTION="KatchTV is an 'Internet TV' application for KDE, otherwise known as a broadcatcher. "
HOMEPAGE="http://www.digitalunleashed.com/giving.php"
SRC_URI="http://www.digitalunleashed.com/downloads/${PN}/${P}.tar.bz2"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
RDEPEND="	|| ( dev-python/pykde kde-base/pykde  )
		>=virtual/python-2.4
		>=media-video/kaffeine-0.8
		dev-python/PyQt
	"

S="${WORKDIR}/KatchTV"

src_compile() {
	einfo "Nothing to compile"
}

src_install() {
	dodir /usr/share/KatchTV
	cd ${S}
	insinto /usr/share/KatchTV
	doins -r ./*

	dodir /usr/share/applnk/Multimedia
	dodir /usr/bin

	echo "
		#!/bin/sh
		cd /usr/share/KatchTV
		python KatchTV
	" > ${D}/usr/bin/KatchTV
	chmod +x ${D}/usr/bin/KatchTV

	echo "[Desktop Entry]
Encoding=UTF-8
Type=Application
Exec=KatchTV
Icon=/usr/share/KatchTV/images/icon.png
Comment=Watch TV via Internet
Name=KatchTV
Terminal=false
GenericName=KatchTV Internet TV" > ${D}/usr/share/applnk/Multimedia/katchtv.desktop


}
