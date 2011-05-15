# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

WANT_ANT_TASKS="ant-nodeps"

inherit java-pkg-2 java-ant-2 eutils

# See for dev info
# http://overlays.gentoo.org/proj/java/wiki/
#	Java_Games_ProjectLightWeightJavaGameLibraryLWJGL
MY_PV="$(delete_version_separator 2)"
DESCRIPTION="The Lightweigth Java Game Library (LWJGL)"
HOMEPAGE="http://www.lwjgl.org"
SRC_URI="http://www.counties.co.nz/alistair/distfiles/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc devil"

CDEPEND="virtual/opengl
		media-libs/openal
		dev-java/jinput
		dev-java/jutils
		x11-libs/libXrandr
		x11-libs/libXxf86vm
		x11-libs/libXcursor
		devil? ( media-libs/devil )"

DEPEND=">=virtual/jdk-1.5
		>=dev-java/ant-core-1.5
		${CDEPEND}"
RDEPEND=">=virtual/jre-1.5
		${CDEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/fix-linux-build.patch"
	eant clean clean-generated

	# libs is the final install path for jars and so's
	rm -vr libs/*
	mkdir libs/linux
	cd libs
	java-pkg_jarfrom jinput
	java-pkg_jarfrom jutils
	cd linux

}

src_compile() {
	# Using com.sun.mirror.declaration from tools.jar
	eant -Djava.home=${JAVA_HOME} generate-all all $(use_doc javadoc) \
		-Dbuild.sysclasspath=first
}

src_install() {
	cd libs
	java-pkg_dojar lwjgl.jar lwjgl_util.jar
	use devil && java-pkg_dojar lwjgl_devil.jar
	if use amd64; then
		cp linux/liblwjgl64.so linux/liblwjgl.so || die
	fi
	java-pkg_doso linux/liblwjgl.so
	#if use_doc; then
	#	cd ${S}/doc
	#	mv javadoc api
	#	java-pkg_dohtml -r api
	#fi
	cd "${S}"
	use_doc && java-pkg_dojavadoc doc/javadoc
}
