# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils rpm multilib

DESCRIPTION="LightScribe Simple Labeler by HP (binary only GUI)"
HOMEPAGE="http://www.lightscribe.com/downloadSection/linux/index.aspx"
SRC_URI="http://download.lightscribe.com/ls/lightscribeApplications-${PV}-linux-2.6-intel.rpm"

LICENSE="lightscribe"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="multilib"

RDEPEND="dev-libs/liblightscribe
	x86? ( >=media-libs/fontconfig-2.3.2
		>=media-libs/freetype-2.1.10
		>=media-libs/libpng-1.2.8
		x11-libs/libICE
		x11-libs/libSM
		x11-libs/libX11
		x11-libs/libXcursor
		x11-libs/libXext
		x11-libs/libXi
		x11-libs/libXrandr
		x11-libs/libXrender
		x11-libs/qt-gui[qt3support]
		x11-libs/qt-sql[qt3support] )
	amd64? ( app-emulation/emul-linux-x86-xlibs
		 app-emulation/emul-linux-x86-baselibs )
	sys-devel/gcc
	sys-libs/zlib"

#RESTRICT="fetch"
RESTRICT="mirror"

S="${WORKDIR}"

QA_PRESTRIPPED="
	opt/lightscribe/SimpleLabeler/SimpleLabeler
	opt/lightscribe/SimpleLabeler/plugins/accessible/libqtaccessiblewidgets.so
	opt/lightscribe/SimpleLabeler/plugins/accessible/libqtaccessiblecompatwidgets.so
	opt/lightscribe/SimpleLabeler/lib32/libQt3Support.so.4
	opt/lightscribe/SimpleLabeler/lib32/libQtGui.so.4
	opt/lightscribe/SimpleLabeler/lib32/libQtNetwork.so.4
	opt/lightscribe/SimpleLabeler/lib32/libQtCore.so.4
	opt/lightscribe/SimpleLabeler/lib32/libQtXml.so.4
	opt/lightscribe/SimpleLabeler/lib32/libQtSql.so.4"

src_unpack() {
	rpm_src_unpack
}

src_install() {
	has_multilib_profile && ABI="x86"

	into /opt/lightscribe/SimpleLabeler
	exeinto /opt/lightscribe/SimpleLabeler
	doexe opt/lightscribeApplications/SimpleLabeler/SimpleLabeler || die "SimpleLabeler install failed"
	doexe opt/lightscribeApplications/SimpleLabeler/*.* || die "configfile install failed"
	exeinto /opt/lightscribe/SimpleLabeler/plugins/accessible
	doexe opt/lightscribeApplications/SimpleLabeler/plugins/accessible/*.so || die "accessible lib install failed"
	insinto /opt/lightscribe/SimpleLabeler/content
	doins -r opt/lightscribeApplications/SimpleLabeler/content/* || die "content install failed"
	use amd64 && dolib.so opt/lightscribeApplications/common/Qt/*
	dodoc opt/lightscribeApplications/*.* || die "doc install failed"
	into /opt
	#run it from the installdir otherwise it wont find the qt config and content files
	make_wrapper SimpleLabeler "./SimpleLabeler" /opt/lightscribe/SimpleLabeler /usr/$(get_libdir)/libstdc++-v3

	# cope with libraries being in /opt/lightscribe/SimpleLabeler/lib on amd64
	use amd64 && dodir /etc/env.d
	use amd64 && echo "LDPATH=${ROOT}opt/lightscribe/SimpleLabeler/$(get_libdir)" > "${D}"/etc/env.d/80lightscribe-simplelabeler
	# install revdep-rebuild file as this binary blob thingy is buggy
	use amd64 && dodir /etc/revdep-rebuild
	use amd64 && echo "SEARCH_DIRS_MASK=\"${ROOT}opt/lightscribe/SimpleLabeler/$(get_libdir)\"" > "${D}"/etc/revdep-rebuild/90lightscribe-simplelabeler

	newicon opt/lightscribeApplications/SimpleLabeler/content/images/LabelWizardIcon.png ${PN}.png || die "icon install failed"
	make_desktop_entry SimpleLabeler "LightScribe Simple Labeler" ${PN}.png "Application;AudioVideo;DiscBurning;Recorder;"
}

pkg_nofetch() {
	einfo "Please download the appropriate Lightscribe Simple Labeler archive"
	einfo "( lightscribeApplications-${PV}-linux-2.6-intel.rpm )"
	einfo "from ${HOMEPAGE} (requires to accept license)"
	einfo
	einfo "Then put the file in ${DISTDIR}"
}
