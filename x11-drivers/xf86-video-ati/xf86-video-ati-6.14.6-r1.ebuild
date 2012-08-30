# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

XORG_DRI=always
XORG_EAUTORECONF=yes
inherit xorg-2

DESCRIPTION="ATI video driver"

KEYWORDS="~alpha ~amd64 ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~amd64-fbsd ~x86-fbsd"
IUSE=""

RDEPEND=">=x11-libs/libdrm-2.4.36[video_cards_radeon]"
DEPEND="${RDEPEND}"

src_prepare() {
	# disable XAA to allow building against >=xorg-server-1.12.99.902, bug #428094
	sed -i '/USE_XAA, 1/d' configure.ac || die
	xorg-2_src_prepare
}

pkg_setup() {
	xorg-2_pkg_setup
	XORG_CONFIGURE_OPTIONS=(
		--enable-dri
		--enable-kms
		--enable-exa
	)
}

src_install() {
	xorg-2_src_install

	# install a modprobe.d file to make sure that KMS
	# is enabled for the radeon kernel driver
	# if this package is installed. KMS is now mandatory
	# but current Sabayon kernels have it disabled to
	# allow fglrx to work
	dodir /etc/modprobe.d
	echo "options radeon modeset=1" > radeon.conf
	insinto /etc/modprobe.d
	doins radeon.conf
}
