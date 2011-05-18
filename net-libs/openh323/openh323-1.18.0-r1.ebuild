# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/openh323/openh323-1.18.0.ebuild,v 1.7 2006/10/24 03:33:36 dang Exp $

inherit eutils flag-o-matic multilib

MY_P="${PN}-v${PV//./_}"

DESCRIPTION="Open Source implementation of the ITU H.323 teleconferencing protocol"
HOMEPAGE="http://www.openh323.org/"
SRC_URI="http://www.voxgratia.org/releases/${PN}-v${PV//./_}-src-tar.gz"

IUSE="debug ssl novideo noaudio"
SLOT="0"
LICENSE="MPL-1.1"
KEYWORDS="~alpha amd64 ~hppa ppc sparc x86"

DEPEND=">=sys-apps/sed-4
	=dev-libs/pwlib-1.10*
	virtual/ffmpeg
	ssl? ( dev-libs/openssl )"

S="${WORKDIR}/${PN}_v${PV//./_}"

pkg_setup() {
	use debug || makeopts="NOTRACE=1"
}

src_unpack() {
	tar -xzf ${DISTDIR}/${A} -C ${WORKDIR} || die "Unpacking failed"

	cd ${S}
	# Makefile does not work correctly, fix
	epatch ${FILESDIR}/${PN}-1.18.0-install.diff

	# Fix linux/compiler.h header availability
	epatch ${FILESDIR}/${PN}-1.18.0-compiler.h.patch
}

src_compile() {
	# remove -fstack-protector, may cause problems (bug #75259)
	filter-flags -fstack-protector

	#export OPENH323DIR=${S}

	econf \
		$(use_enable !novideo video) \
		$(use_enable !noaudio audio) \
		--disable-transnexusosp \
		|| die "econf failed"
	emake ${makeopts} opt || die "emake failed"
}

src_install() {
	emake ${makeopts} PREFIX=/usr DESTDIR=${D} install || die "emake install failed"

	###
	# Compatibility "hacks"
	#

	# debug / no debug use different suffixes - some packages build with only one
	for i in ${D}/usr/lib/libh323_linux_x86_*; do
		use debug && ln -s ${D}/usr/lib/libh323_linux_x86_*.so.*.*.* ${i/_r/_n} \
			|| ln -s ${D}/usr/lib/libh323_linux_x86_*.so.*.*.* ${i/_n/_r}
	done

	# set notrace corerctly
	use debug || dosed "s:^\(NOTRACE.*\):\1 1:" /usr/share/openh323/openh323u.mak

	# mod to keep gnugk happy
	insinto /usr/share/openh323/src
	echo -e "opt:\n\t:" > ${T}/Makefile
	doins ${T}/Makefile

	# these should point to the right directories,
	# openh323.org apps and others need this
	dosed "s:^OH323_LIBDIR = \$(OPENH323DIR).*:OH323_LIBDIR = /usr/${libdir}:" \
		/usr/share/openh323/openh323u.mak
	dosed "s:^OH323_INCDIR = \$(OPENH323DIR).*:OH323_INCDIR = /usr/include/openh323:" \
		/usr/share/openh323/openh323u.mak

	# this is hardcoded now?
	dosed "s:^\(OPENH323DIR[ \t]\+=\) ${S}:\1 /usr/share/openh323:" \
		/usr/share/openh323/openh323u.mak
}
