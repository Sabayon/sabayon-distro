# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-drivers/xf86-video-ati/xf86-video-ati-6.14.0.ebuild,v 1.1 2011/02/04 14:56:46 scarabeus Exp $

EAPI=3
inherit xorg-2

DESCRIPTION="ATI video driver"

KEYWORDS="~alpha ~amd64 ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE=""

RDEPEND=">=x11-base/xorg-server-1.6.3[-minimal]"
DEPEND="${RDEPEND}
	|| ( <x11-libs/libdrm-2.4.22 x11-libs/libdrm[video_cards_radeon] )
	x11-proto/fontsproto
	x11-proto/glproto
	x11-proto/randrproto
	x11-proto/videoproto
	x11-proto/xextproto
	x11-proto/xf86driproto
	x11-proto/xf86miscproto
	x11-proto/xproto"

PATCHES=(
	"${FILESDIR}/0002-UMS-DCE3.2-fix-segfault.patch"
	"${FILESDIR}/0003-UMS-fix-spelling-in-error-message.patch"
	"${FILESDIR}/0004-kms-r6xx-clean-up-pitch-height-alignment-in-EXA-UTS-.patch"
	"${FILESDIR}/0005-6xx-7xx-consolidate-remaining-CB-state.patch"
	"${FILESDIR}/0006-evergreen-ni-consolidate-CB-state-handling.patch"
	"${FILESDIR}/0007-6xx-7xx-consolidate-spi-setup.patch"
	"${FILESDIR}/0008-evergreen-NI-consolidate-spi-setup.patch"
	"${FILESDIR}/0009-6xx-switch-to-linear-aligned-rather-than-linear-gene.patch"
)

pkg_setup() {
	xorg-2_pkg_setup
	CONFIGURE_OPTIONS="
		--enable-dri
		--enable-kms
	"
}
