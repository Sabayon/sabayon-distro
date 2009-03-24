# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit mono eutils

DESCRIPTION="New type of file manager"
HOMEPAGE="http://www.iola.dk/nemo"
NMO_URL="http://www.iola.dk/nemo/downloads"
SRC_URI="${NMO_URL}/${P}.tar.bz2"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="beagle tracker"

RDEPEND=">=gnome-base/libgnome-2.18.0
>=dev-dotnet/gnome-sharp-2.0
>=dev-dotnet/gtk-sharp-2.0
>=x11-libs/cairo-1.4.2
>=x11-libs/gtk+-2.10
beagle? ( >=app-misc/beagle-xesam-0.2 )
tracker? ( >=app-misc/tracker-0.6.3 )"

DEPEND="${RDEPEND}
>=dev-lang/mono-1.2.4
dev-util/pkgconfig"

S="${WORKDIR}/${P}"

src_unpack() {
	unpack ${A}
	cd "${S}"
}

src_compile() {

	#no configure script with source

	if [ -x ./configure ];then
	econf \
	  $(use_enable beagle) \
	  $(use_enable tracker)
	fi
	   if [ -f Makefile ] || [ -f GNUmakefile ] || [ -f makefile ]; then
	   emake || die "emake failed"
	fi
}

src_install() {
	make install DESTDIR="${D}" || die "make install failed"
}

pkg_postinst() {
	elog "If you compiled Nemo with tracker USE flag enabled, run /usr/bin/trackerd &"
	elog "before starting Nemo"
	elog
	ewarn "If you enabled the beagle USE flag, run beagled &&"
	ewarn "beagle-xesam-adaptor , before starting Nemo"
	ewarn
}
