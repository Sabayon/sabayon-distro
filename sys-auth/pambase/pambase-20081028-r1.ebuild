# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-auth/pambase/pambase-20081028-r1.ebuild,v 1.2 2008/11/09 12:21:27 vapier Exp $

EAPI=2

inherit eutils

DESCRIPTION="PAM base configuration files"
HOMEPAGE="http://www.gentoo.org/proj/en/base/pam/"
SRC_URI="http://www.flameeyes.eu/gentoo-distfiles/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
IUSE="debug cracklib passwdqc consolekit gnome-keyring selinux mktemp ssh +sha512"
RESTRICT="binchecks"

RDEPEND="
	|| (
		>=sys-libs/pam-0.99.9.0-r1
		( sys-auth/openpam
		  || ( sys-freebsd/freebsd-pam-modules sys-netbsd/netbsd-pam-modules )
		)
	)
	cracklib? ( >=sys-libs/pam-0.99[cracklib] )
	consolekit? ( sys-auth/consolekit[pam] )
	gnome-keyring? ( >=gnome-base/gnome-keyring-2.20[pam] )
	selinux? ( >=sys-libs/pam-0.99[selinux] )
	passwdqc? ( >=sys-auth/pam_passwdqc-1.0.4 )
	mktemp? ( sys-auth/pam_mktemp )
	ssh? ( sys-auth/pam_ssh )
	sha512? ( >=sys-libs/pam-1.0.1 )
	!<sys-freebsd/freebsd-pam-modules-6.2-r1
	!<sys-libs/pam-0.99.9.0-r1"
DEPEND=""

src_compile() {

	# Add md5 support
	epatch "${FILESDIR}/pambase-md5-sysauth.patch"

	has_version sys-libs/pam && implementation="linux-pam"
	has_version sys-auth/openpam && implementation="openpam"

	emake \
		GIT=true \
		DEBUG=$(use debug && echo yes || echo no) \
		CRACKLIB=$(use cracklib && echo yes || echo no) \
		PASSWDQC=$(use passwdqc && echo yes || echo no) \
		CONSOLEKIT=$(use consolekit && echo yes || echo no) \
		GNOME_KEYRING=$(use gnome-keyring && echo yes || echo no) \
		SELINUX=$(use selinux && echo yes || echo no) \
		MKTEMP=$(use mktemp && echo yes || echo no) \
		PAM_SSH=$(use ssh && echo yes || echo no) \
		SHA512=$(use sha512 && echo yes || echo no) \
		IMPLEMENTATION=${implementation} \
		|| die "emake failed"
}

src_install() {
	emake GIT=true DESTDIR="${D}" install || die "emake install failed"
}

pkg_postinst() {
	if use sha512; then
		elog "Starting from version 20080801, pambase optionally enables"
		elog "SHA512-hashed passwords. For this to work, you need sys-libs/pam-1.0.1"
		elog "built against sys-libs/glibc-2.7 or later."
		elog "If you don't have support for this, it will automatically fallback"
		elog "to MD5-hashed passwords, just like before."
		elog
		elog "Please note that the change only affects the newly-changed passwords"
		elog "and that SHA512-hashed passwords will not work on earlier versions"
		elog "of glibc or Linux-PAM."
	fi
}
