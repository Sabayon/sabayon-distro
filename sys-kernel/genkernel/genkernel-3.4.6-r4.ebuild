# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-kernel/genkernel/genkernel-3.4.5-r1.ebuild,v 1.1 2006/11/22 17:33:51 agriffis Exp $

inherit bash-completion eutils

VERSION_DMAP='1.02.07'
VERSION_DMRAID='1.0.0.rc13'
VERSION_E2FSPROGS='1.38'
VERSION_LVM2='2.02.05'
VERSION_PKG='3.4'
VERSION_SUSPEND='0.5'
VERSION_UNIONFS='0.1'

DESCRIPTION="Gentoo autokernel script"
HOMEPAGE="http://www.gentoo.org"
SRC_URI="http://dev.gentoo.org/~wolf31o2/sources/genkernel/${P}.tar.bz2
	http://dev.gentoo.org/~wolf31o2/sources/genkernel/genkernel-pkg-${VERSION_PKG}.tar.bz2
	http://people.redhat.com/~heinzm/sw/dmraid/src/dmraid-${VERSION_DMRAID}.tar.bz2
	ftp://sources.redhat.com/pub/lvm2/old/LVM2.${VERSION_LVM2}.tgz
	ftp://sources.redhat.com/pub/dm/old/device-mapper.${VERSION_DMAP}.tgz
	mirror://sourceforge/suspend/suspend-${VERSION_SUSPEND}.tar.gz
	ftp://ftp.fsl.cs.sunysb.edu/pub/unionfs/unionfs-utils-0.x/unionfs-utils-${VERSION_UNIONFS}.tar.gz
	mirror://sourceforge/e2fsprogs/e2fsprogs-${VERSION_E2FSPROGS}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sparc ~x86"
IUSE="ibm selinux"

DEPEND="sys-fs/e2fsprogs
	selinux? ( sys-libs/libselinux )"
RDEPEND="${DEPEND} app-arch/cpio"

src_unpack() {
	unpack ${P}.tar.bz2
	cd "${S}"
	unpack ${PN}-pkg-${VERSION_PKG}.tar.bz2

	cp ${FILESDIR}/suspend-0.5-Makefile.patch pkg
	use selinux && sed -i 's/###//g' gen_compile.sh

	# Add UnionFS support
	epatch ${FILESDIR}/${P}-unionfs-inkernel-support.patch

	# Add Sabayon Linux text
	epatch ${FILESDIR}/${P}-sabayon-linux.patch

	# add init-ng/einit support
	epatch ${FILESDIR}/${P}-accel_init-support.patch

	# Smarter "doslowusb" option
	epatch ${FILESDIR}/${P}-smarter-doslowusb.patch
}

src_install() {
	dodir /etc
	cp "${S}"/genkernel.conf ${D}/etc
	# This block updates genkernel.conf
	sed -i -e "s:VERSION_DMAP:$VERSION_DMAP:" \
		-e "s:VERSION_DMRAID:$VERSION_DMRAID:" \
		-e "s:VERSION_E2FSPROGS:$VERSION_E2FSPROGS:" \
		-e "s:VERSION_LVM2:$VERSION_LVM2:" \
		-e "s:VERSION_UNIONFS:$VERSION_UNIONFS:" \
		-e "s:VERSION_SUSPEND:$VERSION_SUSPEND:" \
		${D}/etc/genkernel.conf || die "Could not adjust versions"

	dodir /usr/share/genkernel
	use ibm && cp "${S}"/ppc64/kernel-2.6-pSeries "${S}"/ppc64/kernel-2.6 || \
		cp "${S}"/ppc64/kernel-2.6.g5 "${S}"/ppc64/kernel-2.6
	cp -Rp "${S}"/* ${D}/usr/share/genkernel

	dodir /usr/bin
	dosym /usr/share/genkernel/genkernel /usr/bin/genkernel

	rm ${D}/usr/share/genkernel/genkernel.conf
	dodoc README

	doman genkernel.8
	rm genkernel.8

	cp "${DISTDIR}"/dmraid-${VERSION_DMRAID}.tar.bz2 \
	"${DISTDIR}"/LVM2.${VERSION_LVM2}.tgz \
	"${DISTDIR}"/device-mapper.${VERSION_DMAP}.tgz \
	"${DISTDIR}"/unionfs-utils-${VERSION_UNIONFS}.tar.gz \
	"${DISTDIR}"/e2fsprogs-${VERSION_E2FSPROGS}.tar.gz \
	"${DISTDIR}"/suspend-${VERSION_SUSPEND}.tar.gz \
	${D}/usr/share/genkernel/pkg

	dobashcompletion ${FILESDIR}/genkernel.bash
}

pkg_postinst() {
	echo
	elog 'Documentation is available in the genkernel manual page'
	elog 'as well as the following URL:'
	echo
	elog 'http://www.gentoo.org/doc/en/genkernel.xml'
	echo
	ewarn "This package is known to not work with reiser4.  If you are running"
	ewarn "reiser4 and have a problem, do not file a bug.  We know it does not"
	ewarn "work and we don't plan on fixing it since reiser4 is the one that is"
	ewarn "broken in this regard.  Try using a sane filesystem like ext3 or"
	ewarn "even reiser3."
	echo
	ewarn "The LUKS support has changed from versions prior to 3.4.4.  Now,"
	ewarn "you use crypt_root=/dev/blah instead of real_root=luks:/dev/blah."
	echo

	bash-completion_pkg_postinst
}
