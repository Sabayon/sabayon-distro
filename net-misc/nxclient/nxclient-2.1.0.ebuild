# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils rpm

DESCRIPTION="NXClient is a X11/VNC/NXServer client especially tuned for using remote desktops over low-bandwidth links such as the Internet"
HOMEPAGE="http://www.nomachine.com"

IUSE="cups esd"
LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror strip"

URI_BASE="http://web04.nomachine.com/download/2.1.0/Linux"
SRC_NXCLIENT="${P}-6.i386.rpm"
SRC_URI="${URI_BASE}/${SRC_NXCLIENT}"

DEPEND=">=dev-libs/expat-1.95.8
	>=media-libs/fontconfig-2.2.3
	>=media-libs/freetype-2.1.10
	>=media-libs/jpeg-6b-r7
	>=media-libs/libpng-1.2.8
	net-analyzer/gnu-netcat
	>=sys-libs/zlib-1.2.3
	=x11-libs/qt-3.3*

	cups? ( >=dev-libs/openssl-0.9.7j
		>=net-print/cups-1.1.23 )

	esd? ( >=media-libs/audiofile-0.2.6
	       >=media-sound/esound-0.2.36 )

	amd64? (
		app-emulation/emul-linux-x86-compat
		>=app-emulation/emul-linux-x86-baselibs-2.1.4
		>=app-emulation/emul-linux-x86-xlibs-2.2.1
		>=app-emulation/emul-linux-x86-qtlibs-2.1.1
	       )

	x86? ( >=sys-libs/lib-compat-1.4 )

	|| (  ( x11-libs/libX11
		x11-libs/libXau
		x11-libs/libXdmcp
		x11-libs/libXext
		x11-libs/libXft
		x11-libs/libXrender
		app-text/rman
	      )
		virtual/x11
	   )"

# As per !M instructions: Uninstall all the old stuff.
RDEPEND="${DEPEND}
	!net-misc/nx-x11
	!net-misc/nx-x11-bin
	!net-misc/nxcomp
	!net-misc/nxesd
	!net-misc/nxproxy
	!net-misc/nxserver-business
	!net-misc/nxserver-enterprise
	!net-misc/nxserver-personal
	!net-misc/nxssh"

S=${WORKDIR}

src_install() {
	cp -dPR usr ${D}

	# These will be provided by our dependencies
	rm -f ${D}/usr/NX/lib/lib{jpeg,png,z}*

	# We need to remove these items if the user wishes to compile
	# the OSS components. All these will be delivered by:
	# nxclient-base-2.0.0

	if ! use esd ; then
		rm -f ${D}/usr/NX/bin/nxesd
	fi

	# Make wrappers to /usr/NX/lib, so other programs are not affected.
	mv ${D}/usr/NX/bin/nxclient ${D}/usr/NX/bin/nxclient.bin
	make_wrapper nxclient /usr/NX/bin/nxclient.bin /usr/NX/bin /usr/NX/lib /usr/NX/bin

	mv ${D}/usr/NX/bin/nxservice ${D}/usr/NX/bin/nxservice.bin
	make_wrapper nxservice /usr/NX/bin/nxservice.bin /usr/NX/bin /usr/NX/lib /usr/NX/bin
	mv ${D}/usr/NX/bin/nxssh ${D}/usr/NX/bin/nxssh.bin
	make_wrapper nxssh /usr/NX/bin/nxssh.bin /usr/NX/bin /usr/NX/lib /usr/NX/bin

	# install environment variables
	cat <<EOF > ${T}/50nxpaths
NXDIR=/usr/NX
PATH=\${NXDIR}/bin
ROOTPATH=\${NXDIR}/bin
CONFIG_PROTECT="\${NXDIR}/etc \${NXDIR}/home"
PRELINK_PATH_MASK=\${NXDIR}
SEARCH_DIRS_MASK=\${NXDIR}
EOF
		doenvd ${T}/50nxpaths

	# Of the options in the applnk directory, the desktop files in the
	# "network" directory seem to make the most sense.
	declare applnk=/usr/NX/share/applnk apps=/usr/share/applications
	dodir ${apps}
	domenu ${D}${applnk}/network
	rm ${D}${apps}/nxclient-help.desktop
	rm -rf ${D}${applnk}
}
