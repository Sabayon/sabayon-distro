# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

DESCRIPTION="Visit almost everything in your PC simply by zooming in"
HOMEPAGE="http://eaglemode.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="abiword dvi +html +jpeg +netpbm +png povray rar svg +tiff xine wmf +zip"

DEPEND="dev-lang/perl
	x11-libs/libX11
	app-text/ghostscript-gpl
	jpeg? ( virtual/jpeg )
	png? ( media-libs/libpng )
	tiff? ( media-libs/tiff )
	xine? ( media-libs/xine-lib )
	zip? ( app-arch/unzip )
	rar? ( app-arch/unrar )
	abiword? ( app-office/abiword )
	dvi? ( dev-texlive/texlive-basic )
	netpbm? ( media-libs/netpbm )
	html? ( app-text/htmldoc )
	povray? ( media-gfx/povray )
	svg? ( gnome-base/librsvg )
	wmf? ( media-libs/libwmf )"
RDEPEND="${DEPEND}"

src_compile() {
	# TODO honor CC/CFLAGS/...
	perl make.pl build || die "Compilation failed"
}

src_install() {
	perl make.pl install dir="${D}"/usr/share/${PN} || die "Installation failed"
	dosym /usr/share/${PN}/${PN}.sh /usr/bin/${PN}
}
