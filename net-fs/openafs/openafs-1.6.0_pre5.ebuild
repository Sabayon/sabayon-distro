# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-fs/openafs/openafs-1.6.0_pre3.ebuild,v 1.1 2011/03/20 09:58:35 stefaan Exp $

EAPI="2"

inherit flag-o-matic eutils autotools toolchain-funcs versionator pam

MY_PV=$(delete_version_separator '_')
MY_P="${PN}-${MY_PV}"
S="${WORKDIR}/${MY_P}"
PVER="1"
DESCRIPTION="The OpenAFS distributed file system"
HOMEPAGE="http://www.openafs.org/"
# We always d/l the doc tarball as man pages are not USE=doc material
SRC_URI="http://openafs.org/dl/candidate/${MY_PV}/${MY_P}-src.tar.bz2
	http://openafs.org/dl/candidate/${MY_PV}/${MY_P}-doc.tar.bz2
	mirror://sabayon/${CATEGORY}/${P}-patches-${PVER}.tar.bz2"

LICENSE="IBM BSD openafs-krb5-a APSL-2 sun-rpc"
SLOT="0"
KEYWORDS="~amd64 ~sparc ~x86"
IUSE="doc kerberos pam"

RDEPEND="~net-fs/openafs-kernel-${PV}
	sys-libs/ncurses
	pam? ( sys-libs/pam )
	kerberos? ( virtual/krb5 )"

src_prepare() {
	EPATCH_EXCLUDE="012_all_kbuild.patch" \
	EPATCH_SUFFIX="patch" \
	epatch "${WORKDIR}"/gentoo/patches

	# packaging is f-ed up, so we can't run automake (i.e. eautoreconf)
	sed -i 's/^\(\s*\)a/\1ea/' regen.sh
	: # this line makes repoman ok with not calling eautoconf etc. directly
	skipman=1
	. regen.sh
}

src_configure() {
	# cannot use "use_with" macro, as --without-krb5-config crashes the econf
	local myconf=""
	if use kerberos; then
		myconf="--with-krb5-conf=$(type -p krb5-config)"
	fi

	AFS_SYSKVERS=26 \
	XCFLAGS="${CFLAGS}" \
	econf \
		$(use_enable pam) \
		--enable-supergroups \
		--disable-kernel-module \
		--disable-strip-binaries \
		${myconf}
}

src_compile() {
	emake all_nolibafs || die
}

src_install() {
	local CONFDIR=${WORKDIR}/gentoo/configs
	local SCRIPTDIR=${WORKDIR}/gentoo/scripts

	emake DESTDIR="${D}" install_nolibafs || die

	insinto /etc/openafs
	doins src/afsd/CellServDB || die
	echo "/afs:/var/cache/openafs:200000" > "${D}"/etc/openafs/cacheinfo
	echo "openafs.org" > "${D}"/etc/openafs/ThisCell

	# pam_afs and pam_afs.krb have been installed in irregular locations, fix
	if use pam ; then
		dopammod "${D}"/usr/$(get_libdir)/pam_afs* || die
	fi
	rm -f "${D}"/usr/$(get_libdir)/pam_afs* || die

	# remove kdump stuff provided by kexec-tools #222455
	rm -rf "${D}"/usr/sbin/kdump*

	# avoid collision with mit_krb5's version of kpasswd
	mv "${D}"/usr/bin/kpasswd{,_afs} || die
	mv "${D}"/usr/share/man/man1/kpasswd{,_afs}.1 || die

	# move lwp stuff around #200674 #330061
	mv "${D}"/usr/include/{lwp,lock,timer}.h "${D}"/usr/include/afs/ || die
	mv "${D}"/usr/$(get_libdir)/liblwp* "${D}"/usr/$(get_libdir)/afs/ || die
	# update paths to the relocated lwp headers
	sed -ri \
		-e '/^#include <(lwp|lock|timer).h>/s:<([^>]*)>:<afs/\1>:' \
		"${D}"/usr/include/*.h \
		"${D}"/usr/include/*/*.h \
		|| die

	# minimal documentation
	use pam && doman src/pam/pam_afs.5
	dodoc "${CONFDIR}"/README src/afsd/CellServDB

	# documentation package
	if use doc ; then
		dodoc doc/{arch,examples,pdf,protocol,txt}/*
		dohtml -A xml -r doc/{html,xml}/*
	fi

	# Gentoo related scripts
	newinitd "${SCRIPTDIR}"/openafs-client openafs-client || die
	newconfd "${CONFDIR}"/openafs-client openafs-client || die
	newinitd "${SCRIPTDIR}"/openafs-server openafs-server || die
	newconfd "${CONFDIR}"/openafs-server openafs-server || die

	# used directories: client
	keepdir /etc/openafs
	keepdir /var/cache/openafs

	# used directories: server
	keepdir /etc/openafs/server
	diropts -m0700
	keepdir /var/lib/openafs
	keepdir /var/lib/openafs/db
	diropts -m0755
	keepdir /var/lib/openafs/logs

	# link logfiles to /var/log
	dosym ../lib/openafs/logs /var/log/openafs
}

pkg_preinst() {
	## Somewhat intelligently install default configuration files
	## (when they are not present)
	local x
	for x in cacheinfo CellServDB ThisCell ; do
		if [ -e "${ROOT}"/etc/openafs/${x} ] ; then
			cp "${ROOT}"/etc/openafs/${x} "${D}"/etc/openafs/
		fi
	done
}

pkg_postinst() {
	elog "This installation should work out of the box (at least the"
	elog "client part doing global afs-cell browsing, unless you had"
	elog "a previous and different configuration).  If you want to"
	elog "set up your own cell or modify the standard config,"
	elog "please have a look at the Gentoo OpenAFS documentation"
	elog "(warning: it is not yet up to date wrt the new file locations)"
	elog
	elog "The documentation can be found at:"
	elog "  http://www.gentoo.org/doc/en/openafs.xml"
}
