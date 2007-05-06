# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/hwinfo/hwinfo-13.0.ebuild,v 1.3 2006/09/29 22:40:15 robbat2 Exp $

inherit eutils multilib

DESCRIPTION="hwinfo is the hardware detection tool used in SuSE Linux."
HOMEPAGE="http://www.suse.com"
DEBIAN_PV="3"
DEBIAN_BASE_URI=" mirror://debian/pool/main/${PN:0:1}/${PN}/"
SRC_URI="${DEBIAN_BASE_URI}/${PN}_${PV}.orig.tar.gz
		 ${DEBIAN_BASE_URI}/${PN}_${PV}-${DEBIAN_PV}.diff.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc ~x86 ~amd64"
IUSE=""
RDEPEND=">=sys-fs/sysfsutils-2
		sys-apps/hal
		sys-apps/dbus"
# this package won't work on *BSD
DEPEND="${RDEPEND}
		>=sys-kernel/linux-headers-2.6.17"

src_unpack (){
	unpack ${PN}_${PV}.orig.tar.gz
	EPATCH_OPTS="-p1 -d ${S}" epatch ${DISTDIR}/${PN}_${PV}-${DEBIAN_PV}.diff.gz
	rm ${S}/debian/patches/series
	for p in ${S}/debian/patches/*; do
		EPATCH_OPTS="-p0 -d ${S}" epatch ${p}
	done
	EPATCH_OPTS="-p1 -d ${S}" epatch ${FILESDIR}/${PN}-13.11-makefile-fixes.patch
	#sed -i -e "s,^LIBS[ \t]*= -lhd,LIBS = -lhd -lsysfs," ${S}/Makefile
	#sed -i -e "s,^LIBDIR[ \t]*= /usr/lib$,LIBDIR = /usr/$(get_libdir)," ${S}/Makefile
	echo 'libs: $(LIBHD) $(LIBHD_SO)' >>${S}/Makefile
}

src_compile(){
	# build is NOT parallel safe
	emake -j1 EXTRA_FLAGS="${CFLAGS}" || die "emake failed"
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc VERSION README COPYING ChangeLog
	doman doc/hwinfo.8
	# this is the SuSE version
	# somebody needs to port it still
	rm ${D}/etc/init.d/hwscan
}
