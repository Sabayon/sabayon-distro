# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

#extracted from cvs on 20070603
#cvs -d :pserver:guest@cvs.dev.java.net:/cvs login
#cvs -d :pserver:guest@cvs.dev.java.net:/cvs export -r HEAD jutils
# Then clean away binaries and .cvsignore files

DESCRIPTION="A set of APIs utilized by the Java Game Technology Group."
HOMEPAGE="https://jutils.dev.java.net"
SRC_URI="http://dev.gentoo.org/~betelgeuse/overlay_distfiles/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=">=virtual/jdk-1.4"
RDEPEND=">=virtual/jre-1.4"
IUSE=""

S="${WORKDIR}/${PN}"

# Uses additionalparam to feed -source which makes javadoc fail when we
# add the source attribute
JAVA_PKG_BSFIX_SOURCE_TAGS="${JAVA_PKG_BSFIX_SOURCE_TAGS/javadoc}"

# Graphical tests
RESTRICT="test"

src_install() {
	java-pkg_dojar bin/*.jar
	use source && java-pkg_dosrc src/java/net
	use doc && java-pkg_dojavadoc apidocs
}
