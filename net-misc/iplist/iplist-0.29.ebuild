# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit eutils java-pkg-opt-2 java-ant-2 linux-info toolchain-funcs

DESCRIPTION="Blocks connections from/to hosts listed in files using iptables"
HOMEPAGE="http://iplist.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

COMMON_DEPEND="
	java? ( dev-java/appframework:0
		dev-java/swing-worker:0 )
	net-libs/libnetfilter_queue
	net-libs/libnfnetlink
	dev-libs/libpcre"
DEPEND="${COMMON_DEPEND}
	java? ( >=virtual/jdk-1.5
		app-arch/unzip )"
RDEPEND="${COMMON_DEPEND}
	net-firewall/iptables
	java? ( >=virtual/jre-1.5 )"

S="${WORKDIR}/${PN}"

pkg_setup() {
	local CONFIG_CHECK="~NETFILTER_XT_MATCH_IPRANGE"
	check_extra_config
	java-pkg-opt-2_pkg_setup
}

src_prepare() {
	sed -i '/strip/d' Makefile || die "sed (1) failed"
	sed -i \
		's,/usr/share/java/ipblockUI.jar,/usr/share/iplist/lib/ipblockUI.jar,' \
		ipblock || die "sed (2) failed"
	# patch char*->unsigned char* error, 
	# and various deprecations due to API change
	if has_version '>=net-libs/libnetfilter_queue-1.0.0' ; then
		epatch "${FILESDIR}"/${P}-libnetfilter_queue-1.0.0.patch
	fi
	java-pkg-opt-2_src_prepare
	if use java; then
		epatch "${FILESDIR}"/${PN}-fix-java-build.patch
		epatch "${FILESDIR}"/${PN}-java-classpath.patch
	fi
}

src_compile() {
	emake CPP="$(tc-getCXX)" || die
	if use java; then
		rm *.jar
		cd ipblockUI || die
		java-pkg_jar-from appframework,swing-worker
		unzip appframework.jar || die
		eant || die
	fi
}

src_install() {
	if use java ; then
		java-pkg_dojar ipblockUI/dist/ipblockUI.jar
		domenu ipblock.desktop || die
		doicon ipblock.png || die
		if use doc; then
			java-pkg_dojavadoc ipblockUI/dist/javadoc
		fi
	else
		use doc && ewarn "doc USE flag has no effect with -java"
	fi
	#emake DESTDIR="${D}" install || die "install failed!"
	dosbin iplist ipblock
	doman {${PN},ipblock}.8
	exeinto /etc/cron.daily
	newexe debian/ipblock.cron.daily ipblock
	doinitd gentoo/ipblock
	dodoc allow.p2p changelog THANKS
	insinto /etc
	doins ipblock.conf ipblock.lists
	insinto /var/cache/iplist
	doins allow.p2p
}

pkg_postinst() {
	elog "a cron file was set in /etc/cron.daily"
	elog "and it will update your lists once a day"
}
