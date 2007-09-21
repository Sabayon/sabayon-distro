# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils
MY_P="frostwire"

DESCRIPTION="FrostWire is a high quality, FREE peer-to-peer application."
HOMEPAGE="http://www.frostwire.com"
SRC_URI="http://www4.frostwire.com/frostwire/69421145/frostwire-${PV}.noarch.tar.gz"
LICENSE="GPL-2"
KEYWORDS="~x86"
DEPEND="app-arch/gzip"
RESTRICT="nomirror"

RDEPEND=">=virtual/jre-1.4.2
	>=virtual/jdk-1.4.2"

S="${WORKDIR}"

src_install() {

	dodir /usr/share/${MY_P}
	insinto /usr/share/${MY_P}
	doins -r ${S}/${MY_P}-${PV}.noarch/*

        dodir /usr/bin
        echo '#!/bin/sh' > ${MY_P}
        echo 'cd /usr/share/'${MY_P} >> ${MY_P}
        echo './runFrostwire.sh "$@"' >> ${MY_P}
        exeinto /usr/bin
        doexe ${MY_P}

	insinto /usr/share/applications
	dodir /usr/share/applications
	doins ${S}/${MY_P}-${PV}.noarch/frostwire.desktop

}
