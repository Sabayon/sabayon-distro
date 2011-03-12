# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-drivers/xf86-video-intel/xf86-video-intel-2.14.0.ebuild,v 1.5 2011/03/05 15:51:42 armin76 Exp $

EAPI=3

inherit linux-info xorg-2

DESCRIPTION="X.Org driver for Intel cards"

KEYWORDS="amd64 ia64 x86 -x86-fbsd"
IUSE="dri"

RDEPEND=">=x11-base/xorg-server-1.6
	>=x11-libs/libdrm-2.4.23[video_cards_intel]
	x11-libs/libpciaccess
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXvMC
	>=x11-libs/libxcb-1.5"
DEPEND="${RDEPEND}
	>=x11-proto/dri2proto-1.99.3
	x11-proto/fontsproto
	x11-proto/randrproto
	x11-proto/renderproto
	x11-proto/xextproto
	x11-proto/xproto
	dri? ( x11-proto/xf86driproto
	       x11-proto/glproto )"

PATCHES=(
	"${FILESDIR}"/0001-update-priv-stride.patch
	"${FILESDIR}"/0002-tiling-xorg-opt.patch
	"${FILESDIR}"/0003-disable-page-flip-between-tiled-buffer-and-linear-scanout.patch
)

pkg_setup() {
	xorg-2_pkg_setup
	CONFIGURE_OPTIONS="$(use_enable dri) --enable-xvmc"
}

pkg_postinst() {
	if linux_config_exists \
		&& ! linux_chkconfig_present DRM_I915_KMS; then
		echo
		ewarn "This driver requires KMS support in your kernel"
		ewarn "  Device Drivers --->"
		ewarn "    Graphics support --->"
		ewarn "      Direct Rendering Manager (XFree86 4.1.0 and higher DRI support)  --->"
		ewarn "      <*>   Intel 830M, 845G, 852GM, 855GM, 865G (i915 driver)  --->"
		ewarn "              i915 driver"
		ewarn "      [*]       Enable modesetting on intel by default"
		echo
	fi
}
