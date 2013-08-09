# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-drivers/xf86-video-ati/xf86-video-ati-7.2.0.ebuild,v 1.1 2013/08/07 13:36:09 chithanh Exp $

EAPI=5

XORG_DRI=always
inherit linux-info xorg-2

DESCRIPTION="ATI video driver"

KEYWORDS="~alpha ~amd64 ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="glamor udev"

RDEPEND=">=x11-libs/libdrm-2.4.46[video_cards_radeon]
	glamor? ( x11-libs/glamor )
	udev? ( virtual/udev )"
DEPEND="${RDEPEND}"

pkg_pretend() {
	if use kernel_linux ; then
		if kernel_is -ge 3 9; then
			CONFIG_CHECK="~!DRM_RADEON_UMS ~!FB_RADEON"
		else
			CONFIG_CHECK="~DRM_RADEON_KMS ~!FB_RADEON"
		fi
	fi
	check_extra_config
}

src_configure() {
	XORG_CONFIGURE_OPTIONS=(
		$(use_enable glamor)
		$(use_enable udev)
	)
	xorg-2_src_configure
}

pkg_preinst() {
	# "untrack" radeon.conf, starting from kernel 3.6, this is
	# no longer needed. However, we don't want to break the current
	# status-quo.
	if [ -f "${EROOT}/etc/modprobe.d/radeon.conf" ]; then
		cp "${EROOT}/etc/modprobe.d/"{radeon.conf,radeon.conf.untracked} || die
	fi
}

pkg_postinst() {
	if [ -f "${EROOT}/etc/modprobe.d/radeon.conf.untracked" ]; then
		mv "${EROOT}/etc/modprobe.d/"{radeon.conf.untracked,radeon.conf} || die
	fi
}
