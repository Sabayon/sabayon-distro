# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 eutils java-ant-2

MY_V=1.1.4
MY_MV=1.1

DESCRIPTION="389 Server Management Console (share and help files)"
HOMEPAGE="http://port389.org/"
SRC_URI="http://port389.org/sources/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="1.1"
KEYWORDS="~amd64 ~x86"
IUSE=""

COMMON_DEP="dev-java/jss:3.4
	dev-java/ldapsdk:4.1
	>=dev-java/idm-console-framework-1.1
	!app-admin/fedora-ds-admin-console"

RDEPEND=">=virtual/jre-1.5
	app-arch/zip
	${COMMON_DEP}"
DEPEND=">=virtual/jdk-1.5
	${COMMON_DEP}"

src_prepare() {
	# gentoo java rules say no jars with version number
	# so sed away the version indicator '-'
	sed -e "s!-\*!\*!g" -i build.xml

	java-pkg_jar-from ldapsdk-4.1 ldapjdk.jar
	java-pkg_jar-from jss-3.4 xpclass.jar jss4.jar
	java-pkg_jar-from idm-console-framework-1.1
}

src_compile() {
	eant -Dbuilt.dir="${S}"/build \
	     -Dldapjdk.location="${S}" \
	     -Djss.location="${S}" \
	     -Dconsole.location="${S}" ${antflags} || die "eant failed"

	if use doc; then
		eant -Dbuilt.dir="${S}"/build \
	     -Dldapjdk.location="${S}" \
	     -Djss.location="${S}" \
	     -Dconsole.location="${S}" ${antflags} javadoc || die "javadoc failed"
	fi
}

src_install() {
	java-pkg_jarinto /usr/share/dirsrv/html/java
	java-pkg_newjar "${S}"/build/package/389-admin-${MY_V}.jar 389-admin.jar
	java-pkg_newjar "${S}"/build/package/389-admin-${MY_V}_en.jar 389-admin_en.jar

	dosym 389-admin.jar /usr/share/dirsrv/html/java/389-admin-${MY_MV}.jar
	dosym 389-admin_en.jar /usr/share/dirsrv/html/java/389-admin-${MY_MV}_en.jar

	insinto /usr/share/dirsrv/manual/en/admin
	doins "${S}"/help/en/*.html || die
	doins "${S}"/help/en/tokens.map || die

	insinto /usr/share/dirsrv/manual/en/admin/help
	doins "${S}"/help/en/help/*.html || die

	if use doc;then
		java-pkg_dojavadoc build/doc || die
	fi

	if source; then
		java-pkg_dosrc src/com || die
	fi
}
