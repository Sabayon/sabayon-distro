# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/evms/evms-2.5.5-r10.ebuild,v 1.11 2009/03/12 17:16:03 dev-zero Exp $

inherit eutils flag-o-matic multilib toolchain-funcs autotools linux-info

PATCHVER="${PV}-2"

DESCRIPTION="Utilities for the IBM Enterprise Volume Management System"
HOMEPAGE="http://www.sourceforge.net/projects/evms"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz
	mirror://gentoo/${PN}-patches-${PATCHVER}.tbz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="debug gtk hb hb2 ncurses nls"

#EVMS uses libuuid from e2fsprogs
RDEPEND="virtual/libc
	sys-fs/e2fsprogs
	|| ( >=sys-fs/lvm2-2.02.45 sys-fs/device-mapper )
	>=sys-apps/baselayout-1.9.4-r6
	gtk? ( =x11-libs/gtk+-1* =dev-libs/glib-1* )
	hb? ( !hb2? ( =sys-cluster/heartbeat-1* ) )
	hb2? ( >=sys-cluster/heartbeat-2 )
	ncurses? ( sys-libs/ncurses >=dev-libs/glib-2.12.4-r1 )"
DEPEND="${RDEPEND}
	gtk? ( dev-util/pkgconfig )
	ncurses? ( dev-util/pkgconfig )"

# While the test-concept holds, many of them fail due to unknown reasons.
# Since upstream is almost dead, we have to ignore that for now.
RESTRICT="test"

pkg_setup() {
	if use hb && use hb2 ; then
		ewarn "It's not possible to have support for heartbeat version 1 and 2 at the same time."
		ewarn "Assuming  that you want heartbeat-2, if not, please do not enable the hb2 use flag."
	fi

	get_running_version
	if [ ${KV_PATCH} -lt 19 ] || [ ${KV_MINOR} -eq 4 ] ; then
		ewarn "This revision of EVMS may not work correctly with kernels prior to 2.6.19 when"
		ewarn "using snapshots due to API changes. Please update your kernel or use EVMS 2.5.5-r9."
		ebeep 5
	fi

}

src_unpack() {
	unpack ${A}
	cd "${S}"

	sed -i \
		-e 's:--- /root/aclocal.m4.old:--- root/aclocal.m4.old:' \
		"${WORKDIR}"/patches/51_all_2.5.5-glib_dep.patch || die "404"

	EPATCH_SOURCE="${WORKDIR}/patches"
	EPATCH_SUFFIX="patch"
	epatch

	eautoreconf
}

src_compile() {
	# Bug #54856
	# filter-flags "-fstack-protector"
	replace-flags -O3 -O2
	replace-flags -Os -O2

	local excluded_interfaces=""
	use ncurses || excluded_interfaces="--disable-text-mode"
	use gtk || excluded_interfaces="${excluded_interfaces} --disable-gui"

	# hb2 should override hb
	local myconf="$(use_enable hb ha) --disable-hb2"
	use hb2 && myconf="--disable-ha --enable-hb2"

	# We have to link statically against glib because evmsn resides in /sbin
	econf \
		--libdir=/$(get_libdir) \
		--sbindir=/sbin \
		--includedir=/usr/include \
		--with-static-glib \
		$(use_with debug) \
		$(use_enable nls) \
		${myconf} \
		${excluded_interfaces} || die "Failed configure"
	emake || die "Failed emake"
}

src_install() {
	emake DESTDIR="${D}" install || die "Make install died"
	dodoc ChangeLog INSTALL* PLUGIN.IDS README TERMINOLOGY doc/linuxrc

	insinto /$(get_libdir)/rcscripts/addons
	newins "${FILESDIR}/evms2-start.sh" evms-start.sh || die "rcscript addon failed"

	# install the sample configuration into the doc dir
	dodoc "${D}/etc/evms.conf.sample"
	rm -f "${D}/etc/evms.conf.sample"

	# the kernel patches may come handy for people compiling their own kernel
	docinto kernel/2.4
	dodoc kernel/2.4/*
	docinto kernel/2.6
	dodoc kernel/2.6/*

	# move static libraries to /usr/lib
	dodir /usr/$(get_libdir)
	mv -f "${D}"/$(get_libdir)/*.a "${D}/usr/$(get_libdir)"

	# Create linker scripts for dynamic libs in /lib, else gcc
	# links to the static ones in /usr/lib first.  Bug #4411.
	for x in "${D}/usr/$(get_libdir)"/*.a ; do
		if [ -f ${x} ] ; then
			local lib="${x##*/}"
			gen_usr_ldscript ${lib/\.a/\.so}
		fi
	done

	# the gtk+ frontend should live in /usr/sbin
	if use gtk ; then
		dodir /usr/sbin
		mv -f "${D}"/sbin/evmsgui "${D}"/usr/sbin
	fi

	# Needed for bug #51252
	dosym libevms-2.5.so.0.0 /$(get_libdir)/libevms-2.5.so.0

	newinitd "${FILESDIR}"/evms.initd-2.5.5-r9 evms || die
	newconfd "${FILESDIR}"/evms.conf-2.5.5-r9 evms || die
}

src_test() {
	if [[ -z ${EVMS_TEST_VOLUME} ]] ; then
		eerror "This is a volume manager and it therefore needs a volume"
		eerror "for testing. You have to define EVMS_TEST_VOLUME as"
		eerror "a volume evms can operate on."
		eerror "Example: export EVMS_TEST_VOLUME=sda"
		eerror "Note: The volume-name can not be a symlink."
		eerror "WARNING: EVMS WILL DESTROY EVERYTHING ON IT."
		einfo "If you don't have an empty disk, you can use the loopback-device:"
		einfo "- Create a large file using dd (this creates a 4GB file):"
		einfo "  dd if=/dev/zero of=/tmp/evms_test_file bs=1M count=4096"
		einfo "- Activate a loop device on this file:"
		einfo "  losetup /dev/loop0 /tmp/evms_test_file"
		einfo "- export EVMS_TEST_VOLUME=loop0"
		einfo "The disk has to be at least 4GB!"
		einfo "To deactivate the loop-device afterwards:"
		einfo "- losetup -d /dev/loop0"
		hasq userpriv ${FEATURES} && ewarn "These tests have to run as root. Disable userpriv!"
		die "need test-volume"
	fi

	if hasq userpriv ${FEATURES} ; then
		eerror "These tests need root privileges. Disable userpriv!"
		die "userpriv is not supported"
	fi

	einfo "Disabling sandbox for:"
	einfo " - /dev/${EVMS_TEST_VOLUME}"
	addwrite /dev/${EVMS_TEST_VOLUME}
	einfo " - /dev/evms"
	addwrite /dev/evms
	einfo " - /var/lock/evms-engine"
	addwrite /var/lock/evms-engine

	cd "${S}/tests/suite"
	PATH="${S}/ui/cli:${S}/tests:/sbin:${PATH}" ./run_tests ${EVMS_TEST_VOLUME} || die "tests failed"
}
