# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils rpm

DESCRIPTION="NXNODE is a of NX components that are needed by the various NX servers."
HOMEPAGE="http://www.nomachine.com"

IUSE="rdesktop vnc"
LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror strip"

URI_BASE="http://web04.nomachine.com/download/2.1.0/Linux"
SRC_NXCLIENT="${P}-12.i386.rpm"
SRC_URI="${URI_BASE}/${SRC_NXCLIENT}"

DEPEND="~net-misc/nxclient-2.1.0

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

	# These will be provided by our dependencies
	rm -f ${D}/usr/NX/lib/libesd*

	if ! use rdesktop ; then
		rm -f ${D}/usr/NX/bin/nxdesktop
	fi

	if ! use vnc ; then
		rm -f ${D}/usr/NX/bin/nx{passwd,viewer}
	fi

	# If we did not remove the files from above, then we need
	# to make some wrappers to the /usr/NX/lib dir. Again
	# This is testing to see if this works better.
	mv ${D}/usr/NX/bin/nxagent ${D}/usr/NX/bin/nxagent.bin
	make_wrapper nxagent /usr/NX/bin/nxagent.bin /usr/NX/bin /usr/NX/lib /usr/NX/bin

	if use vnc ; then
		mv ${D}/usr/NX/bin/nxviewer ${D}/usr/NX/bin/nxviewer.bin
		make_wrapper nxviewer /usr/NX/bin/nxviewer.bin /usr/NX/bin /usr/NX/lib /usr/NX/bin
	fi

	if use rdesktop ; then
		mv ${D}/usr/NX/bin/nxdesktop ${D}/usr/NX/bin/nxdesktop.bin
		make_wrapper nxdesktop /usr/NX/bin/nxdesktop.bin /usr/NX/bin /usr/NX/lib /usr/NX/bin
	fi
}
