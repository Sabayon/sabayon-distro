# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

EGIT_REPO_URI="git://ipscan.git.sourceforge.net/gitroot/ipscan/ipscan"
# this is unable to build
# EGIT_COMMIT="3.0-beta4"
EGIT_COMMIT="cff4d38ee5185355d30512aacdbdcbe3276c2842"
inherit versionator git-2 java-pkg-2 java-ant-2

DESCRIPTION="Angry IP - The fast and friendly network scanner"
HOMEPAGE="http://www.angryip.org"
S=${WORKDIR}

MY_PV=${PV/_/-}
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

COMMON_DEPEND="dev-java/swt:3.5"
DEPEND="${COMMON_DEPEND}
	>=virtual/jdk-1.6.0
	>=dev-java/ant-core-1.8"
RDEPEND="${COMMON_DEPEND}
	>=virtual/jre-1.6.0"

JAVA_PKG_BSFIX=no

src_prepare() {
	epatch "${FILESDIR}"/${P}-disable-deb-rpm-package.patch
	# this allows us to do rm -rf "${S}"/ext/launch4j
	epatch "${FILESDIR}"/${P}-remove-launch4j-taskdef.patch
	cd "${S}"/lib || die

	# (dev-java/picocontainer:1) compiles but doesn't work with
	# dev-java/picocontainer-1.1-r1 from Portage
	mv picocontainer-1.0.jar picocontainer-1.0.jar.tmp || die
	rm *.jar
	mv picocontainer-1.0.jar.tmp picocontainer-1.0.jar || die

	java-pkg_jar-from swt-3.5
	# todo swt-mac.jar swt-win32.jar swt-win64.jar?
	mv swt.jar swt-$(my_get_target).jar || die "error renaming swt.jar"

	# see comment above
	#java-pkg_jar-from \
	#	picocontainer-1 picocontainer.jar picocontainer-1.0.jar

	# remove some bundled jars, ELF files...
	rm -rf "${S}"/ext/launch4j

	# "${S}"/ext/proguard/proguard.jar (4.0.1)
	# doesn't compile with dev-java/proguard-4.5

	rm "${S}"/lib/testing/*.jar

	# note: uses binary .so file from ext/rocksaw
}

src_compile() {
	eant $(my_get_target) || die "ant failed"
}

src_install() {
	java-pkg_newjar \
		"${S}/dist/ipscan-$(my_get_target)-$(get_version_component_range 1-2)-git.jar" \
		ipscan-linux.jar
	java-pkg_dolauncher
	insinto /usr/share/pixmaps
	newins "${S}"/resources/images/icon32.png ipscan.png || \
		die "cannot copy icon file"
	# make_desktop_entry ipscan "Angry IP Scanner" ipscan 'Application;Network;'
	insinto /usr/share/applications
	doins "${S}"/ext/deb-bundle/usr/share/applications/ipscan.desktop || \
		die "cannot copy .desktop file"
}

my_get_target() {
	if use x86; then
		echo linux
	elif use amd64; then
		echo linux64
	else
		die "arch unsupported"
	fi
}
