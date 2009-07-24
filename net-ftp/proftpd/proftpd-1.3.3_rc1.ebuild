# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-ftp/proftpd/proftpd-1.3.2-r2.ebuild,v 1.8 2009/05/02 15:57:27 jer Exp $

inherit eutils flag-o-matic toolchain-funcs autotools

KEYWORDS="alpha amd64 hppa ~ia64 ~mips ppc ppc64 sparc x86"

IUSE="acl authfile ban case clamav deflate hardened ifsession ipv6 kerberos ldap mysql ncurses nls noauthunix opensslcrypt pam postgres radius rewrite selinux shaper sitemisc softquota ssl tcpd vroot xinetd"

CASE_VER="0.3"
CLAMAV_VER="0.10"
DEFLATE_VER="0.3.1"
MODGSS_VER="1.3.1"
SHAPER_VER="0.6.5"
VROOT_VER="0.8.3"

DESCRIPTION="An advanced and very configurable FTP server."

SRC_URI="ftp://ftp.proftpd.org/distrib/source/${P/_/}.tar.bz2
		case? ( http://www.castaglia.org/${PN}/modules/${PN}-mod-case-${CASE_VER}.tar.gz )
		clamav? ( http://www.thrallingpenguin.com/resources/mod_clamav-${CLAMAV_VER}.tar.gz )
		deflate? ( http://www.castaglia.org/${PN}/modules/${PN}-mod-deflate-${DEFLATE_VER}.tar.gz )
		kerberos? ( mirror://sourceforge/gssmod/mod_gss-${MODGSS_VER}.tar.gz )
		shaper? ( http://www.castaglia.org/${PN}/modules/${PN}-mod-shaper-${SHAPER_VER}.tar.gz )
		vroot? ( http://www.castaglia.org/${PN}/modules/${PN}-mod-vroot-${VROOT_VER}.tar.gz )"

HOMEPAGE="http://www.proftpd.org/
		http://www.castaglia.org/proftpd/
		http://www.thrallingpenguin.com/resources/mod_clamav.htm
		http://gssmod.sourceforge.net"

SLOT="0"
LICENSE="GPL-2"

DEPEND="acl? ( sys-apps/acl sys-apps/attr )
		clamav? ( app-antivirus/clamav )
		kerberos? ( || ( app-crypt/mit-krb5 app-crypt/heimdal ) )
		ldap? ( >=net-nds/openldap-1.2.11 )
		mysql? ( virtual/mysql )
		ncurses? ( sys-libs/ncurses )
		opensslcrypt? ( >=dev-libs/openssl-0.9.6f )
		pam? ( virtual/pam )
		postgres? ( virtual/postgresql-base )
		ssl? ( >=dev-libs/openssl-0.9.6f )
		tcpd? ( >=sys-apps/tcp-wrappers-7.6-r3 )
		xinetd? ( virtual/inetd )"

RDEPEND="${DEPEND}
		net-ftp/ftpbase
		selinux? ( sec-policy/selinux-ftpd )"

S="${WORKDIR}/${P/_/}"

pkg_setup() {
	# Add the proftpd user to make the default config
	# work out-of-the-box
	enewgroup proftpd
	enewuser proftpd -1 -1 -1 proftpd
}

src_unpack() {
	unpack ${P/_/}.tar.bz2
	cd "${S}"

	# Fix mysql include when both backends are enabled
	epatch "${FILESDIR}"/proftpd-1.3.2-mysql-include.patch
	# Do not use bundled libltdl when compiling mod_dso
	epatch "${FILESDIR}"/proftpd-1.3.2-system-libltdl.patch

	# Fix stripping of files
	sed -e "s| @INSTALL_STRIP@||g" -i Make*

	if use case ; then
		unpack ${PN}-mod-case-${CASE_VER}.tar.gz
		cp -f mod_case/mod_case.c contrib/
		cp -f mod_case/mod_case.html doc/
	fi

	if use clamav ; then
		unpack mod_clamav-${CLAMAV_VER}.tar.gz
		cp -f mod_clamav-${CLAMAV_VER}/mod_clamav.* contrib/
		epatch mod_clamav-${CLAMAV_VER}/${PN}.patch
	fi

	if use deflate ; then
		unpack ${PN}-mod-deflate-${DEFLATE_VER}.tar.gz
		cp -f mod_deflate/mod_deflate.c contrib/
		cp -f mod_deflate/mod_deflate.html doc/
	fi

	if use kerberos ; then
		unpack mod_gss-${MODGSS_VER}.tar.gz
	fi

	if use shaper ; then
		unpack ${PN}-mod-shaper-${SHAPER_VER}.tar.gz
		cp -f mod_shaper/mod_shaper.c contrib/
		cp -f mod_shaper/mod_shaper.html doc/
	fi

	if use vroot ; then
		unpack ${PN}-mod-vroot-${VROOT_VER}.tar.gz
		cp -f mod_vroot/mod_vroot.c contrib/
		cp -f mod_vroot/mod_vroot.html doc/
	fi

	# Fix bug #221275
	# extract custom PR_ macros from aclocal.m4 to acinclude.m4
	# and delete the provided aclocal.m4 before running autoreconf
	einfo "Extract custom m4 macros from aclocal.m4 ..."
	sed -e '/libtool\.m4/q' aclocal.m4 > acinclude.m4
	rm -f aclocal.m4

	eautoreconf
}

src_compile() {
	addpredict /etc/krb5.conf
	local modules myconf mylibs

	modules="mod_ratio:mod_readme:mod_ctrls_admin"
	use acl && modules="${modules}:mod_facl"
	use ban && modules="${modules}:mod_ban"
	use case && modules="${modules}:mod_case"
	use clamav && modules="${modules}:mod_clamav"
	use deflate && modules="${modules}:mod_deflate"
	use pam && modules="${modules}:mod_auth_pam"
	use radius && modules="${modules}:mod_radius"
	use rewrite && modules="${modules}:mod_rewrite"
	use shaper && modules="${modules}:mod_shaper"
	use sitemisc && modules="${modules}:mod_site_misc"
	use ssl && modules="${modules}:mod_tls"
	use tcpd && modules="${modules}:mod_wrap"
	use vroot && modules="${modules}:mod_vroot"

	# pam needs to be explicitely disabled
	use pam || myconf="${myconf} --enable-auth-pam=no"

	if use ldap ; then
		modules="${modules}:mod_ldap"
		mylibs="${mylibs} -lresolv"
		use ssl && CFLAGS="${CFLAGS} -DUSE_LDAP_TLS"
	fi

	if use opensslcrypt ; then
		myconf="${myconf} --enable-openssl --with-includes=/usr/include/openssl"
		mylibs="${mylibs} -lcrypto"
		CFLAGS="${CFLAGS} -DHAVE_OPENSSL"
	fi

	use nls && myconf="${myconf} --enable-nls"

	if use mysql || use postgres ; then
		modules="${modules}:mod_sql"
		if use mysql ; then
			modules="${modules}:mod_sql_mysql"
			myconf="${myconf} --with-includes=/usr/include/mysql"
		fi
		if use postgres ; then
			modules="${modules}:mod_sql_postgres"
			myconf="${myconf} --with-includes=/usr/include/postgresql"
		fi
	fi

	if use softquota ; then
		modules="${modules}:mod_quotatab"
		if use mysql || use postgres ; then
			modules="${modules}:mod_quotatab_sql"
		fi
		if use radius ; then
			modules="${modules}:mod_quotatab_radius"
		fi
		if use ldap ; then
			modules="${modules}:mod_quotatab_file:mod_quotatab_ldap"
		else
			modules="${modules}:mod_quotatab_file"
		fi
	fi

	# mod_ifsession should be the last module in the --with-modules list
	# see http://www.castaglia.org/proftpd/modules/mod_ifsession.html#Installation
	use ifsession && modules="${modules}:mod_ifsession"

	# bug #30359
	use hardened && echo > lib/libcap/cap_sys.c
	gcc-specs-pie && echo > lib/libcap/cap_sys.c

	if use noauthunix ; then
		myconf="${myconf} --disable-auth-unix"
	else
		myconf="${myconf} --enable-auth-unix"
	fi

	if use kerberos ; then
		cd "${S}"/mod_gss-${MODGSS_VER}
		# Generate source files for installed virtual/krb5 provider
		if has_version app-crypt/mit-krb5; then
			econf --enable-mit
		else
			econf --enable-heimdal
		fi
		cd "${S}"
		# copy the generated files
		cp -f mod_gss-${MODGSS_VER}/mod_gss.c contrib/
		cp -f mod_gss-${MODGSS_VER}/mod_gss.h include/
		cp -f mod_gss-${MODGSS_VER}/mod_auth_gss.c contrib/

		myconf="${myconf} --enable-dso  --with-shared=mod_gss:mod_auth_gss"
	fi

	LIBS="${mylibs}" econf \
		--sbindir=/usr/sbin \
		--localstatedir=/var/run \
		--sysconfdir=/etc/proftpd \
		--enable-shadow \
		--enable-autoshadow \
		--enable-ctrls \
		--with-modules=${modules} \
		$(use_enable acl facl) \
		$(use_enable authfile auth-file) \
		$(use_enable ipv6) \
		$(use_enable ncurses) \
		${myconf} || die "econf failed"

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	keepdir /var/run/proftpd

	dodoc "${FILESDIR}/proftpd.conf" \
		COPYING CREDITS ChangeLog NEWS README* \
		doc/license.txt
	dohtml doc/*.html
	dohtml doc/howto/*.html

	docinto rfc
	dodoc doc/rfc/*.txt

	mv -f "${D}/etc/proftpd/proftpd.conf" "${D}/etc/proftpd/proftpd.conf.distrib"

	insinto /etc/proftpd
	newins "${FILESDIR}/proftpd.conf" proftpd.conf.sample

	if use xinetd ; then
		insinto /etc/xinetd.d
		newins "${FILESDIR}/proftpd.xinetd" proftpd
	fi

	newinitd "${FILESDIR}/proftpd.rc6" proftpd
}

pkg_postinst() {
	elog
	elog "You can find the config files in /etc/proftpd"
	elog
	ewarn "With the introduction of net-ftp/ftpbase the ftp user is now ftp."
	ewarn "Remember to change that in the configuration file."
	ewarn
	if use mysql && use postgres ; then
		ewarn "ProFTPD has been build with the MySQL and PostgreSQL modules."
		ewarn "You can use the 'SQLBackend' directive to specify the used SQL"
		ewarn "backend. Without this directive the default backend is MySQL."
		ewarn
	fi
	if use clamav ; then
		ewarn "mod_clamav was updated to a new version, which uses Clamd"
		ewarn "only for virus scanning, so you'll have to set Clamd up"
		ewarn "and start it, also re-check the mod_clamav docs."
		ewarn
	fi
}
