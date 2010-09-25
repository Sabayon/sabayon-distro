# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

inherit rpm

MY_P="lightScribeSimpleLabeler-${PV}"
DESCRIPTION="LightScribe Simple Labeler by HP"
HOMEPAGE="http://www.lightscribe.com/downloadSection/linux/"
LICENSE_URI="http://www.lightscribe.com/downloadSection/linux/lslLicense.html"
SRC_URI="http://www.lightscribe.com/downloadSection/linux/downloads/lsl/${MY_P}-linux-2.6-intel.rpm"
LICENSE="LightScribe-LSL"
SLOT="0"
KEYWORDS="-amd64 ~x86"
IUSE=""
RESTRICT="fetch mirror strip"
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
	"

# SimpleLabeler is linked against bundled qt-4.1.2 libraries...
#RDEPEND="${RDEPEND} >=x11-libs/qt-4.2.2"
#pkg_setup() {
#	if has_version ">=x11-libs/qt-4.2.2" && ! built_with_use x11-libs/qt qt3support; then
#		eerror
#		eerror "You need to rebuild x11-libs/qt with USE=qt3support enabled"
#		eerror
#		die "please rebuild x11-libs/qt with USE=qt3support"
#	fi
#}

pkg_nofetch() {
	einfo
	einfo "The following steps are necessary to install ${PN}:"
	einfo "1. Please agree to the ${PN} license at"
	einfo "\t${LICENSE_URI}"
	einfo "2. Use the following URL to download the needed files into ${DISTDIR}"
	einfo "\t${SRC_URI}"
	einfo "3. Re-run the command that brought you here."
	einfo
}

src_unpack() {
	rpm_src_unpack
}

src_compile() { :; }

src_install() {
	cd ${WORKDIR}

	dodir   /opt/lightscribeApplications/SimpleLabeler
	insinto /opt/lightscribeApplications/SimpleLabeler
	doins  ./opt/lightscribeApplications/SimpleLabeler/qt.conf
	exeinto /opt/lightscribeApplications/SimpleLabeler
	doexe  ./opt/lightscribeApplications/SimpleLabeler/SimpleLabeler
	doexe  ./opt/lightscribeApplications/SimpleLabeler/launchBrowser.sh
	dodir   /opt/lightscribeApplications/SimpleLabeler/content
	dodir   /opt/lightscribeApplications/SimpleLabeler/content/html
	insinto /opt/lightscribeApplications/SimpleLabeler/content/html
	doins  ./opt/lightscribeApplications/SimpleLabeler/content/html/*.html
	dodir   /opt/lightscribeApplications/SimpleLabeler/content/html/help
	insinto /opt/lightscribeApplications/SimpleLabeler/content/html/help
	doins  ./opt/lightscribeApplications/SimpleLabeler/content/html/help/*.html
	dodir   /opt/lightscribeApplications/SimpleLabeler/content/html/help/images
	insinto /opt/lightscribeApplications/SimpleLabeler/content/html/help/images
	doins  ./opt/lightscribeApplications/SimpleLabeler/content/html/help/images/*
	dodir   /opt/lightscribeApplications/SimpleLabeler/content/html/userMessages
	insinto /opt/lightscribeApplications/SimpleLabeler/content/html/userMessages
	doins  ./opt/lightscribeApplications/SimpleLabeler/content/html/userMessages/*
	dodir   /opt/lightscribeApplications/SimpleLabeler/content/images
	insinto /opt/lightscribeApplications/SimpleLabeler/content/images
	doins  ./opt/lightscribeApplications/SimpleLabeler/content/images/*.png
	dodir   /opt/lightscribeApplications/SimpleLabeler/content/images/animations
	dodir   /opt/lightscribeApplications/SimpleLabeler/content/images/animations/swoosh
	insinto /opt/lightscribeApplications/SimpleLabeler/content/images/animations/swoosh
	doins  ./opt/lightscribeApplications/SimpleLabeler/content/images/animations/swoosh/*
	dodir   /opt/lightscribeApplications/SimpleLabeler/content/images/borders
	dodir   /opt/lightscribeApplications/SimpleLabeler/content/images/borders/fullsize
	insinto /opt/lightscribeApplications/SimpleLabeler/content/images/borders/fullsize
	doins  ./opt/lightscribeApplications/SimpleLabeler/content/images/borders/fullsize/*
	dodir   /opt/lightscribeApplications/SimpleLabeler/content/images/borders/metadata
	insinto /opt/lightscribeApplications/SimpleLabeler/content/images/borders/metadata
	doins  ./opt/lightscribeApplications/SimpleLabeler/content/images/borders/metadata/*
	dodir   /opt/lightscribeApplications/SimpleLabeler/content/images/borders/thumbnails
	insinto /opt/lightscribeApplications/SimpleLabeler/content/images/borders/thumbnails
	doins  ./opt/lightscribeApplications/SimpleLabeler/content/images/borders/thumbnails/*
	dodir   /opt/lightscribeApplications/SimpleLabeler/plugins
	dodir   /opt/lightscribeApplications/SimpleLabeler/plugins/accessible
	insinto /opt/lightscribeApplications/SimpleLabeler/plugins/accessible
	doins  ./opt/lightscribeApplications/SimpleLabeler/plugins/accessible/*
	dodir   /opt/lightscribeApplications/common/Qt
	insinto /opt/lightscribeApplications/common/Qt
	doins  ./opt/lightscribeApplications/common/Qt/*
	dodoc  ./opt/lightscribeApplications/lightscribeLicense.rtf
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
