# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/squashfs-tools/squashfs-tools-3.3.ebuild,v 1.3 2008/06/19 17:39:18 wolf31o2 Exp $

inherit eutils toolchain-funcs

MY_PV=${PV/_p/-r}
DESCRIPTION="Tool for creating compressed filesystem type squashfs"
HOMEPAGE="http://squashfs.sourceforge.net/"
SRC_URI="mirror://sourceforge/squashfs/squashfs${MY_PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~m68k ~mips ppc ppc64 ~s390 ~sh sparc x86"
IUSE=""

RDEPEND="sys-libs/zlib"

S=${WORKDIR}/squashfs${PV/_p/-r}/squashfs-tools

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i "s:-O2:${CFLAGS}:" Makefile
	epatch "${FILESDIR}"/squashfs-tools-3.3-posix.patch || die patching failed
	epatch "${FILESDIR}"/squashfs-tools-3.3-fix-segv-and-mksquashfs-hang.patch || die patching failed
}

src_compile() {
	emake CC="$(tc-getCC)" || die
}

src_install() {
	dobin mksquashfs unsquashfs || die
	cd ..
	dodoc README ACKNOWLEDGEMENTS CHANGES PERFORMANCE.README README-3.3
}

pkg_postinst() {
	elog "This version of mksquashfs requires a 2.6.24 kernel or better."
}
