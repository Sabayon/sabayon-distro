# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

XORG_DRI=always
inherit xorg-2

DESCRIPTION="ATI video driver"

KEYWORDS="~alpha amd64 ~ia64 ~ppc ~ppc64 ~sparc x86"
IUSE="glamor udev"

RDEPEND=">=x11-libs/libdrm-2.4.36[video_cards_radeon]
	glamor? ( x11-libs/glamor )
	udev? ( virtual/udev )"
DEPEND="${RDEPEND}"

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
