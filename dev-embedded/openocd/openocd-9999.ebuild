# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="1"

inherit eutils subversion

DESCRIPTION="OpenOCD - Open On-Chip Debugger"
HOMEPAGE="http://openocd.berlios.de/web/"
ESVN_REPO_URI="http://svn.berlios.de/svnroot/repos/openocd/trunk"
SRC_URI=""
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="+ft2232 +presto libftdi parport_giveio"


S="${WORKDIR}/trunk"

# libftd2xx is the default because it is reported to work better.
DEPEND="ft2232? ( || ( libftdi? ( dev-embedded/libftdi )
		     ( dev-embedded/libftd2xx )
		) )
	presto? ( dev-embedded/libftd2xx )"

RDEPEND="${DEPEND}"

pkg_setup () {
	if use libftdi && ! use ft2232; then
	      ewarn "You enabled libftdi but not ft2232!"
	      ewarn "libftdi is only used for ft2232, so this is meaningless!"
	fi

	ewarn "Checks are only made for libftdi and libftd2xx!"
	ewarn "You are responsible to verify you have the drivers"
	ewarn "for any other devices you enable!"
}

src_compile () {
	cd "${S}"
	./bootstrap || die "Can't bootstrap!"

# Check which interfaces are enabled:
  	if use ft2232; then
	   F2232="$(use_enable libftdi ft2232_libftdi) $(use_enable !libftdi ft2232_ftd2xx)"
	fi

	
	DEFAULT_INTERFACES="--enable-parport --enable-parport_ppdev --enable-amtjtagaccel \
			    --enable-ep93xx --enable-at91rm9200 --enable-gw16012 \
			    --enable-usbprog --enable-oocd_trace"

	INTERFACES="${DEFAULT_INTERFACES} $(use_enable parport_giveio) $(use_enable presto presto_ftd2xx) ${F2232}"
	
	econf ${INTERFACES} || die "Error in econf!"
	emake || die "Error in emake!"
}

src_install () {
	cd "${S}/build"
	emake DESTDIR="$D" install
}
