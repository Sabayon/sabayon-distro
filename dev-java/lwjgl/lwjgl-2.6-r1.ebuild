# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

# Uses the javah task.
WANT_ANT_TASKS="ant-nodeps"
JAVA_PKG_IUSE="doc source"

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="The Lightweight Java Game Library (LWJGL)"
HOMEPAGE="http://www.lwjgl.org"
SRC_URI="mirror://sourceforge/java-game-lib/${PN}-source-${PV}.zip"
LICENSE="BSD"
SLOT="2.6"
KEYWORDS="~amd64 ~x86"
IUSE=""

CDEPEND="dev-java/apple-java-extensions-bin
	dev-java/apt-mirror
	dev-java/jinput
	dev-java/jutils
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXrandr
	x11-libs/libXxf86vm"

DEPEND="${CDEPEND}
	>=virtual/jdk-1.5
	x11-proto/xproto"

RDEPEND="${CDEPEND}
	>=virtual/jre-1.5
	media-libs/openal
	virtual/opengl
	x11-apps/xrandr"

S="${WORKDIR}"

JAVA_PKG_BSFIX_NAME="build.xml build-generator.xml"
JAVA_ANT_REWRITE_CLASSPATH="true"

EANT_GENTOO_CLASSPATH="apple-java-extensions-bin apt-mirror jinput jutils"
EANT_BUILD_TARGET="jars headers"

src_compile() {
	# Build the JARs and headers.
	java-pkg-2_src_compile

	# Add "64" for amd64.
	local BITS=
	use amd64 && BITS=64

	# Their native build script sucks.
	cd "${S}/src/native" || die
	LIBRARY_PATH="$(java-config -g LDPATH)" gcc -shared -fPIC -std=c99 -pthread -Wall -Wl,--version-script=linux/${PN}.map -Wl,-z -Wl,defs ${CFLAGS} ${LDFLAGS} $(java-pkg_get-jni-cflags) -I{common,linux} {linux,generated,common}/*.c -lm -lX11 -lXcursor -lXrandr -lXxf86vm -ljawt -ldl -o lib${PN}${BITS}.so || die
}

src_install() {
	java-pkg_dojar libs/${PN}*.jar
	java-pkg_doso src/native/lib${PN}*.so

	use doc && java-pkg_dojavadoc doc/javadoc
	use source && java-pkg_dosrc src/java/org
}
