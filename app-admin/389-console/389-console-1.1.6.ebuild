# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

JAVA_PKG_IUSE=""

inherit java-pkg-2 eutils java-ant-2

DESCRIPTION="A Java based console for remote management 389 server"
HOMEPAGE="http://directory.fedoraproject.org/"
SRC_URI="http://port389.org/sources/${P}.tar.bz2
	http://www.nongnu.org/smc/docs/smc-presentation2/pix/fedora.png"

LICENSE="LGPL-2.1"
SLOT="1.1"
KEYWORDS="~amd64 ~x86"
IUSE=""

COMMON_DEP="dev-java/jss:3.4
	dev-java/ldapsdk:4.1
	>=dev-java/idm-console-framework-1.1
	app-admin/389-admin-console
	!!app-admin/fedora-idm-console
	!!app-admin/389-idm-console"

RDEPEND=">=virtual/jre-1.6
	${COMMON_DEP}"

DEPEND=">=virtual/jdk-1.6
	${COMMON_DEP}"

src_unpack() {
	unpack ${P}.tar.bz2
}
src_prepare() {

	java-pkg_jar-from ldapsdk-4.1 ldapjdk.jar
	java-pkg_jar-from jss-3.4 xpclass.jar jss4.jar
	java-pkg_jar-from idm-console-framework-1.1
}

src_compile() {
	eant -Dbuilt.dir="${S}"/build \
	    -Dldapjdk.local.location="${S}" \
	    -Djss.local.location="${S}" \
	    -Dconsole.local.location="${S}" ${antflags} \
				||die "eant failed"
}

src_install() {
	java-pkg_newjar "${S}"/build/389-console-1.1.4_en.jar 389-console_en.jar
	java-pkg_dolauncher ${PN} --main com.netscape.management.client.console.Console \
				--pwd "/usr/share/dirsrv/html/java/" \
				--pkg_args "-Djava.util.prefs.systemRoot=\"\$HOME/.${PN}\" -Djava.util.prefs.userRoot=\"\$HOME/.${PN}\""\
				die

	doicon "${DISTDIR}"/fedora.png || die "doicon failed"
	make_desktop_entry ${PN} "Port389 Management Console" fedora.png System Path=fedora.png
}
