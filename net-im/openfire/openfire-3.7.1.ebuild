# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-im/openfire/openfire-3.7.1.ebuild,v 1.1 2011/10/28 12:15:37 slyfox Exp $

inherit eutils java-pkg-2 java-ant-2

MY_P=${PN}_src_${PV//./_}
DESCRIPTION="Openfire (formerly wildfire) real time collaboration (RTC) server"
HOMEPAGE="http://www.igniterealtime.org/projects/openfire/"
SRC_URI="http://www.igniterealtime.org/builds/openfire/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

RDEPEND=">=virtual/jre-1.5"
DEPEND="net-im/jabber-base
		~dev-java/ant-contrib-1.0_beta3
		>=virtual/jdk-1.5"
#~dev-java/ant-contrib-1.0_beta2

S=${WORKDIR}/${PN}_src

RESTRICT=""

pkg_setup() {
	if [ -f /etc/env.d/98openfire ]; then
		einfo "This is an upgrade"
		ewarn "As the plugin API changed, at least these plugins need to be updated also:"
		ewarn "User Search, IM Gateway, Fastpath, Monitoring"
		ewarn "hey can be downloaded via Admin Console or at"
		ewarn "${HOMEPAGE}"
	else
		ewarn "If this is an upgrade stop right ( CONTROL-C ) and run the command:"
		ewarn "echo 'CONFIG_PROTECT=\"/opt/openfire/resources/security/\"' > /etc/env.d/98openfire "
		ewarn "For more info see bug #139708"
		sleep 11
	fi
	java-pkg-2_pkg_setup
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/buildxml.patch
	epatch "${FILESDIR}"/buildxml-ant.patch

	# TODO should replace jars in build/lib with ones packaged by us -nichoj
}

src_compile() {
	# Jikes doesn't support -source 1.5
	java-pkg_filter-compiler jikes

	ANT_TASKS="ant-contrib"
	eant -f build/build.xml openfire plugins $(use_doc)
}

src_install() {
	dodir /opt/openfire

	newinitd "${FILESDIR}"/openfire-initd openfire
	newconfd "${FILESDIR}"/openfire-confd openfire

	dodir /opt/openfire/conf
	insinto /opt/openfire/conf
	newins target/openfire/conf/openfire.xml openfire.xml.sample

	dodir /opt/openfire/logs
	keepdir /opt/openfire/logs

	dodir /opt/openfire/lib
	insinto /opt/openfire/lib
	doins target/openfire/lib/*

	dodir /opt/openfire/plugins
	insinto /opt/openfire/plugins
	doins -r target/openfire/plugins/*

	dodir /opt/openfire/resources
	insinto /opt/openfire/resources
	doins -r target/openfire/resources/*

	if use doc; then
		dohtml -r documentation/docs/*
	fi
	dodoc documentation/dist/*

	#Protect ssl key on upgrade
	dodir /etc/env.d/
	echo 'CONFIG_PROTECT="/opt/openfire/resources/security/"' > "${D}"/etc/env.d/98openfire
}

pkg_postinst() {
	chown -R jabber:jabber /opt/openfire

	ewarn If this is a new install, please edit /opt/openfire/conf/openfire.xml.sample
	ewarn and save it as /opt/openfire/conf/openfire.xml
	ewarn
	ewarn The following must be be owned or writable by the jabber user.
	ewarn /opt/openfire/conf/openfire.xml
}
