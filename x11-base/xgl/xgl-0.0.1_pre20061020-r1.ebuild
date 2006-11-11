# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

SNAPSHOT="yes"

inherit flag-o-matic x-modular multilib

SNAPSHOT_DATE=${PV##*_pre}
MESA_PN="Mesa"
MESA_SRC_P="${MESA_PN}-20061027"
XGL_SRC_P="${PN}-${SNAPSHOT_DATE}"

SRC_URI="http://distfiles.gentoo-xeffects.org/snapshots/${MESA_PN}/${MESA_SRC_P}.tar.bz2
	http://distfiles.gentoo-xeffects.org/snapshots/${PN}/${XGL_SRC_P}.tar.bz2"

PATCHES="${FILESDIR}/${PN}-java-wmhack.patch"

S="${WORKDIR}/${PN}"

DESCRIPTION="XGL X server"
HOMEPAGE="http://xorg.freedesktop.org/"
LICENSE="X11"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~ppc"
IUSE="ipv6 xinerama"
DEPEND=">=media-libs/glitz-0.5.6
	>=media-libs/mesa-6.5.1_p20061020
	x11-proto/xf86driproto
	x11-proto/randrproto
	x11-proto/renderproto
	>=x11-proto/fixesproto-4.0
	x11-proto/damageproto
	x11-proto/xf86miscproto
	>=x11-proto/scrnsaverproto-1.1
	x11-proto/resourceproto
	x11-proto/fontsproto
	x11-proto/xf86dgaproto
	x11-proto/videoproto
	>=x11-proto/compositeproto-0.3
	x11-proto/trapproto
	x11-proto/recordproto
	x11-proto/xineramaproto
	x11-proto/evieext
	x11-libs/libXfont
	x11-libs/libxkbfile
	x11-libs/libxkbui
	x11-libs/libXxf86misc"

RESTRICT="nomirror"

pkg_setup() {
	# (#121394) Causes window corruption
	filter-flags -fweb

	CONFIGURE_OPTIONS="
		$(use_enable ipv6)
		$(use_enable xinerama)
		--enable-xgl
		--enable-xglx
		--enable-glx
		--enable-dri
		--disable-xorg
		--disable-aiglx
		--disable-dmx
		--disable-xvfb
		--disable-xnest
		--disable-xprint
		--with-mesa-source=${WORKDIR}/${MESA_PN}
		--sysconfdir=/etc/X11
		--localstatedir=/var
		--enable-install-setuid
		--with-font-dir=/usr/share/fonts
		--with-default-font-path=/usr/share/fonts/misc,/usr/share/fonts/75dpi,/usr/share/fonts/100dpi,/usr/share/fonts/TTF,/usr/share/fonts/Type1"

}

src_install() {
	x-modular_src_install

	rm "${D}/usr/share/aclocal/xorg-server.m4" \
		"${D}/usr/$(get_libdir)/xserver/SecurityPolicy" \
		"${D}/usr/$(get_libdir)/pkgconfig/xorg-server.pc" \
		"${D}/usr/share/man/man1/Xserver.1x"
}
