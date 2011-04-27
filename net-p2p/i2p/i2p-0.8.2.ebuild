# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# Nonofficial ebuild by Ycarus. For new version look here : http://gentoo.zugaina.org/

inherit eutils java-pkg-2 java-ant-2

JETTY_V="5.1.15"

DESCRIPTION="I2P is an anonymous network, exposing a simple layer that applications can use to anonymously and securely send messages to each other."
SRC_URI="http://mirror.i2p2.de/i2psource_${PV}.tar.bz2
	http://dist.codehaus.org/jetty/jetty-5.1.x/jetty-${JETTY_V}.tgz"
HOMEPAGE="http://www.i2p.net/"

SLOT="0"
KEYWORDS="~x86 ~amd64"
LICENSE="GPL-2"
IUSE=""
DEPEND=">=virtual/jdk-1.5
	dev-java/ant"


QA_TEXTRELS="opt/i2p/i2psvc"
QA_EXECSTACK="opt/i2p/i2psvc"

src_unpack() {
	unpack i2psource_${PV}.tar.bz2
	cp ${DISTDIR}/jetty-${JETTY_V}.tgz -P ${S}/apps/jetty || die
}

src_compile() {
	eant pkg || die
}

src_install() {
	dodir /opt/i2p /usr/bin
	exeinto /opt/i2p
	cp -r "${S}"/pkg-temp/* "${D}"/opt/i2p/
	sed -i -e 's:%INSTALL_PATH:/opt/i2p:g' -e 's:%SYSTEM_java_io_tmpdir:/opt/i2p:g' "${D}"/opt/i2p/i2prouter
	sed -i -e 's:$INSTALL_PATH:/opt/i2p:g' -e 's:$SYSTEM_java_io_tmpdir:/opt/i2p:g' "${D}"/opt/i2p/wrapper.config
	doexe pkg-temp/i2prouter pkg-temp/osid pkg-temp/postinstall.sh pkg-temp/eepget pkg-temp/*.config
	if [ "${ARCH}" == "x86" ] ; then
	    cp "${D}"/opt/i2p/lib/wrapper/linux/libwrapper.so "${D}"/opt/i2p/lib/
	    cp "${D}"/opt/i2p/lib/wrapper/linux/wrapper.jar "${D}"/opt/i2p/lib/
	    cp "${D}"/opt/i2p/lib/wrapper/linux/i2psvc "${D}"/opt/i2p/
	elif [ "${ARCH}" == "amd64" ] ; then
	    cp "${D}"/opt/i2p/lib/wrapper/linux64/libwrapper.so "${D}"/opt/i2p/lib/
	    cp "${D}"/opt/i2p/lib/wrapper/linux64/wrapper.jar "${D}"/opt/i2p/lib/
	    cp "${D}"/opt/i2p/lib/wrapper/linux64/i2psvc "${D}"/opt/i2p/
	fi
	
	rm -rf "${D}"/opt/i2p/icons "${D}"/opt/i2p/lib/wrapper
	rm -f "${D}"/opt/i2p/lib/*.dll "${D}"/opt/i2p/*.bat
	dosym "${D}"/opt/i2p/i2prouter /usr/bin/i2prouter
	
	exeinto /etc/init.d
	doexe ${FILESDIR}/i2p
}

pkg_postinst() {
	enewgroup i2p
	enewuser i2p -1 -1 /opt/i2p/home i2p -m
	einfo "Configure the router now : http://localhost:7657/index.jsp"
	einfo "Use /etc/init.d/i2p start to start I2P"
}
