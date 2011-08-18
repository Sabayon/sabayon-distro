# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/openswan/openswan-2.6.35.ebuild,v 1.2 2011/08/16 13:24: Setsuna-Xero Exp $

EAPI="2"

inherit eutils linux-info toolchain-funcs flag-o-matic

DESCRIPTION="Open Source implementation of IPsec for the Linux operating system (was SuperFreeS/WAN)."
HOMEPAGE="http://www.openswan.org/"
SRC_URI="http://www.openswan.org/download/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86"
IUSE="caps curl ldap pam ssl extra-algorithms weak-algorithms nocrypto-algorithms ms-bad-proposal nss"

COMMON_DEPEND="!net-misc/strongswan
	dev-libs/gmp
	dev-lang/perl
	caps? ( sys-libs/libcap-ng )
	curl? ( net-misc/curl )
	ldap? ( net-nds/openldap )
	nss? ( dev-libs/nss )
	ssl? ( dev-libs/openssl )"
DEPEND="${COMMON_DEPEND}
	virtual/linux-sources
	app-text/xmlto
	app-text/docbook-xml-dtd:4.1.2" # see bug 237132
RDEPEND="${COMMON_DEPEND}
	virtual/logger
	sys-apps/iproute2"

pkg_setup() {
	if use nocrypto-algorithms && ! use weak-algorithms; then
		ewarn "Enabling nocrypto-algorithms USE flag has no effect when"
		ewarn "weak-algorithms USE flag is disabled"
	fi

	linux-info_pkg_setup

	if kernel_is -ge 2 6; then
		einfo "This ebuild will set ${P} to use 2.6 native IPsec (KAME)."
		einfo "KLIPS will not be compiled/installed."
		MYMAKE="programs"

	elif kernel_is 2 4; then
		if ! [[ -d "${KERNEL_DIR}/net/ipsec" ]]; then
			eerror "You need to have an IPsec enabled 2.4.x kernel."
			eerror "Ensure you have one running and make a symlink to it in /usr/src/linux"
			die
		fi

		einfo "Using patched-in IPsec code for kernel 2.4"
		einfo "Your kernel only supports KLIPS for kernel level IPsec."
		MYMAKE="confcheck programs"

	else
		die "Unsupported kernel version"
	fi

	# most code is OK, but programs/pluto code breaks strict aliasing
	append-cflags -fno-strict-aliasing
}

src_prepare() {
	epatch "${FILESDIR}"/${P}-gentoo.patch
	use ms-bad-proposal && epatch "${FILESDIR}"/${PN}-${PV%.*}-allow-ms-bad-proposal.patch

	find . -type f -regex '.*[.]\([1-8]\|html\|xml\)' -exec sed -i \
	    -e s:/usr/local:/usr:g '{}' \; ||
	    die "failed to replace text in docs"
}

get_make_options() {
	echo KERNELSRC=\"${KERNEL_DIR}\"\
		FINALEXAMPLECONFDIR=/usr/share/doc/${PF}\
		INC_RCDEFAULT=/etc/init.d\
		INC_USRLOCAL=/usr\
		INC_MANDIR=share/man\
		FINALDOCDIR=/usr/share/doc/${PF}/html\
		FINALLIBDIR=/usr/$(get_libdir)/ipsec\
		DESTDIR=\"${D}\"\
		USERCOMPILE=\"${CFLAGS}\"\
		CC=\"$(tc-getCC)\"

	use caps\
		&& echo USE_LIBCAP_NG=true\
		|| echo USE_LIBCAP_NG=false

	use curl\
		&& echo USE_LIBCURL=true\
		|| echo USE_LIBCURL=false

	use ldap\
		&& echo USE_LDAP=true\
		|| echo USE_LDAP=false

	echo USE_XAUTH=true
	use pam\
		&& echo USE_XAUTHPAM=true\
		|| echo USE_XAUTHPAM=false

	use nss\
		&& echo USE_LIBNSS=true\
		|| echo USE_LIBNSS=false

	use ssl\
		&& echo HAVE_OPENSSL=true\
		|| echo HAVE_OPENSSL=false

	use extra-algorithms\
		&& echo USE_EXTRACRYPTO=true\
		|| echo USE_EXTRACRYPTO=false
	if use weak-algorithms ; then
		echo USE_WEAKSTUFF=true
		if use nocrypto-algorithms; then
			echo USE_NOCRYPTO=true
		fi
	else
		echo USE_WEAKSTUFF=false
	fi

	echo USE_LWRES=false # needs bind9 with lwres support
	if use curl || use ldap || use pam; then
		echo HAVE_THREADS=true
	else
		echo HAVE_THREADS=false
	fi
}

src_compile() {
	eval set -- $(get_make_options)
	emake "$@" ${MYMAKE} || die "emake failed"
}

src_install() {
	eval set -- $(get_make_options)
	emake "$@" install || die "emake install failed"

	dodoc docs/{KNOWN_BUGS*,RELEASE-NOTES*,PATENTS*,debugging*}
	dohtml doc/*.html
	docinto quickstarts
	dodoc doc/quickstarts/*

	newinitd "${FILESDIR}"/ipsec-initd ipsec || die "failed to install init script"

	keepdir /var/run/pluto
}

pkg_preinst() {
	if has_version "<net-misc/openswan-2.6.14" && pushd "${ROOT}etc/ipsec"; then
		ewarn "Following files and directories were moved from '${ROOT}etc/ipsec' to '${ROOT}etc':"
		local i err=0
		if [ -h "../ipsec.d" ]; then
			rm "../ipsec.d" || die "failed to remove ../ipsec.d symlink"
		fi
		for i in *; do
			if [ -e "../$i" ]; then
				eerror "  $i NOT MOVED, ../$i already exists!"
				err=1
			elif [ -d "$i" ]; then
				mv "$i" .. || die "failed to move $i directory"
				ewarn "  directory $i"
			elif [ -f "$i" ]; then
				sed -i -e 's:/etc/ipsec/:/etc/:g' "$i" && \
					mv "$i" .. && ewarn "  file $i" || \
					die "failed to move $i file"
			else
				eerror "  $i NOT MOVED, it is not a file nor a directory!"
				err=1
			fi
		done
		popd
		if [ $err -eq 0 ]; then
			rmdir "${ROOT}etc/ipsec" || eerror "Failed to remove ${ROOT}etc/ipsec"
		else
			ewarn "${ROOT}etc/ipsec is not empty, you will have to remove it yourself"
		fi
	fi
}

pkg_postinst() {
	if kernel_is -ge 2 6; then
		CONFIG_CHECK="~NET_KEY ~INET_XFRM_MODE_TRANSPORT ~INET_XFRM_MODE_TUNNEL ~INET_AH ~INET_ESP ~INET_IPCOMP"
		WARNING_INET_AH="CONFIG_INET_AH:\tmissing IPsec AH support (needed if you want only authentication)"
		WARNING_INET_ESP="CONFIG_INET_ESP:\tmissing IPsec ESP support (needed if you want authentication and encryption)"
		WARNING_INET_IPCOMP="CONFIG_INET_IPCOMP:\tmissing IPsec Payload Compression (required for compress=yes)"
		check_extra_config
	fi
}

