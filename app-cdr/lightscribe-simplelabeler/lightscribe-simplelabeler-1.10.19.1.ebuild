# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

inherit rpm multilib

MY_P="lightscribeApplications-${PV}"
DESCRIPTION="LightScribe Simple Labeler by HP"
HOMEPAGE="http://www.lightscribe.com/downloadSection/linux/"
LICENSE_URI="http://www.lightscribe.com/downloadSection/linux/lslLicense.html"
SRC_URI="http://download.lightscribe.com/ls/${MY_P}-linux-2.6-intel.rpm"
LICENSE="LightScribe-SimpleLabeler LightScribe"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror strip"
DEPEND=""
RDEPEND="virtual/libc
	=virtual/libstdc++-3*
	sys-devel/gcc
	dev-libs/libxml2
	media-libs/freetype
	media-libs/fontconfig
	media-libs/libpng
	media-libs/nas
	sys-libs/zlib
	x11-libs/libICE
	x11-libs/libSM
	|| ( x11-libs/libX11 virtual/x11 )
	x11-libs/libXau
	x11-libs/libXcursor
	x11-libs/libXdmcp
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXinerama
	x11-libs/libXrender
	x11-libs/libXrandr
	x11-libs/libXt
	app-cdr/lightscribe
	amd64? ( app-emulation/emul-linux-x86-baselibs )
	"

src_unpack() {
	rpm_src_unpack
}

src_compile() { 
	einfo "nothing to compile"
}

src_install() {
	cd ${WORKDIR}
	cp -rp "${WORKDIR}/"* "${D}/"
	dosym   /opt/lightscribeApplications/SimpleLabeler/SimpleLabeler /usr/bin/${PN}
	insinto /usr/share/applications/
	doins   ${FILESDIR}/${PN}.desktop
}

pkg_postinst() {
	einfo
	einfo "You might want to have a look at the LightScribe Free Label Gallery at"
	einfo "\thttp://www.lightscribe.com/ideas/labelgallery.aspx"
	einfo
}
