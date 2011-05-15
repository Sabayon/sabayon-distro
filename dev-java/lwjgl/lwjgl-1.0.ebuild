# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# uses the javah task
WANT_ANT_TASKS="ant-nodeps"
JAVA_PKG_IUSE="devil doc source"

inherit java-pkg-2 java-ant-2 eutils

# See for dev info
# http://overlays.gentoo.org/proj/java/wiki/
#	Java_Games_ProjectLightWeightJavaGameLibraryLWJGL
MY_PV="$(delete_version_separator 2)"
DESCRIPTION="The Lightweigth Java Game Library (LWJGL)"
HOMEPAGE="http://www.lwjgl.org"
SRC_URI="mirror://sourceforge/java-game-lib/${PN}-source-${PV}.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS=""
IUSE=""

CDEPEND="virtual/opengl
		media-libs/openal
		dev-java/jinput
		dev-java/jutils"

DEPEND=">=virtual/jdk-1.5
		x11-libs/libX11
		x11-libs/libXcursor
		x11-libs/libXrandr
		x11-proto/xf86vidmodeproto
		x11-proto/xproto
		${CDEPEND}"

#TODO: the library for devil seems to be only needed at runtime
# check how it behaves with code that is using it when the library is not there
RDEPEND=">=virtual/jre-1.5
		devil? ( media-libs/devil )
		x11-libs/libX11
		x11-libs/libXext
		${CDEPEND}"

S="${WORKDIR}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	#eant clean clean-generated
	mkdir bin
	java-ant_rewrite-classpath build.xml
}

#EANT_BUILD_TARGET="generate-all all"
EANT_BUILD_TARGET="all"
EANT_GENTOO_CLASSPATH="jinput,jutils"
# needs com.sun.* from tools.jar for code generation
# EANT_EXTRA_ARGS="-Dbuild.sysclasspath=first"

src_install() {
	java-pkg_dojar libs/lwjgl*jar
	java-pkg_doso libs/linux/*.so
	use doc && java-pkg_dojavadoc doc/javadoc
	use source && java-pkg_dosrc src/java/org
}
