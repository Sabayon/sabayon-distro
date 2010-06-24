# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

WANT_AUTOMAKE="1.9"

MY_PV=${PV/_rc/.rc}
MY_PV=${MY_PV/_a/.a}

inherit eutils multilib autotools depend.apache

DESCRIPTION="389 Directory Server (admin)"
HOMEPAGE="http://port389.org/"
SRC_URI="http://port389.org/sources/${PN}-${MY_PV}.tar.bz2"

LICENSE="GPL-2 Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+console debug ipv6 selinux threads"

# TODO snmp agent init script

DEPEND="console? ( app-admin/389-console )
	dev-libs/nss[utils]
	|| ( <=dev-libs/nspr-4.8.3-r3[ipv6?] >=dev-libs/nspr-4.8.4 )
	dev-libs/svrcore
	dev-libs/mozldap
	dev-libs/cyrus-sasl
	dev-libs/icu
	>=sys-libs/db-4.2.52
	net-analyzer/net-snmp[ipv6?]
	sys-apps/tcp-wrappers[ipv6?]
	sys-libs/pam
	app-misc/mime-types
	www-apache/mod_nss
	>=app-admin/389-admin-console-1.1.0
	>=app-admin/389-ds-console-1.1.0
	dev-libs/389-adminutil
	www-client/lynx
	www-servers/apache:2[apache2_modules_actions,apache2_modules_alias]
	www-servers/apache:2[apache2_modules_auth_basic,apache2_modules_authz_default]
	www-servers/apache:2[apache2_modules_mime_magic,apache2_modules_rewrite]
	www-servers/apache:2[apache2_modules_setenvif,suexec,threads]
	!www-apache/mod_admserv
	!www-apache/mod_restartd
	selinux? ( sys-apps/policycoreutils
		sec-policy/selinux-base-policy
		sys-apps/checkpolicy )"

RDEPEND="${DEPEND}"

# 389-ds-base needs to compile libacl-plugin.so
# in order to make /usr/sbin/setup-ds-admin.pl working
PDEPEND="net-nds/389-ds-base[presence,bitwise]"

S="${WORKDIR}/${PN}-${MY_PV}"

need_apache2_2

pkg_setup() {
	depend.apache_pkg_setup
	# This is also configured in 389-ds-base, but given
	# our dependency setup, to make sure that all is
	# pretty to the build system, better doing it here too
        enewgroup dirsrv
        enewuser dirsrv -1 -1 -1 dirsrv
}

src_prepare() {

	epatch "${FILESDIR}/1.1.11_rc1/"*.patch
	# Configuration files fixes
	epatch "${FILESDIR}/${PN}-"*.patch

	sed -e "s!SUBDIRS!# SUBDIRS!g" -i Makefile.am || die "sed failed"
	# Setup default user/group, in this case it's dirsrv
	sed -e "s!nobody!dirsrv!g" -i configure.ac || die "sed failed"

	eautoreconf
}

src_configure() {
	# stub autoconf triplet  :(
	local myconf=""
	use debug && myconf="--enable-debug"
	use selinux &&  myconf="${myconf} --with-selinux"

	econf \
		$(use_enable threads threading) \
		--disable-rpath \
		--with-fhs \
		--with-apr-config \
		--with-apxs=${APXS} \
		--with-httpd=${APACHE_BIN} \
		${myconf} || die "econf failed"
}

src_install () {

	emake DESTDIR="${D}" install || die "emake failed"
	keepdir /var/log/dirsrv/admin-serv

	# remove redhat style init script.
	rm -rf "${D}"/etc/rc.d
	rm -rf "${D}"/etc/default

	# install gentoo style init script.
	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	newconfd "${FILESDIR}"/${PN}.confd ${PN}

	# remove redhat style wrapper scripts
	# and install gentoo scripts.
	rm -rf "${D}"/usr/sbin/*-ds-admin
	dosbin "${FILESDIR}"/*-ds-admin

	# In this version build systems for modules is delete :(
	# manually install modules, not using apache-modules eclass
	# because use bindled library

	# install mod_admserv
	exeinto "${APACHE_MODULESDIR}"
	doexe "${S}/.libs"/mod_admserv.so || die "internal ebuild error: mod_admserv not found"

	insinto "${APACHE_MODULES_CONFDIR}"
	newins "${FILESDIR}/${PV}"/48_mod_admserv.conf 48_mod_admserv \
				|| die "internal ebuild error: 48_mod_admserv.conf not found"

	# install mod_restard
	exeinto "${APACHE_MODULESDIR}"
	doexe "${S}/.libs"/mod_restartd.so || die "internal ebuild error: mod_restartd  not found"

	insinto "${APACHE_MODULES_CONFDIR}"
	newins "${FILESDIR}/${PV}"/48_mod_restartd.conf 48_mod_restartd \
				|| die "internal ebuild error: 48_mod_restard.conf not found"

	if use selinux; then
		local POLICY_TYPES="targeted"
		cd "${S}"/selinux-build
		cp /usr/share/selinux/${POLICY_TYPES}/include/Makefile  .
		make || die "selinux policy compile failed"
		insinto /usr/share/selinux/${POLICY_TYPES}
		doins -r "${S}/selinux-build/"*.pp
	fi

}

pkg_postinst() {

	# show setup information
	elog "Once you configured www-servers/apache as written above,"
	elog "you need to run (as root): /usr/sbin/setup-ds-admin.pl"
	elog

	# show security and sysctl info
	elog "It is recommended to setup net.ipv4.tcp_keep_alive_time"
	elog "in /etc/sysctl.conf (or via sysctl -w && sysctl -p) to a reasonable"
	elog "value (in milliseconds) to avoid temporary server congestions"
	elog "from lost client connections"
	elog

	# /etc/security/limits.conf settings
	elog "It is also recommended to fine tune the maximum open files"
	elog "settings inside /etc/security/limits.conf:"
	elog "* soft nofile 2048"
	elog "* hard nofile 4096"
	elog

	elog "To start 389 Directory Server Administration Interface at boot"
	elog "please add 389-admin service to the default runlevel:"
	elog
	elog "    rc-update add 389-admin default"
	elog

	elog "for 389 Directory Server Admin interface to work, you need"
	elog "to setup a FQDN hostname and use it while running /usr/sbin/setup-ds-admin.pl"
	elog

}
