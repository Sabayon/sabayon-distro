# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils rpm

DESCRIPTION="NX Server Free is the first Enterprise level implementation of nxserver-freenx."
HOMEPAGE="http://www.nomachine.com"

IUSE=""
LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror strip"

URI_BASE="http://web04.nomachine.com/download/2.1.0/Linux/FE/"
SRC_NXSERVER="nxserver-${PV}-9.i386.rpm"
SRC_URI="${URI_BASE}/${SRC_NXSERVER}"

DEPEND="~net-misc/nxnode-2.1.0

	|| (  ( x11-libs/libICE
		x11-libs/libSM
		x11-libs/libXaw
		x11-libs/libXmu
		x11-libs/libXpm
		x11-libs/libXt
	      )
		virtual/x11
	   )"

RDEPEND="${DEPEND}"

S=${WORKDIR}

src_install() {
	cp -dPR usr ${D}
}
